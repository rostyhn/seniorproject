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
    var possibleTargets: [String] = [String]()
    @IBOutlet weak var picker_TestName: UIPickerView!
    
    @IBOutlet weak var picker_TargetSymbol: UIPickerView!
    
    override func viewDidLoad() {
        
        picker_TestName.delegate = self
        picker_TestName.dataSource = self
        
        picker_TargetSymbol.delegate = self
        picker_TargetSymbol.dataSource = self
        
        if(UserDefaults.standard.bool(forKey:"loadLocally"))
        {
            self.testNames = ["AlphabetTest", "SymbolTest"]
            
            //load the first test's targets
            
            let path = Bundle.main.path(forResource: "AlphabetTest", ofType: "json")!
            
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            
            //debug - gives you the string of data read in
            //var rawData = String(decoding: jsonData!, as: UTF8.self);
            
            let testData = try? JSONDecoder().decode(SymbolData.self, from: jsonData!)
            
            self.possibleTargets = testData!.possibleTargets
            self.picker_TargetSymbol.reloadAllComponents()
            
        }
        else
        {
            // /data/getTestList
            // /data/download/<name>.json
            let url = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000" + "/data/download/getTestList")
            
            let jsonData = try? Data(contentsOf: url!, options: .mappedIfSafe)
            
            let testNamesFromJSON = try? JSONDecoder().decode(TestNamesFromJSON.self, from: jsonData!)
            
            let firstTest = testNamesFromJSON!.first!.name
            
            for element in testNamesFromJSON!
            {
                self.testNames.append(element.name)
            }
            
            //load in the first test's possible targets
            
            let targetURL = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000" + "/data/download/" + firstTest)
            
            let targetJsonData = try? Data(contentsOf: targetURL!, options: .mappedIfSafe)
            
            let testData = try? JSONDecoder().decode(SymbolData.self, from: targetJsonData!)
            
            self.possibleTargets = testData!.possibleTargets
            self.picker_TargetSymbol.reloadAllComponents()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker_TestName
        {
            return testNames.count
        }
        else
        {
            return possibleTargets.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == picker_TestName
        {
            UserDefaults.standard.set(testNames[row], forKey: "testSelected")
            
            if(!UserDefaults.standard.bool(forKey: "loadLocally"))
            {
                //make sure to pull the correct symbol list from the server
                let targetURL = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000" + "/data/download/" + testNames[row])
                
                let targetJsonData = try? Data(contentsOf: targetURL!, options: .mappedIfSafe)
                
                let testData = try? JSONDecoder().decode(SymbolData.self, from: targetJsonData!)
                
                self.possibleTargets = testData!.possibleTargets
                self.picker_TargetSymbol.reloadAllComponents()
            }
            else
            {
                //load the file in locally and grab the data
                let path = Bundle.main.path(forResource: testNames[row], ofType: "json")!
                
                let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                //debug - gives you the string of data read in
                //var rawData = String(decoding: jsonData!, as: UTF8.self);
                
                let testData = try? JSONDecoder().decode(SymbolData.self, from: jsonData!)
                
                self.possibleTargets = testData!.possibleTargets
                self.picker_TargetSymbol.reloadAllComponents()
            }
            
            return testNames[row]
        }
        else
        {
            //set to target symbol
            UserDefaults.standard.set(possibleTargets[row], forKey: "targetSymbol")
            return possibleTargets[row]
        }
        return ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //figure out how to display this alert on close
        /*
        let closingAlert = UIAlertController(title: "Test settings set!", message: "Test selected: " + UserDefaults.standard.string(forKey: "testSelected")! + "\n Target symbol selected:" + UserDefaults.standard.string(forKey: "targetSymbol")!, preferredStyle: .alert)
        
        let closingAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        closingAlert.addAction(closingAction)
        self.present(closingAlert, animated: true, completion: nil)
        */
    }
}
