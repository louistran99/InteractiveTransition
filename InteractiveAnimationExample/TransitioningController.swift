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
    var navigationVC : UINavigationController?
    var initialFrame : CGRect?
    
    var initiallyInteractive = false
    fileprivate let duration = 0.75
    fileprivate var presenting = false
    fileprivate var transitionOperation : UINavigationControllerOperation = .none
    let panGestureRecognizer : UIPanGestureRecognizer

    init (panGesture: UIPanGestureRecognizer, viewControllerToPresent : UIViewController) {
        presentedVC = viewControllerToPresent
        panGestureRecognizer = panGesture
        super.init()
        presentedVC?.transitioningDelegate = self
        panGestureRecognizer.addTarget(self, action: #selector(updateAnimation(_:)))
    }
    init (panGesture: UIPanGestureRecognizer, navigationController : UINavigationController) {
        navigationVC = navigationController
        panGestureRecognizer = panGesture
        super.init()
        navigationVC?.delegate = self
        navigationVC?.view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(updateAnimation(_:)))
    }
    
    func endAnimation () {
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
    
    func updateAnimation (_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            initiallyInteractive = true
        case .changed:
            animatePanningChanged(panGesture)
        case .ended:
            endAnimation()
        default:
            break
        }
    }
    
    func animatePanningChanged (_ panGesture : UIPanGestureRecognizer) {
        guard transitionContext != nil else {
            return
        }
        
        let translation = panGesture.translation(in: self.transitionContext?.containerView)
        let screenFrame = (self.transitionContext?.containerView.frame)!
        var progress : CGFloat = 0.0
        switch transitionOperation {
        case .push:
            progress = -translation.y/(screenFrame.height)
            progress = max(0,progress)
        case .pop:
            progress = translation.y/(screenFrame.height)
            progress = max(0,progress)
        case .none:
            if (presenting) {
                progress = -translation.y/(screenFrame.height)
                progress = max(0,progress)
            } else {
                progress = translation.y/(screenFrame.height)
                progress = max(0,progress)
            }
        }
        
        print("progress: \(progress)\t translation:\(translation)")
        transitionAnimator?.fractionComplete = progress
        if let context = transitionContext {
            context.updateInteractiveTransition(progress)
        }
    }
    
    private func completionPosition() -> UIViewAnimatingPosition {
        let completionThreshold: CGFloat = 0.33
        let flickMagnitude: CGFloat = 1200 //pts/sec
        let velocity = panGestureRecognizer.velocity(in: transitionContext?.containerView)
        let isFlick = (sqrt(velocity.x*velocity.x+velocity.y*velocity.y) > flickMagnitude)
        let isFlickDown = isFlick && (velocity.y > 0.0)
        let isFlickUp = isFlick && (velocity.y < 0.0)
        
        switch self.transitionOperation {
        case .push:
            if (isFlickUp || transitionAnimator.fractionComplete > completionThreshold) {
                return .end
            } else if (isFlickDown) {
                return .start
            }
            break
        case .pop:
            if (isFlickDown) {
                return .end
            } else if (isFlickUp) {
                return .start
            }
            break
        case .none:
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
        return .start
    }
}

//MARK: DetialViewControlerDelegate
extension TransitioningController : DetialViewControlerDelegate {
    func panGestureDidPan(_ panGesture: UIPanGestureRecognizer) {
        updateAnimation(panGesture)
    }
}

//MARK: UINavigationControllerDelegate
extension TransitioningController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionOperation = operation
        return self
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
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
    
    func animationEnded(_ transitionCompleted: Bool) {
        initiallyInteractive = false
        transitionOperation = .none
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionAnimator
    }
}

// MARK: UIViewControllerInteractiveTransitioning
extension TransitioningController : UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containterView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let toAffineTransform = CGAffineTransform.identity
        let fromAffineTransform = toAffineTransform.translatedBy(x: (initialFrame?.minX)!, y: (initialFrame?.minY)!)
        
        
        var detailView = toView
        switch self.transitionOperation {
        case .push:
            detailView = toView
        case .pop:
            detailView = fromView
        case .none:
            if (presenting) {
                detailView = toView
            } else {
                detailView = fromView
            }
        }
        
        switch self.transitionOperation {
            case .push:
                detailView.transform = fromAffineTransform
            case .pop:
                detailView.transform  = CGAffineTransform.identity
            case .none:
                if (presenting) {
                    detailView.transform = fromAffineTransform
                } else {
                    detailView.transform = toAffineTransform
                }
        }
        
        print("from transform:\(fromAffineTransform)\t to transform:\(toAffineTransform)")

        detailView.clipsToBounds = true
        containterView.addSubview(toView)
        containterView.bringSubview(toFront: detailView)

        transitionAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut, animations: {
            switch self.transitionOperation {
            case .push:
                detailView.transform = CGAffineTransform.identity
            case .pop:
                detailView.transform  = fromAffineTransform
            case .none:
                if (self.presenting) {
                    detailView.transform = CGAffineTransform.identity
                } else {
                    detailView.transform = fromAffineTransform
                }
            }
        })
        
        transitionAnimator.addCompletion { [unowned self] (position) in
            let completeTransition = (position == .end)
            transitionContext.completeTransition(completeTransition)
            if (self.presenting && completeTransition) {
                let vc = transitionContext.viewController(forKey: .to) as! DetailViewController
                vc.delegate = self
                vc.transitioningDelegate = self
                vc.transitioningController = self
                self.presenting = false
            } else if (self.transitionOperation == .push && completeTransition) {
                let vc = transitionContext.viewController(forKey: .to) as! DetailViewController
                vc.delegate = self
                vc.transitioningController = self
            }
        }
        
        if (!transitionContext.isInteractive) {
            if (transitionAnimator.state == .inactive) {
                transitionAnimator.startAnimation()
            } else {
                transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.25)
            }
        }
    }
    
    var wantsInteractiveStart: Bool {
        return initiallyInteractive
    }
}







