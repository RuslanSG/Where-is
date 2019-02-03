//
//  GreetingsPageViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/25/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, WelcomeViewControllerDelegate, GreetingViewControllerDelegate {
    
    var pageViewController: UIPageViewController?
    var appearance: Appearance!
    
    private enum ViewControllerIdentifier {
        static let GreetingViewController = "greetingViewController"
        static let SensViewController = "sensViewController"
        static let TutorialViewController = "tutorialViewController"
        static let DarkModeViewController = "darkModeViewController"
        static let WelcomeViewController = "welcomeViewController"
    }
    
    private enum Strings {
        static let Next = NSLocalizedString("Далее", comment: "Кнопка, которая перемещает в следующее меню")
        static let Back = NSLocalizedString("Назад", comment: "Кнопка, которая перемещает в предыдущее меню")
        static let Of = NSLocalizedString("из", comment: "Например: 1 из 5")
    }
    
    private lazy var orderedViewControllers: [UIViewController] = {
        let greetingViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.GreetingViewController) as! GreetingViewController
        let sensViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.SensViewController)
        let tutorialViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.TutorialViewController) as! TutorialViewController
        let darkModeViewContoller = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.DarkModeViewController) as! DarkModeTableViewController
        let welcomeViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.WelcomeViewController) as! WelcomeViewController
        
        greetingViewController.delegate = self
        welcomeViewController.delegate = self
        darkModeViewContoller.appearance = appearance
        welcomeViewController.appearance = appearance
                
        return [greetingViewController,
                sensViewController,
                tutorialViewController,
                darkModeViewContoller,
                welcomeViewController]
    }()
    
    private lazy var visibleViewController = orderedViewControllers.first!
    
    private let topBarView: UIView = {
        let x = UIScreen.main.bounds.minX
        let y = UIScreen.main.bounds.minY
        let width = UIScreen.main.bounds.width
        let height = UIApplication.shared.statusBarFrame.height + 40
        let view = UIView(frame: CGRect(
            x: x,
            y: y,
            width: width,
            height: height)
        )
        view.alpha = 0.95
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let rightArrow = UIImage(named: "arrow_right")
        button.setTitle(Strings.Next, for: .normal)
        button.setImage(rightArrow, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let leftArrow = UIImage(named: "arrow_left")
        button.setTitle(Strings.Back, for: .normal)
        button.setImage(leftArrow, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        button.alpha = 0.0
        button.isEnabled = false
        return button
    }()
    
    private lazy var pageNumberLabel: UILabel = {
        let label = UILabel()
        let indexOfVisiblePage = orderedViewControllers.index(of: visibleViewController) ?? 0
        label.text = String(indexOfVisiblePage + 1) + " " + Strings.Of + " " + String(orderedViewControllers.count)
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInputComponents()
        visibleViewController = orderedViewControllers.first!
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(_:)),
            name: Notification.Name.DarkModeStateDidChange,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func nextButtonPressed(_ sender: UIButton) {
        guard let currentViewController = pageViewController?.viewControllers?.first else { return }
        guard let viewControllerIndex = orderedViewControllers.index(of: currentViewController) else { return }
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else { return }
        guard orderedViewControllers.count > nextIndex else { return }
        
        let nextViewController = orderedViewControllers[nextIndex]
        pageViewController?.setViewControllers(
            [nextViewController],
            direction: .forward,
            animated: true,
            completion: nil
        )
        setupControlButtons(to: nextViewController)
        visibleViewController = nextViewController
        updatePageLabel(currentPage: visibleViewController)
    }
    
    @objc private func backButtonPressed(_ sender: UIButton) {
        guard let currentViewController = pageViewController?.viewControllers?.first else { return }
        guard let viewControllerIndex = orderedViewControllers.index(of: currentViewController) else { return }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0  else { return }
        guard orderedViewControllers.count > previousIndex else { return }
        
        let previousViewController = orderedViewControllers[previousIndex]
        pageViewController?.setViewControllers(
            [previousViewController],
            direction: .reverse,
            animated: true,
            completion: nil
        )
        setupControlButtons(to: previousViewController)
        visibleViewController = previousViewController
        updatePageLabel(currentPage: visibleViewController)
    }
    
    // MARK: - GreetingViewControllerDelegate
    
    func skipButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - WelcomeViewControllerDelegate
    
    func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Notifications
    
    @objc func darkModeStateChangedNotification(_ notification: Notification) {
        setupColors()
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return appearance.darkMode ? .lightContent : .default
    }
    
    // MARK: - Helping Methods
    
    private func setupInputComponents() {
        self.pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        let greetingsViewController = orderedViewControllers[0]
        let viewControllers = [greetingsViewController]
        self.pageViewController!.setViewControllers(
            viewControllers,
            direction: .forward,
            animated: false,
            completion: {done in }
        )
        
        self.addChild(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 100.0, dy: 100.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParent: self)
        
        self.view.addSubview(topBarView)
        self.view.addSubview(nextButton)
        self.view.addSubview(backButton)
        self.view.addSubview(pageNumberLabel)
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        let inset: CGFloat = 5.0
        let height: CGFloat = 22.0
        let width: CGFloat = 80.0
        
        /// nextButton constraints
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: statusBarHeight + inset).isActive = true
        nextButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -inset).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        /// nextButton constraints
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: statusBarHeight + inset).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: inset).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        /// pageNumberLabel constraints
        pageNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        pageNumberLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pageNumberLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: statusBarHeight + inset).isActive = true
        pageNumberLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func setupColors() {
        let duration = 0.6
        let delay = 0.0
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: delay,
            options: .curveEaseInOut,
            animations: {
                self.pageNumberLabel.textColor = self.appearance.textColor
                self.view.backgroundColor = self.appearance.tableViewBackgroundColor
                self.topBarView.backgroundColor = self.appearance.tableViewBackgroundColor
        })
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func newViewConrtoller(withIdentifier identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return newViewController
    }
    
    private func setupControlButtons(to viewController: UIViewController) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.nextButton.alpha = viewController == self.orderedViewControllers.last! ? 0.0 : 1.0
                self.backButton.alpha = viewController == self.orderedViewControllers.first! ? 0.0 : 1.0
                self.nextButton.isEnabled = viewController == self.orderedViewControllers.last! ? false : true
                self.backButton.isEnabled = viewController == self.orderedViewControllers.first! ? false : true
        },
            completion: nil
        )
    }
    
    private func updatePageLabel(currentPage: UIViewController) {
        let indexOfVisiblePage = orderedViewControllers.index(of: currentPage) ?? 0
        pageNumberLabel.text = String(indexOfVisiblePage + 1) + " " + Strings.Of + " " + String(orderedViewControllers.count)
    }

}

