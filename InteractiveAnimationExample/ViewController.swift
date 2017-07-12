//
//  ViewController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/6/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit
import AVFoundation

enum viewState {
    case preview, fullview
}

class ViewController: UIViewController {

    @IBOutlet var previewView : UIView!
    var state : viewState = .preview
    var panningViewControllerAnimator : UIViewPropertyAnimator? = nil
    var bottomFrame : CGRect = CGRect.zero
    var topFrame : CGRect = CGRect.zero
    
    let duration = 1.0
    var originalFrame = CGRect.zero
    var isPresenting = false
    var transitionContext : UIViewControllerContextTransitioning?
    fileprivate var panGesture : UIPanGestureRecognizer?
    fileprivate var tapGesture : UITapGestureRecognizer?
    var transitioningController : TransitioningController?
    var detailVC : DetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        panGesture = UIPanGestureRecognizer()
        panGesture?.delegate = self
        panGesture?.addTarget(self, action: #selector(handlePanGesture(_:)))
        self.previewView.addGestureRecognizer(panGesture!)
        tapGesture = UITapGestureRecognizer()
        tapGesture?.addTarget(self, action: #selector(handleTapGesture(_:)))
        tapGesture?.delegate = self
        self.previewView.addGestureRecognizer(tapGesture!)
        self.bottomFrame = self.previewView.frame
        self.topFrame = CGRect.init(x: 0, y: 0, width: self.previewView.frame.width, height: self.previewView.frame.height)
        if let navigationBar = self.navigationController?.navigationBar {
            self.topFrame = CGRect.init(x: 0, y: navigationBar.frame.origin.y + navigationBar.frame.height, width: self.previewView.frame.width, height: self.previewView.frame.height)
        }
        
    
        detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewControllerID") as? DetailViewController;
        transitioningController = TransitioningController(panGesture: panGesture!, viewControllerToPresent: detailVC!)
        let frame = self.previewView.frame
        let scale = frame.width / self.view.frame.width
        let fromFrame = CGRect(origin: frame.origin, size: CGSize(width: scale*self.view.frame.width, height: scale*self.view.frame.height))
        transitioningController?.initialFrame = fromFrame
        
        
        self.title = "Master View"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTapGesture(_ tapGestureRecognizer : UITapGestureRecognizer) {
        print(tapGestureRecognizer)
        
        
//        let detailVC : DetailViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewControllerID") as! DetailViewController;
//        transitioningController = TransitioningController(panGesture: panGesture!, viewControllerToPresent: detailVC)
//        detailVC.transitioningDelegate = transitioningController
        self.present(detailVC!, animated: true) {}
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
        var endFrame : CGRect
        switch self.state {
            case .preview:
                endFrame = self.topFrame
//                let detailVC : DetailViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewControllerID") as! DetailViewController;
//                transitioningController = TransitioningController(panGesture: panGesture, viewControllerToPresent: detailVC)
//                let frame = self.previewView.frame
//                let scale = frame.width / self.view.frame.width
//                let fromFrame = CGRect(origin: frame.origin, size: CGSize(width: scale*self.view.frame.width, height: scale*self.view.frame.height))
//                transitioningController?.initialFrame = fromFrame
                self.present(detailVC!, animated: true) {}
            
            case .fullview:
                endFrame = self.bottomFrame
        }
    }
    
    func panningChanged (_ panGesture : UIPanGestureRecognizer) {
    }
    
    func panningEnded (_ panGesture : UIPanGestureRecognizer) {
    }
    
}

//MARK: UIGestureRecognizerDelegate
extension ViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        if (gestureRecognizer == tapGesture) {
            return true
        } else {
            return false
        }
    }
}






