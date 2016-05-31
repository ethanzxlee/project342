//
//  CustomPresentationController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 18/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    
    var chromeView = UIView()
    
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView,
            let presentedView = self.presentedView(),
            let transitionCoordinator = self.presentingViewController.transitionCoordinator()
        else {
            return
        }
        
        // Setup the chromeView
        self.chromeView.frame = containerView.bounds
        self.chromeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.chromeView.alpha = 0
        
        // Add the views into the container
        containerView.addSubview(self.chromeView)
        containerView.addSubview(presentedView)
        
        // Animate the chromeView fade in animation alongside with the transition animation
        transitionCoordinator.animateAlongsideTransition({ (context) in
            self.chromeView.alpha = 1
        }, completion: nil)
    }

    
    override func presentationTransitionDidEnd(completed: Bool) {
        // Remove the chromeView if the presentation was abborted
        if (!completed) {
            self.chromeView.removeFromSuperview()
        }
    }
    
    
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = self.presentingViewController.transitionCoordinator() else {
            return
        }
        
        // Animate the chromeView fade out animation alongside with the transition animation
        transitionCoordinator.animateAlongsideTransition({ (context) in
            self.chromeView.alpha = 0
        }, completion: nil)
    }
    
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        // Remove the chromeVeiw if the dismissal was completed
        if (completed) {
            self.chromeView.removeFromSuperview()
        }
    }
    
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        // Make the presentedView not fullscreen
        guard let containerView = self.containerView else {
            return CGRect()
        }
        
        return CGRectInset(containerView.bounds, 30, 30)
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        // Resize the chromeView when the containerView resizes
        coordinator.animateAlongsideTransition({ (context) in
            self.chromeView.frame = context.containerView().bounds
        }, completion: nil)
    }
    
}
