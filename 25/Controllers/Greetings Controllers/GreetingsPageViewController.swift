//
//  GreetingsPageViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/25/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class GreetingsPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewConrtoller(withIdentifier: ViewControllerIdentifier.greetingsVC.rawValue)]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        if  let firstViewController = orderedViewControllers.first {
            setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0  else { return orderedViewControllers.last }
        guard orderedViewControllers.count > previousIndex else { return nil }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else { return orderedViewControllers.first }
        guard orderedViewControllers.count > nextIndex else { return nil }
        return orderedViewControllers[nextIndex]
    }
    
    // MARK: - Helping Methods
    
    private func newViewConrtoller(withIdentifier identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return newViewController
    }

}
