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
    
    @IBOutlet weak var btn_Settings: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func act_startTest(_ sender: UIButton) {
        performSegue(withIdentifier: "to_Questions", sender: self);
    }
    

    @IBAction func act_OpenAbout(_ sender: UIButton) {
        performSegue(withIdentifier: "to_AboutUs", sender: self)
    }
    
    @IBAction func act_openSettings(_ sender: Any) {
        //performSegue(withIdentifier: "to_Settings", sender: self)
    }
    
    
    
}

