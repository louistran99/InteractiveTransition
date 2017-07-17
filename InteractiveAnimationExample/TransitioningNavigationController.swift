//
//  TransitioningNavigationController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/17/17.
//  Copyright © 2017 IF. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


class TransitioningNavigationController: NSObject {
    var transitionOperation : UINavigationControllerOperation = .none
    var transitionAnimator : UIViewPropertyAnimator!
    var transitionContext : UIViewControllerContextTransitioning? 
    let navigationController : UINavigationController!
    var transitionItemFromFrame = CGRect.zero
    var transitionItemToFrame = CGRect.zero
    var initiallyInteractive = false
    
    init(navigationController : UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
        let panGestureRecognizer = UIPanGestureRecognizer()
        self.navigationController.view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        
        
        
    }
    
    
    func handlePanGesture (_ panGesture : UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            handleBeganState(panGesture)
        case .changed:
            handleChangedState(panGesture)
        case .ended:
            handleEndedState(panGesture)
        default:
            handleOtherStates(panGesture)
        }
    }
    
    
    func handleBeganState (_ panGesture : UIPanGestureRecognizer) {
        print("Began")
    }
    
    func handleChangedState (_ panGesture : UIPanGestureRecognizer) {
        print("Changed")
    }
    
    func handleEndedState (_ panGesture : UIPanGestureRecognizer) {
    
    }
    
    func handleOtherStates (_ panGesture : UIPanGestureRecognizer) {
    
    }
    
}



// MARK: UINavigationControllerDelegate
extension TransitioningNavigationController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }



}

// MARK: UIViewControllerInteractiveTransitioning
extension TransitioningNavigationController : UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        //
    }
    
    var wantsInteractiveStart: Bool {
        return initiallyInteractive
    }
}



