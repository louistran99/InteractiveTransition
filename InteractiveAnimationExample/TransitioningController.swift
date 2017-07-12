//
//  TransitioningController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/8/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit

class TransitioningController: NSObject {
  
    var transitionAnimator : UIViewPropertyAnimator!
    var transitionContext : UIViewControllerContextTransitioning? = nil
    var presentedVC : UIViewController?
    var initialFrame : CGRect?
    
    fileprivate let duration = 0.75
    fileprivate var presenting = false
    fileprivate let panGestureRecognizer : UIPanGestureRecognizer


    init (panGesture: UIPanGestureRecognizer, viewControllerToPresent : UIViewController) {
        presentedVC = viewControllerToPresent
        panGestureRecognizer = panGesture
        super.init()
        
        viewControllerToPresent.transitioningDelegate = self
        panGestureRecognizer.addTarget(self, action: #selector(updateAnimation(_:)))
        
    }
    
    func updateAnimation (_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: transitionContext?.containerView)
        switch panGesture.state {
        case .began, .changed:
            animatePanningChanged(panGesture)
        case .ended, .cancelled, .failed:
            animatePanningEnded(panGesture)
        default:
            break
        }
    }
    
    func animatePanningChanged (_ panGesture : UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: presentedVC?.view)
        let screenFrame = (presentedVC?.view.frame)!
        var progress : CGFloat = 0.0
        if (presenting) {
            progress = -translation.y/(screenFrame.height-64)
            progress = max(0,progress)
        } else {
            progress = translation.y/(screenFrame.height-64)
            progress = max(0,progress)
        }
        print("progress: \(progress)")
        transitionAnimator?.fractionComplete = progress
        if let context = transitionContext {
            context.updateInteractiveTransition(progress)
        }
    }
    
    func animatePanningEnded (_ panGesture: UIPanGestureRecognizer) {
        guard let context = transitionContext else {
            return
        }
        guard (context.isInteractive) else {
            return
        }
        let position = self.completionPosition()
        if (position == .end) {
            transitionAnimator.isReversed = false
            context.finishInteractiveTransition()
        } else {
            transitionAnimator.isReversed = true
            context.cancelInteractiveTransition()
        }
        transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.25)
    
    }

    
    private func completionPosition() -> UIViewAnimatingPosition {
        let completionThreshold: CGFloat = 0.33
        let flickMagnitude: CGFloat = 1200 //pts/sec
        let velocity = panGestureRecognizer.velocity(in: transitionContext?.containerView)
        let isFlick = (sqrt(velocity.x*velocity.x+velocity.y*velocity.y) > flickMagnitude)
        let isFlickDown = isFlick && (velocity.y > 0.0)
        let isFlickUp = isFlick && (velocity.y < 0.0)
        
        if (presenting && isFlickUp) || (!presenting && isFlickDown) {
            return .end
        } else if (presenting && isFlickDown) || (!presenting && isFlickUp) {
            return .start
        } else if transitionAnimator.fractionComplete > completionThreshold {
            return .end
        } else {
            return .start
        }
    }
}

//MARK: DetialViewControlerDelegate
extension TransitioningController : DetialViewControlerDelegate {
    func panGestureDidPan(_ panGesture: UIPanGestureRecognizer) {
        updateAnimation(panGesture)
    }
}


//MARK: UIViewControllerTransitionDelegate
extension TransitioningController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presenting = false
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        presenting = true
        return self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        presenting = false
        return self
    }

}

// MARK: UIViewControllerAnimatedTransitioning
extension TransitioningController : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return self.transitionAnimator
    }
}

// MARK: UIViewControllerInteractiveTransitioning
extension TransitioningController : UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containterView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let detailView = presenting ? toView : fromView
        let finalFrame = toView.frame

        var xScaleFactor : CGFloat = 1.0
        var yScaleFactor : CGFloat = 1.0
        if let initialFrame = initialFrame {
            xScaleFactor = initialFrame.width / finalFrame.width
            yScaleFactor = xScaleFactor
        }
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        let toAffineTransform = CGAffineTransform.identity

        let fromAffineTransform = scaleTransform.translatedBy(x: (initialFrame?.minX)!-finalFrame.minX, y: (initialFrame?.minY)!-finalFrame.minY)
        
        if (presenting) {
            detailView.transform = fromAffineTransform
        } else {
            detailView.transform = toAffineTransform
        }
        detailView.clipsToBounds = true
        containterView.addSubview(toView)
        containterView.bringSubview(toFront: detailView)

        transitionAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut, animations: { 
            if (self.presenting) {
                detailView.transform = toAffineTransform
            } else {
                detailView.transform = fromAffineTransform
            }
        })
        
        transitionAnimator.addCompletion { [unowned self] (position) in
            let completeTransition = (position == .end)
            transitionContext.completeTransition(completeTransition)
            if (self.presenting) {
                let vc = transitionContext.viewController(forKey: .to) as! DetailViewController
                vc.delegate = self
                vc.transitioningDelegate = self
                self.presenting = false
            }
        }
        
        if (transitionContext.isInteractive) {
            
        } else {
            if (transitionAnimator.state == .inactive) {
                transitionAnimator.startAnimation()
            } else {
                transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.25)
            }
        }
    }
    
}







