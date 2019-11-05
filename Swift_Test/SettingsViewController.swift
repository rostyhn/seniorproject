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
    var isConnectionSafe = false
    
    @IBOutlet weak var serverNameTextField: UITextField!
    @IBOutlet weak var doctorIDTextField: UITextField!
    @IBOutlet weak var toggle_Debug: UISwitch!
    @IBOutlet weak var toggle_LoadLocally: UISwitch!
    @IBOutlet weak var segueToTestSettings: UIButton!
    @IBOutlet weak var toggle_Questionnaire: UISwitch!
    
    @IBAction func f_toggle_LoadLocally(sender: UISwitch)
    {
        if(sender.isOn)
        {
            UserDefaults.standard.set(true, forKey: "loadLocally")
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "loadLocally")
        }
    }
    
    @IBAction func f_toggle_Questionnaire(_ sender: UISwitch) {
        
        if(sender.isOn)
        {
            UserDefaults.standard.set(true, forKey: "showQuestionnaire")
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "showQuestionnaire")
        }
    }
    @IBAction func change_DoctorID(_ sender: UITextField) {
        //query database if doctor exists
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
    
    @IBAction func f_segueToTestSettings(sender: UIButton)
    {
        //load test settings page
        self.performSegue(withIdentifier: "to_TestSettings", sender: self)
    }
    
    @IBAction func change_ServerName(_ sender: UITextField) {
        self.view.showBlurLoader()
        guard let url = URL(string: "http://" + sender.text! + ":5000") else { return }

               var request = URLRequest(url: url)
               request.timeoutInterval = 3.0

               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   if let error = error {
                       print("\(error.localizedDescription)")
                    self.showConnectionError(title:"Unable to connect to server", message: "Check the server address you entered and try again.")

                   }
                   if let httpResponse = response as? HTTPURLResponse {
                       print("statusCode: \(httpResponse.statusCode)")
                        UserDefaults.standard.set(sender.text,forKey: "serverAddress")
                            self.prepareTestSettingsPage()

                   }
               }
               task.resume()
        }
    
    func prepareTestSettingsPage()
    {
        DispatchQueue.main.async {
            self.view.removeBlurLoader()
            UserDefaults.standard.set(true, forKey: "isConnectionSafe")
            self.segueToTestSettings.isHidden = false
            let alert = UIAlertController(title: "Connection successful", message: "Check the more settings page for advanced test administration options.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    func showConnectionError(title: String, message: String)
    {
        DispatchQueue.main.async {
            //reset everything
            UserDefaults.standard.set(false, forKey: "isConnectionSafe")
            self.serverNameTextField.text = UserDefaults.standard.string(forKey: "serverAddress")
            self.view.removeBlurLoader()
            self.segueToTestSettings.isHidden = true
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
        self.present(alert, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.segueToTestSettings.isHidden = UserDefaults.standard.bool(forKey: "isConnectionSafe") == true ? false : true
        
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
        if(UserDefaults.standard.bool(forKey: "loadLocally"))
        {
           toggle_LoadLocally.setOn(true, animated: true)
        }
        else
        {
            toggle_LoadLocally.setOn(false, animated: true)
        }
        if(UserDefaults.standard.bool(forKey: "showQuestionnaire"))
        {
             toggle_Questionnaire.setOn(true, animated: true)
        }
        else
        {
            toggle_Questionnaire.setOn(false, animated: true)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}

class SettingsUIView: UIView
{
    
}
