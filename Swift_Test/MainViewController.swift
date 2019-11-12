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

class MainViewController: UIViewController {
    
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
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        
        renderer = Renderer(view: mtkView, device: device!, mode: 0)
        mtkView.delegate = renderer
        
        //first time settings set up
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            
            let alertController = UIAlertController(title: "First Launch", message: "This is the first time the app has been opened. Please consider checking the settings page.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: false);

            UserDefaults.standard.set(false, forKey: "debugMode")
            UserDefaults.standard.set("192.168.1.1", forKey: "serverAddress")
            UserDefaults.standard.set("AlphabetTest", forKey: "testSelected")
            UserDefaults.standard.set("A", forKey: "targetSymbol")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set("123456789", forKey: "doctorID")
            UserDefaults.standard.set(true, forKey: "loadLocally")
            //if it loaded in the settings screen, we'll assume that the connection is working
            UserDefaults.standard.set(false, forKey: "isConnectionSafe")
            UserDefaults.standard.set(true, forKey: "showQuestionnaire")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hides navigation bar everywhere
         self.navigationController?.navigationBar.isHidden = true
     }
    
    
    @IBAction func act_startTest(_ sender: UIButton) {
        
        if(UserDefaults.standard.string(forKey: "doctorID")! != "")
        {
        
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
                //bad because it assumes that the connection is safe from previous loads...
                if(UserDefaults.standard.value(forKey: "isConnectionSafe") as! Bool)
                    {
                        if(UserDefaults.standard.value(forKey: "showQuestionnaire") as! Bool)
                        {
                            self.performSegue(withIdentifier: "to_Questions", sender: self)
                        }
                        else
                        {
                            self.performSegue(withIdentifier: "to_Test", sender: self)
                        }
                    }
                    else
                    {
                        self.showAlert(title: "Connection error", message: "The connection specified in the settings menu is potentially unsafe. Please change the server address and try again.")
                    }
                }
                else
                {
                    self.showAlert(title: "No ID entered", message: "Please enter a valid patient ID and try again.")
                }
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            showAlert(title: "No doctor ID entered.", message: "Please enter a valid doctor ID and try again.")
        }
        
    }
    
    func showAlert(title: String, message: String)
    {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let errorAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        errorAlert.addAction(errorAction)
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func act_OpenAbout(_ sender: UIButton) {
        
         let alert = UIAlertController(title: "Instructions", message: "Double tap to exit the about screen.", preferredStyle: .alert)
         
        let action = UIAlertAction(title: "OK", style: .default, handler: { [unowned self] (action) -> Void in
            self.performSegue(withIdentifier: "to_AboutUs", sender: self)
            
        })
         
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    @IBAction func act_openSettings(_ sender: Any) {
        //except when we open the settings menu
        self.navigationController?.navigationBar.isHidden = false
        performSegue(withIdentifier: "to_Settings", sender: self)
    }
    

    
}


