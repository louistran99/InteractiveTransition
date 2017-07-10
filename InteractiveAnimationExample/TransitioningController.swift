//
//  TransitioningController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/8/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit

class TransitioningController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning
 {
    weak var navigationController : UINavigationController?
    var transitionOperation : UINavigationControllerOperation = .none
    var presenting = false
    let duration = 0.75
    var originalFrame = CGRect.zero
    var transitionAnimator : UIViewPropertyAnimator!

    //MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containterView = transitionContext.containerView
//        let toView = transitionContext.view(forKey: .to)!
//        let fromView = transitionContext.view(forKey: .from)!
//        let toViewController = transitionContext.viewController(forKey: .to)
//        let fromViewcontroller = transitionContext.viewController(forKey: .from)
//        
//        
//        let detailView = presenting ? toView : fromView
//        let initialFrame = presenting ? originalFrame : fromView.frame
//        let finalFrame = presenting ? toView.frame : originalFrame
//        
//        let xScaleFactor = initialFrame.width / finalFrame.width
//        let yScaleFactor = xScaleFactor
//        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
//        
//        if (presenting) {
//            detailView.transform = scaleTransform
//            detailView.frame.origin = initialFrame.origin
////            detailView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
//            detailView.clipsToBounds = true
//        }
//        
//        containterView.addSubview(toView)
//        containterView.bringSubview(toFront: detailView)
//        
//        UIView.animate(withDuration: duration, animations: { 
//            detailView.transform = CGAffineTransform.identity
//            detailView.frame.origin = CGPoint(x: 0, y: 0)
//        }, completion: {_ in
//            transitionContext.completeTransition(true)
//        })
//        
    }

    func animationEnded(_ transitionCompleted: Bool) {
        
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // set up & return property animator
        transitionAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: { 
            let containterView = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!
            let fromView = transitionContext.view(forKey: .from)!
            let toViewController = transitionContext.viewController(forKey: .to)
            let fromViewcontroller = transitionContext.viewController(forKey: .from)
        })
    
        return transitionAnimator
    }

}


extension TransitioningController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionOperation = operation
        return self
    }
}









