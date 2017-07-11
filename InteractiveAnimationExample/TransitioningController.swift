//
//  TransitioningController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/8/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit

class TransitioningController: NSObject, UIViewControllerAnimatedTransitioning {
  
    var transitionAnimator : UIViewPropertyAnimator!
    let transitionContext : UIViewControllerContextTransitioning
    var parentViewController : UIViewController?

    
    private var presenting = false
    private let duration = 0.75
    private let panGestureRecognizer : UIPanGestureRecognizer


    init (context: UIViewControllerContextTransitioning, panGestureRecognizer panGesture: UIPanGestureRecognizer, viewController parentVC : UIViewController) {
        self.transitionContext = context
        self.parentViewController = parentVC
        self.panGestureRecognizer = panGesture
        super.init()
        
        
        
    }
    
    // MARK -- UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containterView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)
        let fromViewcontroller = transitionContext.viewController(forKey: .from)
        
        
        let detailView = presenting ? toView : fromView
        let initialFrame = presenting ? originalFrame : fromView.frame
        let finalFrame = presenting ? toView.frame : originalFrame
        
        let xScaleFactor = initialFrame.width / finalFrame.width
        let yScaleFactor = xScaleFactor
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if (presenting) {
            detailView.transform = scaleTransform
            detailView.frame.origin = initialFrame.origin
//            detailView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            detailView.clipsToBounds = true
        }
        
        containterView.addSubview(toView)
        containterView.bringSubview(toFront: detailView)
        
        UIView.animate(withDuration: duration, animations: { 
            detailView.transform = CGAffineTransform.identity
            detailView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: {_ in
            transitionContext.completeTransition(true)
        })
        
        
    }

}


extension TransitioningController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionOperation = operation
        return self
    }

}





