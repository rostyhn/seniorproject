//
//  ViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var btn_startTest: UIButton!
    
    @IBOutlet weak var btn_About: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func act_startTest(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Test", message: "The test will now begin.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Begin Test", style: .default, handler: {

            [unowned self] (action) -> Void in

            self.performSegue(withIdentifier: "to_Test", sender: self);
        })
        alertController.addAction(defaultAction)
        
        present(alertController, animated: false);
        

    }
    

    @IBAction func act_OpenAbout(_ sender: UIButton) {
        performSegue(withIdentifier: "to_AboutUs", sender: self)
        
    }
    

    
    
}

