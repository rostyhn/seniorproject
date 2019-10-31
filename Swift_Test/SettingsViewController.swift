//
//  SettingsViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/23/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var serverNameTextField: UITextField!
    
    @IBOutlet weak var doctorIDTextField: UITextField!
    @IBOutlet weak var toggle_Debug: UISwitch!
    
    @IBAction func change_DoctorID(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "doctorID")
    }
    @IBAction func f_toggle_Debug(_ sender: UISwitch) {
        if(sender.isOn)
        {
            UserDefaults.standard.set(true, forKey: "debugMode")
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "debugMode")
        }
    }
    
    @IBAction func change_ServerName(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text,forKey: "serverAddress")
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.navigationBar.isHidden = false
        
        //need to add error checking for both fields
        serverNameTextField.text = UserDefaults.standard.string(forKey: "serverAddress")
        
        doctorIDTextField.text = UserDefaults.standard.string(forKey: "doctorID")
        
        if(UserDefaults.standard.bool(forKey: "debugMode"))
        {
            //if true, switch should be on
            toggle_Debug.setOn(true, animated: true)
        }
        else
        {
            toggle_Debug.setOn(false, animated: true)
        }
        
        
        
     }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //connect to server and check if it works;
        //if not warn user and try again when a new address is typed in
        //then load in tests and data
        
        
        /*let url = URL(string: "http://192.168.1.76:5000/data/get_test_list")
        let jsonData = try? Data(contentsOf: url!, options: .mappedIfSafe);
        
        //debug - gives you the string of data read in
        var rawData = String(decoding: jsonData!, as: UTF8.self);
        print(rawData)
        
        
        let testlist = try? JSONDecoder().decode(QuestionData.self, from: jsonData!);
        */
        
        
        
    }
}

class SettingsUIView: UIView
{
    
}
