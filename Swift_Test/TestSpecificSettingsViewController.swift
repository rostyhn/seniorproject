//
//  TestSpecificSettingsViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 11/4/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation
import UIKit

class TestSpecificSettingsViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    var testNames: [String] = [String]()
    @IBOutlet weak var picker_TestName: UIPickerView!
    
    @IBOutlet weak var picker_TargetSymbol: UIPickerView!
    
    override func viewDidLoad() {
        
        picker_TestName.delegate = self
        picker_TestName.dataSource = self
        
        if(UserDefaults.standard.bool(forKey:"loadLocally"))
        {
            self.testNames = ["AlphabetTest", "SymbolTest"]
        }
        else
        {
            //implement loading from website
        }
        
        //implement loading in symbol list from website
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker_TestName
        {
            return testNames.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == picker_TestName
        {
            UserDefaults.standard.set(testNames[row], forKey: "testSelected")
            
            return testNames[row]
        }
        return ""
    }
    
    
    
    
}
