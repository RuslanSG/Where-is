//
//  GreetingsPageViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/25/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    var pageViewController: UIPageViewController?
    var game: Game!
    
    private lazy var orderedViewControllers: [UIViewController] = {
        let greetingsViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.greetingsViewController.rawValue)
        let sensViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.sensViewController.rawValue)
        let tutorialViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.tutorialViewController.rawValue) as! TutorialViewController
        let remindersViewContoller = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.remindersViewController.rawValue)
        let darkModeViewContoller = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.darkModeViewController.rawValue)
        let welcomeViewController = self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.welcomeViewController.rawValue)
                
        return [greetingsViewController,
                sensViewController,
                tutorialViewController,
                remindersViewContoller,
                darkModeViewContoller,
                welcomeViewController]
    }()
    
    private lazy var visibleViewController = orderedViewControllers.first!
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let rightArrow = UIImage(named: "arrow_right")
        button.setTitle("Далее", for: .normal)
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
        button.setTitle("Назад", for: .normal)
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
        label.text = "\(indexOfVisiblePage + 1) из \(orderedViewControllers.count)"
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInputComponents()
        visibleViewController = orderedViewControllers.first!
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
            pageViewRect = pageViewRect.insetBy(dx: 200.0, dy: 200.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParent: self)
        
        self.view.addSubview(nextButton)
        self.view.addSubview(backButton)
        self.view.addSubview(pageNumberLabel)
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let inset: CGFloat = 5.0
        let height = 22.0
        let width = 80.0
        
        self.view.addConstraintsWithFormat(format: "H:[v0(\(width))]-\(inset)-|", views: nextButton)
        self.view.addConstraintsWithFormat(format: "V:|-\(statusBarHeight + inset)-[v0(\(height))]", views: nextButton)
        
        self.view.addConstraintsWithFormat(format: "H:|-\(inset)-[v0(\(width))]", views: backButton)
        self.view.addConstraintsWithFormat(format: "V:|-\(statusBarHeight + inset)-[v0(\(height))]", views: backButton)
        
        self.pageNumberLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.view.addConstraintsWithFormat(format: "V:|-\(statusBarHeight + inset)-[v0(\(height))]", views: pageNumberLabel)
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
        pageNumberLabel.text = "\(indexOfVisiblePage + 1) из \(orderedViewControllers.count)"
    }

}

