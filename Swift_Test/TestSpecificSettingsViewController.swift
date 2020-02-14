//
//  TestSpecificSettingsViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 11/4/19.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

import Foundation
import UIKit


struct TestParam {
    var label: String
    var endpoint: String
    var options: [Any]
    var jsonType: String
    var targetSetting: String
    init(label: String, endpoint: String, jsonType: String, targetSetting: String)
    {
        self.label = label;
        self.endpoint = endpoint;
        self.options = [];
        self.jsonType = jsonType;
        self.targetSetting = targetSetting;
        //to make it even more dynamic, add params that are dependent on this one
    }
}

//"more settings" view controller
class TestSpecificSettingsViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    var params = [TestParam]()
    var testBeingEdited: Locality?
    
    //MARK: On view open
    override func viewDidLoad() {
       
        self.view.backgroundColor = UIColor.white;
        
        switch(testBeingEdited!)
        {
        case .jolo:
            params.append(TestParam(label: "Test Version", endpoint: "data/getTestList", jsonType: "TestNamesFromJSON", targetSetting: "JOLOVersion"));
            break;
        case .cancellation:
            break;
        case .global:
            break;
        }
        
        var counter = 0;
        for i in 0...params.count-1 {
            //load the picker's options
            var param = params[i];
            let url = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000/" + param.endpoint);
            let jsonData = try? Data(contentsOf: url!, options: .mappedIfSafe)
            switch(param.jsonType)
            {
                case "TestNamesFromJSON":
                    let elements = try? JSONDecoder().decode(TestNamesFromJSON.self, from: jsonData!);
                    for element in elements!
                    {
                        //make more general later
                        param.options.append(element.name);
                    }
                    break;
                default:
                    break;
            }
            //create a label for the picker
            let newPickerLabel = UILabel();
            newPickerLabel.numberOfLines = 0;
            newPickerLabel.textColor = UIColor.black;
            newPickerLabel.text = param.label;
            newPickerLabel.frame = CGRect(x: 40, y: counter * 100 + 100, width: 1000, height:40);
            counter = counter + 1;
            newPickerLabel.font = UIFont(name: "Helvetica", size: 30.0);
            self.view.addSubview(newPickerLabel);
            
            //create the picker
            let newPicker = attributedPickerView()
            newPicker.center = CGPoint(x: Int(UIScreen.main.bounds.midX), y: counter * 100 + 100);
            newPicker.delegate = self;
            newPicker.dataSource = self;
            newPicker.setValue(UIColor.black, forKeyPath: "textColor")
            newPicker.targetParam = param;
            counter = counter + 1;

            self.view.addSubview(newPicker);

        }
            //load in the first test's possible targets
            
            /*let targetURL = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000" + "/data/download/" + firstTest)
            
            let targetJsonData = try? Data(contentsOf: targetURL!, options: .mappedIfSafe)
            
            let testData = try? JSONDecoder().decode(SymbolData.self, from: targetJsonData!)
            
            self.possibleTargets = testData!.possibleTargets
            self.picker_TargetSymbol.reloadAllComponents()*/
        
    }
    //MARK: Picker functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //MARK: Return number of components
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let thisView = pickerView as! attributedPickerView;
        return thisView.targetParam!.options.count;
    }
    
    //MARK: Return chosen component
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let thisView = pickerView as! attributedPickerView;
        UserDefaults.standard.set(thisView.targetParam!.options[row] as! String, forKey: thisView.targetParam!.targetSetting)
        
        return thisView.targetParam!.options[row] as! String;
        
    }
}
    
class attributedPickerView : UIPickerView {
    var targetParam: TestParam?
}
