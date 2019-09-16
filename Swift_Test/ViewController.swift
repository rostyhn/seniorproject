//
//  ViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import UIKit

//custom button code 
@IBDesignable class RoundButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        refreshCorners(value: cornerRadius)
    }
    
    func refreshCorners(value: CGFloat){
        layer.cornerRadius = value
    }
    
    @IBInspectable
         var cornerRadius: CGFloat = 15.0 {
            didSet {
                refreshCorners(value: cornerRadius)
            }
        }
    
}

class ViewController: UIViewController {
    @IBOutlet weak var btn_startTest: UIButton!
    
    @IBOutlet weak var btn_About: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func act_startTest(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Test", message: "The test will now begin.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Begin Test", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        performSegue(withIdentifier: "to_Test", sender: self)
    }
    

    @IBAction func act_OpenAbout(_ sender: UIButton) {
        performSegue(withIdentifier: "to_AboutUs", sender: self)
        
    }
    

    
    
}

