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
    var transitioningController : TransitioningNavigationController?
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
//        transitioningController = TransitioningController(panGesture: panGesture!, viewControllerToPresent: detailVC!)
//        transitioningController = TransitioningController(panGesture: panGesture!, navigationController: self.navigationController!)
        transitioningController = TransitioningNavigationController(navigationController: self.navigationController!)
        let frame = self.previewView.frame
        let scale = frame.width / self.view.frame.width
        transitioningController?.transitionItemFromFrame = CGRect(origin: frame.origin, size: CGSize(width: scale*self.view.frame.width, height: scale*self.view.frame.height))
        transitioningController?.initiallyInteractive = true

        self.title = "Master View"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showDetailVC () {
        transitioningController?.initiallyInteractive = false
        self.navigationController?.pushViewController(detailVC!, animated: true)
    }
    
    
    func handleTapGesture(_ tapGestureRecognizer : UITapGestureRecognizer) {
        transitioningController?.initiallyInteractive = false
        self.present(detailVC!, animated: true, completion: nil)
    }

    func handlePanGesture (_ panGestureRecognizer : UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
                self.panningBegan(panGestureRecognizer)
        default:
            break
        }
        
    }
    
    func panningBegan (_ panGesture : UIPanGestureRecognizer) {
        transitioningController?.initiallyInteractive = true
//        self.present(detailVC!, animated: true) {}

//        self.navigationController?.pushViewController(detailVC!, animated: true)
    }
}

//MARK: UIGestureRecognizerDelegate
extension ViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer || (gestureRecognizer is UITapGestureRecognizer)) {
            return true
        } else {
            return false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == tapGesture && otherGestureRecognizer == panGesture) {
            return true
        } else if (gestureRecognizer == panGesture && otherGestureRecognizer == tapGesture) {
            return true
        } else {
            return false
        }
    }
}






