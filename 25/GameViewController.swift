//
//  ViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 07.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, SettingsTableViewControllerDelegate {
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: -
    
    lazy var feedbackView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = .clear
        view.alpha = 0.25
        return view
    }()
    
    lazy var buttonsContainerView: UIView = {
        let view = UIView(frame: buttonsFieldFrame)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var resultsView: ResultsView = {
        let blur = UIBlurEffect(style: .light)
        let view = ResultsView(
            frame: self.view.frame,
            effect: blur,
            userInterfaceColor: userInterfaceColor,
            cornerRadius: cornerRadius,
            fontsColor: darkMode ? numbersColors.darkMode : numbersColors.lightMode
        )
        view.alpha = 0.0
        return view
    }()
    
    lazy var messageView: MessageView = {
        let blur = UIBlurEffect(style: darkMode ? .dark : .light)
        let view = MessageView(effect: blur)
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        view.alpha = 0.0
        return view
    }()
        
    // MARK: -
    
    private let userDefaults = UserDefaults.standard
    private let darkModeKey = "darkMode"
    
    var game = Game() {
        didSet {
            print("didSet")
        }
    }
    
    var gameFinished = false {
        didSet {
            if gameFinished {
                self.view.bringSubview(toFront: resultsView)
            } else {
                self.view.sendSubview(toBack: resultsView)
            }
            stopButton.isEnabled = !gameFinished
        }
    }
    
    var grid: Grid {
        return Grid(layout: .dimensions(rowCount: game.rows, columnCount: game.colums), frame: buttonsContainerView.bounds)
    }
    
    var buttons = [UIButton]() {
        didSet {
            buttonsContainerView.frame = buttonsFieldFrame
        }
    }
    
    var buttonFrameX: CGFloat?
    var buttonFrameY: CGFloat?
    var buttonFrameHeight: CGFloat?
    var buttonFrameWidth: CGFloat?
    
    let cellCompressionRatio = 0.90
    
    var timer = Timer()
    
    let feedbackGenerator = FeedbackGenerator()
    
    private var messageViewHeight: CGFloat {
        if let button = buttons.first {
            let height = buttons.count % 10 == 0 ? button.bounds.height * 2 + gridInset * 2 : button.bounds.height
            return height
        }
        return 0.0
    }
    
    private var messageViewWidth: CGFloat {
        if let button = buttons.first {
            let width = button.bounds.width * 3 + gridInset * 4
            return width
        }
        return 0.0
    }
    
    // MARK: - Colors
    
    private let cellsColors     = (darkMode: #colorLiteral(red: 0.2203874684, green: 0.2203874684, blue: 0.2203874684, alpha: 1), lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    private let numbersColors   = (darkMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), lightMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    private let mainViewColors  = (darkMode: #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1), lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    
    private let colorSets = [[(light: #colorLiteral(red: 0.06666666667, green: 0.4666666667, blue: 0.7215686275, alpha: 1), dark: #colorLiteral(red: 0.03137254902, green: 0.3058823529, blue: 0.4941176471, alpha: 1)),
                              (light: #colorLiteral(red: 0.09803921569, green: 0.6588235294, blue: 0.6117647059, alpha: 1), dark: #colorLiteral(red: 0.06666666667, green: 0.4823529412, blue: 0.462745098, alpha: 1)),
                              (light: #colorLiteral(red: 0.1607843137, green: 0.6862745098, blue: 0.1137254902, alpha: 1), dark: #colorLiteral(red: 0.05098039216, green: 0.4392156863, blue: 0.05882352941, alpha: 1))],
                             
                             [(light: #colorLiteral(red: 0.968627451, green: 0.7254901961, blue: 0.168627451, alpha: 1), dark: #colorLiteral(red: 0.8057276114, green: 0.4694959764, blue: 0.1296572619, alpha: 1)),
                              (light: #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1), dark: #colorLiteral(red: 0.599486165, green: 0.08605109967, blue: 0.05797519395, alpha: 1)),
                              (light: #colorLiteral(red: 0.7882352941, green: 0.1843137255, blue: 0.4823529412, alpha: 1), dark: #colorLiteral(red: 0.5, green: 0.1014612427, blue: 0.3135548154, alpha: 1))],
                             
                             [(light: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1), dark: #colorLiteral(red: 0.3025199942, green: 0.301058545, blue: 0.3039814435, alpha: 1)),
                              (light: #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1), dark: #colorLiteral(red: 0.4634119638, green: 0.2628604885, blue: 0.05822089579, alpha: 1)),
                              (light: #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1), dark: #colorLiteral(red: 0.4723546985, green: 0.4624517336, blue: 0.09191328908, alpha: 1))]]
    
    var defaultCellsColor: UIColor {
        return darkMode ? cellsColors.darkMode : cellsColors.lightMode
    }
    var defaultNumbersColor: UIColor {
        return darkMode || game.colorfulCellsMode ? numbersColors.darkMode : numbersColors.lightMode
    }
    var mainViewColor: UIColor {
        return darkMode ? mainViewColors.darkMode : mainViewColors.lightMode
    }

    lazy var randomColorSet = colorSets[colorSets.count.arc4random]

    var randomColor: UIColor {
        let randomColor = darkMode ? randomColorSet[randomColorSet.count.arc4random].dark :
                                     randomColorSet[randomColorSet.count.arc4random].light
        return randomColor
    }
    
    private var userInterfaceColor: UIColor! {
        didSet {
            stopButton.tintColor = userInterfaceColor
            settingsButton.tintColor = userInterfaceColor
        }
    }
    
    var darkMode = false {
        didSet {
            self.view.backgroundColor = mainViewColor
            game.colorfulCellsMode ? shuffleCellsColors(animated: false) : removeCellColors(animated: false)
            removeNumberColors(animated: false)
            UIApplication.shared.statusBarStyle = darkMode ? .lightContent : .default
            userInterfaceColor = randomColor
            
            resultsView.effect = darkMode ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
            resultsView.userInterfaceColor = userInterfaceColor
            resultsView.fontsColor = darkMode ? numbersColors.darkMode : numbersColors.lightMode
            
            messageView.label.textColor = defaultNumbersColor
            messageView.effect = darkMode ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        setupInputComponents()
        prepareForNewGame()
    }
    
    // MARK: - Setup UI
    
    func setupInputComponents() {
        userInterfaceColor = randomColor
        
        self.view.addSubview(resultsView)
        self.view.addSubview(feedbackView)
        self.view.addSubview(buttonsContainerView)
        self.view.addSubview(messageView)
        
        addButtons(count: game.numbers.count)
        updateButtonsFrames()
        
        self.view.sendSubview(toBack: feedbackView)
        self.view.sendSubview(toBack: resultsView)
        self.view.bringSubview(toFront: messageView)
        
        let height = messageViewHeight
        if let button = buttons.first {
            let width = button.bounds.width * 3 + gridInset * 4
            messageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            messageView.center = self.view.center
        }
    }
    
    // MARK: - Actions
    
    @objc func buttonPressed(sender: UIButton) {
        compressButton(sender)
        if gameFinished {
            startGame()
            hideMessage()
            feedbackGenerator.playImpactHapticFeedback(needsToPrepare: true, style: .medium)
            return
        }
        let selectedNumberIsRight = game.selectedNumberIsRight(sender.tag)
        if selectedNumberIsRight && sender.tag == game.maxNumber {
            // User tapped the last number
            game.finishGame()
            showResults(time: game.elapsedTime, maxNumber: game.maxNumber, level: game.level - 1)
            prepareForNewGame(hideMessageLabel: false)
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .success)
            uncompressButton(sender)
            return
        }
        if selectedNumberIsRight {
            // User tapped the right number
            feedbackGenerator.playImpactHapticFeedback(needsToPrepare: true, style: .medium)
        } else {
            // User tapped the wrong number
            feedbackSelection(isRight: false)
            feedbackGenerator.playNotificationHapticFeedback(notificationFeedbackType: .error)
        }
        if game.shuffleNumbersMode {
            game.shuffleNumbers()
            updateNumbers(animated: true)
        } else {
            if !game.winkNumbersMode {
                sender.titleLabel?.alpha = 0.2
            }
        }
        if game.shuffleColorsMode {
            shuffleCellsColors(animated: true)
            shuffleNumbersColors(animated: true)
        }
        game.numberSelected(sender.tag)
    }
    
    @objc func buttonReleased(sender: UIButton) {
        if !gameFinished, !game.shuffleNumbersMode, !game.winkNumbersMode {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.0,
                options: [],
                animations: {
                    sender.titleLabel?.alpha = 1.0
            })
        }
        uncompressButton(sender)
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        prepareForNewGame()
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
             self.prepareForNewGame()
        })
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    
    func colorfulNumbersModeStateChanged(to state: Bool) {
        if state == false {
            removeNumberColors(animated: false)
        }
        prepareForNewGame()
    }
    
    func colorfulCellsModeStateChanged(to state: Bool) {
        if state == false {
            removeCellColors(animated: false)
            removeNumberColors(animated: false)
        }
        prepareForNewGame()
    }
    
    func maxNumberChanged(to maxNumber: Int) {
        if buttons.count < maxNumber {
            game.rows += 1
            addButtons(count: maxNumber - buttons.count)
        } else {
            game.rows -= 1
            removeButtons(count: buttons.count - maxNumber)
        }
        
        messageView.frame = CGRect(x: 0.0, y: 0.0, width: messageViewWidth, height: messageViewHeight)
        messageView.center = self.view.center
        
        updateButtonsFrames()
        prepareForNewGame()
    }
    
    
    func darkModeStateChanged(to state: Bool) {
        darkMode = state
        prepareForNewGame()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let nav = segue.destination as? UINavigationController,
            let svc = nav.topViewController as? SettingsTableViewController {
            svc.delegate = self
            svc.game = game
            svc.userInterfaceColor = userInterfaceColor
            svc.darkMode = darkMode
        }
    }
        
}


