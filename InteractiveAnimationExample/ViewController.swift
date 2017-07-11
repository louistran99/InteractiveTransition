//
//  ViewController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/6/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit

enum viewState {
    case preview, fullview
}

class ViewController: UIViewController {

    @IBOutlet var previewView : UIView!
    var state : viewState = .preview
    var panningViewAnimator : UIViewPropertyAnimator!
    var panningViewControllerAnimator : UIViewPropertyAnimator? = nil
    var bottomFrame : CGRect = CGRect.zero
    var topFrame : CGRect = CGRect.zero
    
    let duration = 1.0
    var originalFrame = CGRect.zero
    var isPresenting = false
    var transitionContext : UIViewControllerContextTransitioning? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let panGesture = UIPanGestureRecognizer()
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        self.previewView.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleTapGesture(_:)))
        self.previewView.addGestureRecognizer(tapGesture)
        self.bottomFrame = self.previewView.frame
        self.topFrame = CGRect.init(x: 0, y: 0, width: self.previewView.frame.width, height: self.previewView.frame.height)
        if let navigationBar = self.navigationController?.navigationBar {
            self.topFrame = CGRect.init(x: 0, y: navigationBar.frame.origin.y + navigationBar.frame.height, width: self.previewView.frame.width, height: self.previewView.frame.height)
        }
        
        self.title = "Master View"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTapGesture(_ tabpGestureRecognizer : UITapGestureRecognizer) {
        let detailVC : DetailViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewControllerID") as! DetailViewController;
        detailVC.transitioningDelegate = self
        self.present(detailVC, animated: true) {}
    }

    func handlePanGesture (_ panGestureRecognizer : UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
                self.panningBegan(panGestureRecognizer)
        case .changed:
                self.panningChanged(panGestureRecognizer)
        case .ended:
                self.panningEnded(panGestureRecognizer)
        default:
            break
        }
        
    }
    
    func panningBegan (_ panGesture : UIPanGestureRecognizer) {
        if ((self.panningViewAnimator) != nil) {
            if (self.panningViewAnimator.isRunning) {
                return
            }
        }
        var endFrame : CGRect
        switch self.state {
            case .preview:
                endFrame = self.topFrame
                let detailVC : DetailViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewControllerID") as! DetailViewController;
                detailVC.transitioningDelegate = self
                self.present(detailVC, animated: true) {}
            
            case .fullview:
                endFrame = self.bottomFrame
        }
        self.panningViewAnimator = UIViewPropertyAnimator.init(duration: 1.0, dampingRatio: 0.4, animations: { 
            self.previewView.frame = endFrame
        })
        

    }
    
    func panningChanged (_ panGesture : UIPanGestureRecognizer) {
        if ((self.panningViewAnimator) != nil) {
            if (self.panningViewAnimator.isRunning) {
                return
            }
        }
        let translation = panGesture.translation(in: self.view)
        let screenFrame = self.view.frame
        var progress : CGFloat = 0.0
        switch self.state {
        case .preview:
            progress = -translation.y/(screenFrame.height-64)
            progress = max(0,progress)
        case .fullview:
            progress = translation.y/(screenFrame.height-64)
            progress = max(0,progress)
        }
        print("progress: \(progress)")
        panningViewAnimator.fractionComplete = progress
        panningViewControllerAnimator?.fractionComplete = progress
        if let context = transitionContext {
            context.updateInteractiveTransition(progress)
        }
        
    }
    
    func panningEnded (_ panGesture : UIPanGestureRecognizer) {
        if ((self.panningViewAnimator) != nil) {
            if (self.panningViewAnimator.isRunning) {
                return
            }
        }
        
        panGesture.isEnabled = false
        let translation = panGesture.translation(in: self.view)
        let velocity = panGesture.velocity(in: self.view)
        let progress = fabs(translation.y / self.view.frame.height)

        switch self.state {
        case .preview:
            if (progress > 0.5 || velocity.y < -200.0) {
                self.panningViewAnimator.isReversed = false
                self.panningViewAnimator.addCompletion({(finalPosition) in
                    self.state = .fullview
                    panGesture.isEnabled = true
                })
                self.transitionContext?.finishInteractiveTransition()
            } else {
                self.panningViewAnimator.isReversed = true
                self.panningViewAnimator.addCompletion({(finalPosition) in
                    panGesture.isEnabled = true
                })
                self.transitionContext?.cancelInteractiveTransition()
            }
        case .fullview:
            if (progress > 0.5 || velocity.y > 200.0) {
                self.panningViewAnimator.isReversed = false
                self.panningViewAnimator.addCompletion({(finalPosition) in
                    self.state = .preview
                    panGesture.isEnabled = true
                })
            } else {
                self.panningViewAnimator.isReversed = true
                self.panningViewAnimator.addCompletion({(finalPosition) in
                    panGesture.isEnabled = true
                })
            }
        }
        let velocityVector : CGVector = CGVector.init(dx: velocity.x/100, dy: velocity.y/100)
        let springTimingParams = UISpringTimingParameters.init(dampingRatio: 0.8, initialVelocity: velocityVector)
        self.panningViewAnimator.continueAnimation(withTimingParameters: springTimingParams, durationFactor: 0.25)
        self.panningViewControllerAnimator?.continueAnimation(withTimingParameters: springTimingParams, durationFactor: 0.25)
        
    }
    
}

//MARK: UIGestureRecognizerDelegate
extension ViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: UIViewControllerTransitioningDelegate
extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        originalFrame = previewView.superview!.convert(previewView.frame, to: nil)
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        originalFrame = previewView.superview!.convert(previewView.frame, to: nil)
        isPresenting = true
        return self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isPresenting = false
        return self
    }
    
}

// MARK: UIViewControllerAnimatedTransitioning
extension ViewController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.interruptibleAnimator(using: transitionContext).startAnimation()
//        let containterView = transitionContext.containerView
//        let toView = transitionContext.view(forKey: .to)!
//        let fromView = transitionContext.view(forKey: .from)!
//        let toViewController = transitionContext.viewController(forKey: .to)
//        let fromViewcontroller = transitionContext.viewController(forKey: .from)
//        
//        
//        let detailView = isPresenting ? toView : fromView
//        let initialFrame = isPresenting ? originalFrame : fromView.frame
//        let finalFrame = isPresenting ? toView.frame : originalFrame
//        
//        let xScaleFactor = initialFrame.width / finalFrame.width
//        let yScaleFactor = xScaleFactor
//        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
//        
//        if (isPresenting) {
//            detailView.transform = scaleTransform
//            detailView.frame.origin = initialFrame.origin
//            //            detailView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
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
    }
    func animationEnded(_ transitionCompleted: Bool) {
        print(transitionCompleted)
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return self.panningViewControllerAnimator!
    }
}

// MARK: UIViewControllerInteractiveTransitioning
extension ViewController : UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        self.transitionContext = transitionContext
        
        let containterView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let detailView = isPresenting ? toView : fromView
        let initialFrame = isPresenting ? originalFrame : fromView.frame
        let finalFrame = isPresenting ? toView.frame : originalFrame
        
        let xScaleFactor = initialFrame.width / finalFrame.width
        let yScaleFactor = xScaleFactor
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if (isPresenting) {
            detailView.transform = scaleTransform
            detailView.frame.origin = initialFrame.origin
            detailView.clipsToBounds = true
        }
        containterView.addSubview(toView)
        containterView.bringSubview(toFront: detailView)
        

        self.panningViewControllerAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.4, animations: {
            detailView.transform = CGAffineTransform.identity
            detailView.frame.origin = CGPoint(x: 0, y: 0)
        })
        
        
        panningViewControllerAnimator?.addCompletion({ (position) in
            let completed = (position == .end)
            self.transitionContext?.completeTransition(completed)
        })
        
        if (transitionContext.isInteractive) {
        
        } else {
            if (panningViewControllerAnimator?.state == .inactive) {
                self.panningViewControllerAnimator?.startAnimation()
            } else {
                panningViewControllerAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0.25)
            }
            
        }
        
        
    }
    
    var wantsInteractiveStart: Bool {
        return true
    }
    
    
}





