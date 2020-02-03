//
//  TestSpecificSettingsViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 11/4/19.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

import Foundation
import UIKit

//"more settings" view controller
class TestSpecificSettingsViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    var testNames: [String] = [String]()
    var possibleTargets: [String] = [String]()
    @IBOutlet weak var picker_TestName: UIPickerView!
    @IBOutlet weak var picker_TargetSymbol: UIPickerView!
    
    //MARK: On view open
    override func viewDidLoad() {
        
        picker_TestName.delegate = self
        picker_TestName.dataSource = self
        picker_TargetSymbol.delegate = self
        picker_TargetSymbol.dataSource = self
        
        //MARK: If load locally
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
        //MARK: If load from server
        else
        {
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
    //MARK: Picker functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //MARK: Return number of components
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerView == picker_TestName) ? testNames.count : possibleTargets.count
    }
    
    //MARK: Return chosen component
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
        }
        else
        {
            //set to target symbol
            UserDefaults.standard.set(possibleTargets[row], forKey: "targetSymbol")
        }
        return (pickerView == picker_TestName) ? testNames[row] : possibleTargets[row]
    }
}
