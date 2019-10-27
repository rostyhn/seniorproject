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
    
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.navigationBar.isHidden = false
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
    
    override func loadView()
    {
        
    }
}

class SettingsUIView: UIView
{
    
}
