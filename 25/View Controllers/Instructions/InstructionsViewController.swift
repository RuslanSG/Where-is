//
//  InstructionsViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 8/25/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {
    
    var needsToShowWelcome = true
    
    private var pageViewController: InstructionsPageViewController!
    private var detailViewControllers = [UIViewController]()
    private var currentViewControllerIndex = 0

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 13.0, *) {
//            isModalInPresentation = needsToShowWelcome
//            view.backgroundColor = .systemBackground
//        }
        
        configurePageViewController()
        configureDetailViewControllers()
    }
    
    // MARK: - Private Methods
    
    private func configurePageViewController() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: InstructionsPageViewController.self)) as? InstructionsPageViewController else { return }
        
        self.pageViewController = pageViewController
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageViewController.view)
        
        let margins = view.layoutMarginsGuide
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func configureDetailViewControllers() {
        guard let welcomeViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: WelcomeViewController.self)) as? WelcomeViewController else { return }
        guard let tutorialViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: TutorialViewController.self)) as? TutorialViewController else { return }
        
        welcomeViewController.delegate = self
        tutorialViewController.delegate = self
        
        detailViewControllers = [welcomeViewController, tutorialViewController]
        
        let initialViewController = needsToShowWelcome ? welcomeViewController : tutorialViewController
        pageViewController.setViewControllers([initialViewController], direction: .forward, animated: true)
    }

}

extension InstructionsViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return detailViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentViewControllerIndex = detailViewControllers.firstIndex(of: viewController) else { return nil }
        let previousViewControllerIndex = currentViewControllerIndex - 1
        
        if detailViewControllers.indices.contains(previousViewControllerIndex) {
            self.currentViewControllerIndex = previousViewControllerIndex
            return detailViewControllers[previousViewControllerIndex]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentViewControllerIndex = detailViewControllers.firstIndex(of: viewController) else { return nil }
        let nextViewControllerIndex = currentViewControllerIndex + 1
        
        if detailViewControllers.indices.contains(nextViewControllerIndex) {
            self.currentViewControllerIndex = nextViewControllerIndex
            return detailViewControllers[nextViewControllerIndex]
        } else {
            return nil
        }
    }
}

extension InstructionsViewController: WelcomeViewControllerDelegate {
    
    func nextButtonPressed(_ viewController: WelcomeViewController) {
        guard let index = detailViewControllers.firstIndex(of: viewController) else { return }
        let nextViewController = detailViewControllers[index + 1]
        pageViewController.setViewControllers([nextViewController], direction: .forward, animated: true)
    }
    
    func skipButtonPressed(_ viewController: WelcomeViewController) {
        UserDefaults.standard.set(false, forKey: UserDefaults.Key.firstTime)
        dismiss(animated: true)
    }
}

extension InstructionsViewController: TutorialViewControllerDelegate {
    
    func doneButtonPressed(_ viewController: TutorialViewController) {
        UserDefaults.standard.set(false, forKey: UserDefaults.Key.firstTime)
        dismiss(animated: true)
    }
}
