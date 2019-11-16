//
//  SettingsViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/23/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation
import UIKit

//settings view controller
class SettingsViewController: UIViewController
{
    @IBOutlet weak var serverNameTextField: UITextField!
    @IBOutlet weak var doctorIDTextField: UITextField!
    @IBOutlet weak var toggle_Debug: UISwitch!
    @IBOutlet weak var toggle_LoadLocally: UISwitch!
    @IBOutlet weak var segueToTestSettings: UIButton!
    @IBOutlet weak var toggle_Questionnaire: UISwitch!
    
    // MARK: Toggle loading locally
    
    @IBAction func f_toggle_LoadLocally(sender: UISwitch)
    {
        (sender.isOn) ? UserDefaults.standard.set(true, forKey: "loadLocally") : UserDefaults.standard.set(false, forKey: "loadLocally")
    }
    
    // MARK: Toggle questionnaire
    
    @IBAction func f_toggle_Questionnaire(_ sender: UISwitch)
    {
        (sender.isOn) ? UserDefaults.standard.set(true, forKey: "showQuestionnaire") : UserDefaults.standard.set(false, forKey: "showQuestionnaire")
    }
    
    // MARK: Toggle debug mode
    
    @IBAction func f_toggle_Debug(_ sender: UISwitch) {
        (sender.isOn) ? UserDefaults.standard.set(true, forKey: "debugMode") : UserDefaults.standard.set(false, forKey: "debugMode")
    }
    
    // MARK: Change Doctor ID
    
    @IBAction func change_DoctorID(_ sender: UITextField) {
        //query database if doctor exists - could create a doctor ID lookup
        var isCorrect = false
        self.view.showBlurLoader()
        let url = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000/data/download/getDoctorList")!
        
        var request = URLRequest(url: url)
         request.timeoutInterval = 3.0

         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             if let error = error {
                 print("\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showConnectionError(title:"Unable to connect to server", message: "Check the server address you entered and try again.")
                }
             }
             if let httpResponse = response as? HTTPURLResponse {
                 print("statusCode: \(httpResponse.statusCode)")
                 let jsonData = try? Data(contentsOf: url, options: .mappedIfSafe)
                 
                 let doctorNames = try? JSONDecoder().decode(DoctorNames.self, from: jsonData!)
                 
                 DispatchQueue.main.async {
                 for doctor in doctorNames!
                 {
                     if(doctor.DoctorID == Int(sender.text!))
                     {
                         let alert = UIAlertController(title: "Doctor ID Changed", message: "Welcome, " + doctor.DoctorName + ".", preferredStyle: .alert)
                         let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                         alert.addAction(action)
                         self.present(alert, animated: true, completion: nil)
                         UserDefaults.standard.set(sender.text, forKey: "doctorID")
                         isCorrect = true
                         self.view.removeBlurLoader()
                         return
                     }
                 }
                 if(!isCorrect)
                 {
                     let alert = UIAlertController(title: "Doctor ID not found", message: "Check the ID you entered and try again.", preferredStyle: .alert)
                     let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                     alert.addAction(action)
                     self.view.removeBlurLoader()
                     self.present(alert, animated: true, completion: nil)
                 }
                }
             }
         }
         task.resume()
    }
    
    // MARK: Change Server Address
    
    @IBAction func change_ServerName(_ sender: UITextField) {
        self.view.showBlurLoader()
        guard let url = URL(string: "http://" + sender.text! + ":5000/data/testConnection") else { return }

               var request = URLRequest(url: url)
               request.timeoutInterval = 3.0

               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   if let error = error {
                       print("\(error.localizedDescription)")
                    self.showConnectionError(title:"Unable to connect to server", message: "Check the server address you entered and try again.")
                   }
                   if let httpResponse = response as? HTTPURLResponse {
                       print("statusCode: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                            self.prepareTestSettingsPage(text: sender.text!)
                        }
                   }
               }
               task.resume()
    }
    
    // MARK: Open more settings page

    @IBAction func f_segueToTestSettings(sender: UIButton)
    {
        self.view.showBlurLoader()
        //load test settings page if connection exists
        guard let url = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000/data/testConnection") else { return }

               var request = URLRequest(url: url)
               request.timeoutInterval = 3.0

               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   if let error = error {
                       print("\(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.view.showBlurLoader()
                    self.showConnectionError(title:"Unable to connect to server", message: "Check the server address you entered and try again.")
                    }
                   }
                   if let httpResponse = response as? HTTPURLResponse {
                       print("statusCode: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                            self.view.removeBlurLoader()
                           self.performSegue(withIdentifier: "to_TestSettings", sender: self)
                        }
                   }
               }
               task.resume()
    }

    // MARK: UI Utility Functions
    
    func prepareTestSettingsPage(text: String)
    {
            self.view.removeBlurLoader()
            self.doctorIDTextField.isUserInteractionEnabled = true
            UserDefaults.standard.set(true, forKey: "isConnectionSafe")
            UserDefaults.standard.set(text,forKey: "serverAddress")
            self.segueToTestSettings.isHidden = false
            let alert = UIAlertController(title: "Connection successful", message: "Check the more settings page for advanced test administration options.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
            self.present(alert, animated: true)
    }
    
    func showConnectionError(title: String, message: String)
    {
        DispatchQueue.main.async {
            //reset everything
            UserDefaults.standard.set(false, forKey: "isConnectionSafe")
            UserDefaults.standard.set("", forKey: "doctorID")
            self.doctorIDTextField.text = ""
            self.doctorIDTextField.isUserInteractionEnabled = false
            self.view.removeBlurLoader()
            self.segueToTestSettings.isHidden = true
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
        self.present(alert, animated: true)
        }
    }
    
    //MARK: On view open
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.segueToTestSettings.isHidden = UserDefaults.standard.bool(forKey: "isConnectionSafe") == true ? false : true
        self.doctorIDTextField.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "isConnectionSafe") == true ? true: false
        serverNameTextField.text = UserDefaults.standard.string(forKey: "serverAddress")
        doctorIDTextField.text = UserDefaults.standard.string(forKey: "doctorID")
        
        (UserDefaults.standard.bool(forKey: "debugMode")) ? toggle_Debug.setOn(true, animated: true) : toggle_Debug.setOn(false, animated: true)
        
        (UserDefaults.standard.bool(forKey: "loadLocally")) ? toggle_LoadLocally.setOn(true, animated: true) : toggle_LoadLocally.setOn(false, animated: true)
        
        (UserDefaults.standard.bool(forKey: "showQuestionnaire")) ? toggle_Questionnaire.setOn(true, animated: true) : toggle_Questionnaire.setOn(false, animated: true)
    }
}

class SettingsUIView: UIView
{
    
}
