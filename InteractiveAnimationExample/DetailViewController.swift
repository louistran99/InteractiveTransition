//
//  DetailViewController.swift
//  InteractiveAnimationExample
//
//  Created by Louis Tran on 7/7/17.
//  Copyright © 2017 IF. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var previewView : UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
        self.title = "Detail View"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTapGesture (_ tapGesture : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
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
