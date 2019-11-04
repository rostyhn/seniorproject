//
//  ViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import UIKit
import MetalKit
import ModelIO

var patientID: String = ""

class ViewController: UIViewController {
    
    var mtkView: MTKView!
    var renderer: Renderer!
    
    @IBOutlet weak var btn_startTest: UIButton!
    
    @IBOutlet weak var btn_About: UIButton!
    
    @IBOutlet weak var btn_Settings: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mtkView = MTKView()
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.backgroundColor = UIColor.white
        mtkView.frame = CGRect(x:view.bounds.maxX/2 - 125,y:150, width:250, height:250)
        mtkView.clearColor = MTLClearColor.init(red: 255, green: 255, blue: 255, alpha: 1)
        view.addSubview(mtkView)
        let device = MTLCreateSystemDefaultDevice()
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
        
        
        renderer = Renderer(view: mtkView, device: device!)
        mtkView.delegate = renderer
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            
            let alertController = UIAlertController(title: "First Launch", message: "This is the first time the app has been opened. Please consider checking the settings page.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: false);

            UserDefaults.standard.set(false, forKey: "debugMode")
            UserDefaults.standard.set("192.168.1.1", forKey: "serverAddress")
            UserDefaults.standard.set("Alphabet_test", forKey: "testSelected")
            UserDefaults.standard.set("A", forKey: "targetSymbol")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set("123456789", forKey: "doctorID")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hides navigation bar everywhere
         self.navigationController?.navigationBar.isHidden = true
     }
    
    
    @IBAction func act_startTest(_ sender: UIButton) {
        
        let errorAlert = UIAlertController(title: "No ID entered", message: "Please enter a valid patient ID and try again.", preferredStyle: .alert)
        
        let errorAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        errorAlert.addAction(errorAction)
        
        let alert = UIAlertController(title: "Enter Patient ID", message: "Please enter the patient's ID.", preferredStyle: .alert)
        
        alert.addTextField { (textField) -> Void in
            textField.text = ""
        }
        
        let defaultAction = UIAlertAction(title: "Continue", style: .default, handler: {

            [unowned self] (action) -> Void in
            
            let textField = alert.textFields![0] as UITextField
            
            if(textField.text != "")
            {
                patientID = textField.text!
                self.performSegue(withIdentifier: "to_Questions", sender: self)
            }
            else
            {
                self.present(errorAlert, animated: true, completion: nil)
            }
        })
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func act_OpenAbout(_ sender: UIButton) {

        performSegue(withIdentifier: "to_AboutUs", sender: self)
    }
    
    @IBAction func act_openSettings(_ sender: Any) {
        //except when we open the settings menu
        self.navigationController?.navigationBar.isHidden = false
        performSegue(withIdentifier: "to_Settings", sender: self)
    }
    

    
}


