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
    var previewOriginalFrame : CGRect = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let panGesture = UIPanGestureRecognizer()
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        self.previewView.addGestureRecognizer(panGesture)
        self.previewOriginalFrame = self.previewView.frame
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                endFrame = CGRect.init(x: 0, y: 0, width: previewOriginalFrame.width, height: previewOriginalFrame.height)
            case .fullview:
                endFrame = previewOriginalFrame
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
            progress = -translation.y/screenFrame.height
            progress = max(0,progress)
        case .fullview:
            progress = (translation.y/screenFrame.height)
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

        print("velocity: \(velocity)\tprogress:\(progress)")
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



}


