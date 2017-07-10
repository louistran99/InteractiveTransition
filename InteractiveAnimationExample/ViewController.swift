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
    var panningAnimator : UIViewPropertyAnimator!
    var bottomFrame : CGRect = CGRect.zero
    var topFrame : CGRect = CGRect.zero
    let transitioningController = TransitioningController()
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
        detailVC.modalPresentationStyle = .custom
        self.present(detailVC, animated: true) {}
//        self.navigationController?.pushViewController(detailVC, animated: true);
        
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
 
        if ((self.panningAnimator) != nil) {
            if (self.panningAnimator.isRunning) {
                return
            }
        }
        var endFrame : CGRect
        switch self.state {
            case .preview:
                endFrame = self.topFrame
            case .fullview:
                endFrame = self.bottomFrame
        }
        
        self.panningAnimator = UIViewPropertyAnimator.init(duration: 1.0, dampingRatio: 0.4, animations: { 
            self.previewView.frame = endFrame
        })
    }
    
    func panningChanged (_ panGesture : UIPanGestureRecognizer) {
        if ((self.panningAnimator) != nil) {
            if (self.panningAnimator.isRunning) {
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
        panningAnimator.fractionComplete = progress
    }
    
    func panningEnded (_ panGesture : UIPanGestureRecognizer) {
        if ((self.panningAnimator) != nil) {
            if (self.panningAnimator.isRunning) {
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
                self.panningAnimator.isReversed = false
                self.panningAnimator.addCompletion({(finalPosition) in
                    self.state = .fullview
                    panGesture.isEnabled = true
                })
            } else {
                self.panningAnimator.isReversed = true
                self.panningAnimator.addCompletion({(finalPosition) in
                    panGesture.isEnabled = true
                })
            }
        case .fullview:
            if (progress > 0.5 || velocity.y > 200.0) {
                self.panningAnimator.isReversed = false
                self.panningAnimator.addCompletion({(finalPosition) in
                    self.state = .preview
                    panGesture.isEnabled = true
                })
            } else {
                self.panningAnimator.isReversed = true
                self.panningAnimator.addCompletion({(finalPosition) in
                    panGesture.isEnabled = true
                })
            }
        }
        let velocityVector : CGVector = CGVector.init(dx: velocity.x/100, dy: velocity.y/100)
        let springTimingParams = UISpringTimingParameters.init(dampingRatio: 0.8, initialVelocity: velocityVector)
        self.panningAnimator.continueAnimation(withTimingParameters: springTimingParams, durationFactor: 0.25)
    }
    
}

extension ViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioningController.originalFrame = previewView.superview!.convert(previewView.frame, to: nil)
        transitioningController.presenting = true
        return transitioningController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioningController.presenting = false
        return transitioningController
    }
    
}





