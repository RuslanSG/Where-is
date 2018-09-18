//
//  GameViewControllerHelper.swift
//  25
//
//  Created by Ruslan Gritsenko on 22.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation

extension GameViewController: CLLocationManagerDelegate {
    
    var cornerRadius: CGFloat {
        if  self.view.traitCollection.horizontalSizeClass == .regular,
            self.view.traitCollection.verticalSizeClass == .regular {
            return 12.0
        } else {
            return 7.0
        }
    }
    
    var numbersFontSize: CGFloat {
        return self.view.bounds.width / 10
    }
    
    var gridInset: CGFloat {
        return self.view.bounds.width / 200
    }
    
    var buttonsContainerViewFrame: CGRect {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let staturBarHeight = UIApplication.shared.statusBarFrame.height
        
        let bottomGap = screenHeight - stopButton.frame.maxY
        
        let minY = staturBarHeight + gridInset
        let maxY = screenHeight - stopButton.frame.height - bottomGap - gridInset
        let maxAlllowedHeight = maxY - minY
        
        let expectedHeight = screenWidth / CGFloat(game.colums) * CGFloat(game.rows)
        let expectedMinY = screenHeight / 2 - expectedHeight / 2
        let expectedMaxY = screenHeight / 2 + expectedHeight / 2
        
        let width = screenWidth - gridInset * 2
        var height: CGFloat {
            return expectedHeight < maxAlllowedHeight ? expectedHeight : maxAlllowedHeight
        }
        
        let x = gridInset
        var y: CGFloat {
            if expectedHeight < maxAlllowedHeight {
                if expectedMinY < minY && expectedMaxY < maxY {
                    return minY
                } else if expectedMinY > minY && expectedMaxY > maxY {
                    return expectedMinY - (expectedMaxY - maxY)
                } else {
                    return expectedMinY
                }
            } else {
                return minY
            }
        }
        
        return CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
    }
    
    // MARK: - Cells
    
    func updateButtonsFrames() {
        for i in buttons.indices {
            let button = buttons[i]
            if let viewFrame = grid[i]?.insetBy(dx: gridInset, dy: gridInset) {
                button.frame = viewFrame
            }
        }
    }
    
    func feedbackSelection(isRight: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: [],
            animations: {
                self.feedbackView.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.1490196078, blue: 0.1215686275, alpha: 1)
        }) { (position) in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.1,
                delay: 0.0,
                options: [],
                animations: {
                    self.feedbackView.backgroundColor = .clear
            })
        }
    }
    
    func addButtons(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to add. Provide a multiple of five number.")
        for _ in 0..<count {
            let button: UIButton = {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                button.titleLabel?.font = UIFont.systemFont(ofSize: numbersFontSize)
                button.titleLabel?.alpha = 0.0
                button.backgroundColor = game.colorfulCellsMode ? randomColor : defaultCellsColor
                button.setTitleColor(textColor, for: .normal)
                button.layer.cornerRadius = cornerRadius
                button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchDown)
                button.addTarget(self, action: #selector(buttonReleased(sender:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(buttonReleased(sender:)), for: .touchUpOutside)
                return button
            }()
            buttons.append(button)
            buttonsContainerView.addSubview(button)
        }
    }
    
    func removeButtons(count: Int) {
        assert(count % 5 == 0, "Reason: invalid number of buttons to remove. Provide a multiple of five number.")
        for _ in 0..<count {
            let lastButton = buttons.last
            if let lastButton = lastButton {
                lastButton.removeFromSuperview()
            }
            buttons.removeLast()
        }
    }
    
    func compressButton(_ button: UIButton) {
        buttonFrameX = button.frame.minX
        buttonFrameY = button.frame.minY
        buttonFrameWidth = button.frame.width
        buttonFrameHeight = button.frame.height
        
        let newButtonFrameX = button.frame.minX + button.frame.width * CGFloat(1 - cellCompressionRatio) / 2
        let newButtonFrameY = button.frame.minY + button.frame.height * CGFloat(1 - cellCompressionRatio) / 2
        let newButtonFrameWidth = button.frame.width * CGFloat(cellCompressionRatio)
        let newButtonFrameHeight = button.frame.height * CGFloat(cellCompressionRatio)
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.05,
            delay: 0.0,
            options: [],
            animations: {
                button.frame = CGRect(
                    x: newButtonFrameX,
                    y: newButtonFrameY,
                    width: newButtonFrameWidth,
                    height: newButtonFrameHeight
                )
        })
    }
    
    func uncompressButton(_ button: UIButton) {
        if let buttonFrameX = self.buttonFrameX,
            let buttonFrameY = self.buttonFrameY,
            let buttonFrameWidth = self.buttonFrameWidth,
            let buttonFrameHeight = self.buttonFrameHeight {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0.0,
                options: [],
                animations: {
                    button.frame = CGRect(
                        x: buttonFrameX,
                        y: buttonFrameY,
                        width: buttonFrameWidth,
                        height: buttonFrameHeight
                    )
                    button.titleLabel?.alpha = 1.0
            })
            self.buttonFrameX = nil
            self.buttonFrameY = nil
            self.buttonFrameWidth = nil
            self.buttonFrameHeight = nil
        }
    }
    
    
    
    // MARK: - Numbers
    
    func showNumbers(animated: Bool) {
        buttons.forEach({ (button) in
            button.isEnabled = true
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 1.0
                })
            } else {
                button.titleLabel?.alpha = 1.0
            }
        })
    }
    
    func hideNumbers(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 0.0
                })
            } else {
                button.titleLabel?.alpha = 0.0
            }
        })
    }
    
    func setNumbers() {
        for i in buttons.indices {
            let number = game.numbers[i]
            let button = buttons[i]
            button.setTitle(String(number), for: .normal)
            button.tag = number
        }
    }
    
    func updateNumbers(animated: Bool) {
        for i in buttons.indices {
            let number = game.numbers[i]
            let button = buttons[i]
            if animated && buttonsNotAnimating.contains(button) {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 0.0
                }) { (position) in
                    button.setTitle(String(number), for: .normal)
                    button.tag = number
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.1,
                        delay: 0.0,
                        options: [],
                        animations: {
                            button.titleLabel?.alpha = 1.0
                    })
                }
            } else {
                button.setTitle(String(number), for: .normal)
                button.tag = number
            }
        }
    }
    
    func winkNumber(at button: UIButton) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: {
                button.titleLabel?.alpha = 0.0
        }) { (_) in
            if self.game.inGame {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.5,
                    delay: 0.9,
                    options: [],
                    animations: {
                        button.titleLabel?.alpha = 1.0
                }, completion: { (_) in
                    self.buttonsNotAnimating.append(button)
                })
            }
        }
    }
    
    func swapNumbers(animated: Bool) {
        let button1 = buttonsNotAnimating[buttonsNotAnimating.count.arc4random]
        guard let index1 = buttonsNotAnimating.index(of: button1) else { return }
        buttonsNotAnimating.remove(at: index1)
        
        let button2 = buttonsNotAnimating[buttonsNotAnimating.count.arc4random]
        guard let index2 = buttonsNotAnimating.index(of: button2) else { return }
        buttonsNotAnimating.remove(at: index2)
        
        let number1 = button1.tag
        let number2 = button2.tag
        
        let duration = 1.0
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration / 2,
                delay: 0.0,
                options: [],
                animations: {
                    button1.titleLabel?.alpha = 0.0
                    button2.titleLabel?.alpha = 0.0
            }) { (position) in
                if self.game.inGame {
                    button1.setTitle(String(number2), for: .normal)
                    button2.setTitle(String(number1), for: .normal)
                    button1.tag = number2
                    button2.tag = number1
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: duration / 2,
                        delay: 0.0,
                        options: [],
                        animations: {
                            button1.titleLabel?.alpha = 1.0
                            button2.titleLabel?.alpha = 1.0
                    })
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.buttonsNotAnimating.append(button1)
                self.buttonsNotAnimating.append(button2)
            }
        }
    }
    
    // MARK: - Colors
    
    func shuffleCellsColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.backgroundColor = self.randomColor
                })
            } else {
                button.backgroundColor = randomColor
            }
        })
    }
    
    func shuffleNumbersColors(animated: Bool) {
        let colorSet = currentColorSet.map { darkMode ? $0.dark : $0.light }
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        if let color = self.getAnotherColor(for: button, from: colorSet) {
                            button.setTitleColor(color, for: .normal)
                        }
                })
            } else {
                if let color = self.getAnotherColor(for: button, from: colorSet) {
                    button.setTitleColor(color, for: .normal)
                }
            }
        })
    }
    
    func removeCellColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.backgroundColor = self.defaultCellsColor
                })
            } else {
                button.backgroundColor = defaultCellsColor
            }
        })
    }
    
    func winkCellColor(at button: UIButton) {
        let colorSet = currentColorSet.map { darkMode ? $0.dark : $0.light }
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: {
                if let color = self.getAnotherColor(for: button, from: colorSet) {
                    button.backgroundColor = color
                }
        })
    }
    
    func removeNumberColors(animated: Bool) {
        buttons.forEach({ (button) in
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: [],
                    animations: {
                        button.setTitleColor(self.textColor, for: .normal)
                })
            } else {
                button.setTitleColor(self.textColor, for: .normal)
            }
        })
    }
        
    // MARK: - Message view
    
    func showMessage() {
        self.view.addSubview(messageView)
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: [],
            animations: {
                self.messageView.alpha = 1.0
        })
    }
    
    func hideMessage() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: [],
            animations: {
                self.messageView.alpha = 0.0
        }) { (_) in
            self.messageView.removeFromSuperview()
        }
    }
    
    // MARK: - Location
    
    func getUserLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            currentLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        }
    }
    
    // MARK: - Sunrise/Sunset Time Info
    
    internal func getSunTimeInfo(with location: CLLocationCoordinate2D) {
        guard let solar = Solar(coordinate: location) else { return }
        let sunrise = calendar.date(byAdding: .hour, value: 3, to: solar.sunrise!)!
        let sunset = calendar.date(byAdding: .hour, value: 3, to: solar.sunset!)!
        self.sunrise = sunrise
        self.sunset = sunset
        
    }
    
    // MARK: - Helping Methods
    
    internal func startGame() {
        if resultsIsShowing {
            resultsView.hide()
            resultsIsShowing = false
        }
        showNumbers(animated: true)
        game.startGame()
        gameFinished = false
        
        feedbackGenerator.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactFeedbackGenerator?.prepare()
        
        if game.colorfulCellsMode {
            shuffleCellsColors(animated: true)
        }
        if game.colorfulNumbersMode {
            shuffleNumbersColors(animated: true)
        }
        
        if game.winkNumbersMode {
            timer1 = Timer.scheduledTimer(
                timeInterval: TimeInterval(3.5 / Double(game.maxNumber)),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: true
            )
        }
        
        if game.swapNumbersMode {
            timer2 = Timer.scheduledTimer(
                timeInterval: TimeInterval(5.0 / Double(game.maxNumber)),
                target: self,
                selector: #selector(timerSceduled),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    func prepareForNewGame(hideMessageLabel: Bool = true) {
        game.newGame()
        setNumbers()
        gameFinished = true
        if game.winkNumbersMode || game.winkColorsMode || game.swapNumbersMode {
            timer1.invalidate()
            timer2.invalidate()
            buttons.forEach { $0.titleLabel?.layer.removeAllAnimations() }
        }
        hideNumbers(animated: false)
        showMessage()
    }
    
    func getAnotherColor(for button: UIButton, from colorSet: [UIColor]) -> UIColor? {
        let buttonColor = button.backgroundColor
        var otherColors = colorSet
        if let buttonColor = buttonColor {
            let index = otherColors.index(of: buttonColor)
            if let index = index {
                otherColors.remove(at: index)
                return otherColors[otherColors.count.arc4random]
            }
        }
        return nil
    }
    
    enum CellPart {
        case number
        case color
    }
    
    @objc func timerSceduled() {
        if game.winkNumbersMode {
            wink(.number)
        }
        if game.winkColorsMode {
            wink(.color)
        }
        if game.swapNumbersMode {
            swapNumbers(animated: true)
        }
    }
    
    func wink(_ cellPart: CellPart) {
        if cellPart == .number {
            let button = buttonsNotAnimating[buttonsNotAnimating.count.arc4random]
            if let index = buttonsNotAnimating.index(of: button) {
                buttonsNotAnimating.remove(at: index)
            }
            winkNumber(at: button)
        }
        if cellPart == .color {
            let button = buttons[buttons.count.arc4random]
            winkCellColor(at: button)
        }
    }
    
    func setDarkModeByCurrentTime() {
        if let isDay = isDay {
            darkMode = !isDay
        }
    }
    
}
