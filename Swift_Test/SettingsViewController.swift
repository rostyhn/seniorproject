//
//  SettingsViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/23/19.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

import Foundation
import UIKit

enum UIType {
    case toggle, textfield
}

enum Locality: String, CaseIterable {
    case global = "Global"
    case cancellation = "Cancellation Test"
    case jolo = "Angle Matching Test"
}

struct Setting {
    let label : String
    let name : String
    let type : UIType
    let locality : Locality
    
    init(label: String, name: String, type: UIType, locality: Locality)
    {
        self.label = label;
        self.name = name;
        self.type = type;
        self.locality = locality;
    }
}

//settings view controller
class SettingsViewController: UIViewController
{
    let settings = [Setting(label: "Debug Mode", name: "debug_mode", type: UIType.toggle, locality: Locality.global),
                        Setting(label: "Show Questionnaire", name: "show_questionnaire", type: UIType.toggle, locality: Locality.global)];
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        var counter = 0;
        
        for locale in Locality.allCases {
            let currentLocaleLabel = UILabel();
            currentLocaleLabel.numberOfLines = 0;
            currentLocaleLabel.textColor = UIColor.black;
            currentLocaleLabel.text = locale.rawValue + " Settings";
            currentLocaleLabel.font = UIFont(name: "Helvetica", size: 30.0);
            currentLocaleLabel.frame = CGRect(x: 40, y: counter * 100 + 100, width: 1000, height:40);
            counter = counter + 1;
            self.view.addSubview(currentLocaleLabel);
            for setting in settings
            {
                if(setting.locality == locale)
                {
                    let currentSettingLabel = UILabel();
                    currentSettingLabel.numberOfLines = 0;
                    currentSettingLabel.textColor = UIColor.black;
                    currentSettingLabel.text = setting.label;
                    currentSettingLabel.font = UIFont(name: "Helvetica", size:  24.0);
                    currentSettingLabel.frame = CGRect(x: 40, y: counter * 100 + 100, width: 1000, height:40);
                    
                    switch(setting.type){
                    case .toggle:
                        let currentInteractable = ToggleButton();
                        currentInteractable.isOn = (UserDefaults.standard.bool(forKey: setting.name)) ? true : false;
                        //ooo nice and blue
                        currentInteractable.onTintColor = UIColor.blue;
                        currentInteractable.associatedVal = setting.name;
                        currentInteractable.frame = CGRect(x: Int(UIScreen.main.bounds.maxX - 100.0), y: counter * 100 + 100, width: 50, height: 40);
                        currentInteractable.addTarget(self, action: #selector(toggleSetting), for: .valueChanged);
                        self.view.addSubview(currentInteractable);
                        break;
                    case .textfield:
                        break;
                    }
                    self.view.addSubview(currentSettingLabel);
                    counter = counter + 1;
                }
            }
            //add button for specific settings if not global
            if(locale != .global)
            {
                let btn_TestSpecific = SegueButton();
                btn_TestSpecific.frame = CGRect(x: Int(UIScreen.main.bounds.midX) - 175, y: counter * 100 + 100, width: 350, height: 40);
                btn_TestSpecific.setTitleColor(UIColor.blue, for: .normal)
                btn_TestSpecific.setTitle("Change version of " + locale.rawValue.lowercased(), for: .normal);
                btn_TestSpecific.layer.cornerRadius = 9.0;
                btn_TestSpecific.layer.borderWidth = 0.8;
                btn_TestSpecific.associatedVal = locale;
                btn_TestSpecific.addTarget(self, action: #selector(segueToTestSpecificSettings), for: .touchUpInside);
                self.view.addSubview(btn_TestSpecific);
                counter = counter + 1;
            }
        }
    }
    
    @objc func segueToTestSpecificSettings(sender: SegueButton)
    {
        self.performSegue(withIdentifier: "to_TestSpecificSettings", sender: sender.associatedVal!)
    }
    
    @objc func toggleSetting(sender: ToggleButton!)
    {
        (sender.isOn) ? UserDefaults.standard.set(true, forKey: sender.associatedVal!) : UserDefaults.standard.set(false, forKey: sender.associatedVal!);
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_TestSpecificSettings"
        {
            if let testViewController = segue.destination as? TestSpecificSettingsViewController {
               testViewController.testBeingEdited = sender as? Locality;
            }
        }
    }
}

class SettingsUIView: UIView
{
    
}

class SegueButton: UIButton {
    var associatedVal : Locality?
}

class ToggleButton: UISwitch {
    var associatedVal : String?
}
