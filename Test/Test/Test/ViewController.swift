//
//  ViewController.swift
//  Test
//
//  Created by Shah, Hiral N on 9/19/19.
//  Copyright © 2019 Shah, Hiral N. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   
    @IBOutlet weak var Start: UIButton!
    
    @IBAction func Submit(_ sender: Any) { // user enter patient id and left and right hand store into variable
         
        
    }
    
    @IBAction func starttest_onClick(_ sender: Any) {
        let alertController:UIAlertController = UIAlertController(title: "Begin Test?", message: " Are you ready to begin the test. You will be timed for the duration for this test.(I expect the language of this to be changed ", preferredStyle: UIAlertController.Style.alert)
        
        // Create a UIAlertAction object, this object will add a button at alert dialog bottom, the button text is OK, when click it just close the alert dialog.
        let alertAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
        
        // Add alertAction object to alertController.
        alertController.addAction(alertAction)
        // Popup the alert dialog.
        present(alertController, animated: true, completion: nil)
    }
    
        
    @IBAction func start_procedure(_ sender: Any) {
        //performSegue(withIdentifier: "Start", sender:self)
        
    }
    
    @IBAction func About(_ sender: Any) {
        //performSegue(withIdentifier: "About", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func createMessage(title:String, message:String)
    {
       let alertController:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
}

