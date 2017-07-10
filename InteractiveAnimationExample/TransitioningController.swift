//
//  TransitioningController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/8/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit

class TransitioningController: NSObject {
    weak var navigationController : UINavigationController?
    var transitionOperation : UINavigationControllerOperation = .none
    
}


extension TransitioningController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionOperation = operation
        return self
    }

}

extension TransitioningController : UIViewControllerAnimatedTransitioning {


}
