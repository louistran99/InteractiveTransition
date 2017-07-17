//
//  DetailViewController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/7/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit

protocol DetialViewControlerDelegate : NSObjectProtocol {
    func panGestureDidPan(_ panGesture: UIPanGestureRecognizer)
}

class DetailViewController: UIViewController {
    
    @IBOutlet var previewView : UIView!
    weak var transitioningController : TransitioningController?
    weak var delegate : DetialViewControlerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        previewView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleTapGesture(_:)))
        previewView.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
        self.title = "Detail View"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTapGesture (_ tapGesture: UITapGestureRecognizer) {
        transitioningController?.initiallyInteractive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func handlePanGesture (_ panGesture: UIPanGestureRecognizer) {
        transitioningController?.initiallyInteractive = true
        self.dismiss(animated: true, completion: nil)
        if let value = delegate {
            value.panGestureDidPan(panGesture)
        }        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
