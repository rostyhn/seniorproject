//
//  ResultsViewController.swift
//  Swift_Test
//
//  Created by Auriemma, Thomas Henry on 2/16/20.
//  Copyright © 2020 Rosty H. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class ResultsViewController : UIViewController {
    //will extend later if necessary 
    var testData: JOLOTest?
    let resultView = ResultView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup the scroll view
        resultView.frame = view.bounds
        resultView.contentSize = view.bounds.size
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        
        
        var counter = 0;
        //label for PatientID + V. of Test
        let patientIDLabel = UILabel()
        patientIDLabel.numberOfLines = 0;
        patientIDLabel.textColor = UIColor.black
        patientIDLabel.text = "Patient ID: " + String(testData!.patientID);
        patientIDLabel.font = UIFont(name: "Helvetica", size: 30.0);
        patientIDLabel.frame = CGRect(x: 40, y: counter * 100 + 50, width: 1000, height:40)
        resultView.addSubview(patientIDLabel);
        
        let testVersionLabel = UILabel()
        testVersionLabel.numberOfLines = 0;
        testVersionLabel.textColor = UIColor.black
        testVersionLabel.text = "Test Version: " + String(testData!.jsonName);
        testVersionLabel.font = UIFont(name: "Helvetica", size: 30.0);
        testVersionLabel.frame = CGRect(x: Int(UIScreen.main.bounds.midX), y: counter * 100 + 50, width: 1000, height:40)
        resultView.addSubview(testVersionLabel);
        resultView.contentSize = CGSize(width: resultView.contentSize.width, height: resultView.contentSize.height + 20)
        
        counter = counter + 1;
        
        for i in 0...testData!.responses.count-1 {
            var correctnessRect = CGRect();
            var currentBlockHeight = 0;
            correctnessRect.origin = CGPoint(x: 40, y: counter * 100 + 50);
            //write the stimuli expected answers
            let stimuliLabel = UILabel();
            stimuliLabel.numberOfLines = 0;
            stimuliLabel.textColor = UIColor.black
            stimuliLabel.text = "Expected Answers: ";
            
            var expected_answers = "";
            
            let mirror = Mirror(reflecting: testData!.stimuli![i])
            for child in mirror.children {
                if child.label!.contains("line") {
                    let val = (child.value as? Int)
                    if(val != nil)
                    {
                        expected_answers = expected_answers + String(val! + 1) + " ";
                    }
                }
            }
            stimuliLabel.text = stimuliLabel.text! + " " + expected_answers;
            stimuliLabel.font = UIFont(name: "Helvetica", size: 20.0);
            stimuliLabel.frame = CGRect(x: 40, y: counter * 100 + 50, width: 1000, height:40)
            resultView.addSubview(stimuliLabel);
            currentBlockHeight = currentBlockHeight + 40;
            
            
            var final_response = "";
            
            for responsePart in testData!.responses[i].responseDataList
            {
                //try to make this using a mirror instead of hard coding it
                let timeStampLabel = UILabel()
                timeStampLabel.numberOfLines = 0;
                timeStampLabel.textColor = UIColor.black;
                timeStampLabel.font = UIFont(name: "Helvetica", size: 20.0);
                timeStampLabel.text = "Time Stamp: " + String(responsePart.timestamp);
                timeStampLabel.frame = CGRect(x: Int(UIScreen.main.bounds.midX), y: counter * 100 + 50, width: 1000, height:40);
                resultView.addSubview(timeStampLabel);
                
                
                let patientResponse = UILabel()
                patientResponse.numberOfLines = 0;
                patientResponse.textColor = UIColor.black;
                patientResponse.font = UIFont(name: "Helvetica", size: 20.0);
                patientResponse.text = "Response part: " + responsePart.responsePart;
                patientResponse.frame = CGRect(x: Int(UIScreen.main.bounds.midX), y: counter * 100 + 75, width: 1000, height:40);
                resultView.addSubview(patientResponse);
                
                final_response = final_response + responsePart.responsePart + " ";
                
                let duration = UILabel()
                duration.numberOfLines = 0;
                duration.textColor = UIColor.black;
                duration.font = UIFont(name: "Helvetica", size: 20.0);
                duration.text = "Duration: " + String(responsePart.timestamp);
                duration.frame = CGRect(x: Int(UIScreen.main.bounds.midX), y: counter * 100 + 100, width: 1000, height:40);
                resultView.contentSize = CGSize(width: resultView.contentSize.width, height: resultView.contentSize.height + 20)
                resultView.addSubview(duration);
                currentBlockHeight = currentBlockHeight + 100;
                counter = counter + 1;
            }
        }
        
        //add return to main & print
        
        let btn_return = UIButton()
        btn_return.backgroundColor = UIColor.red
        btn_return.setTitle("Return back to main menu", for: .normal)
        btn_return.addTarget(self, action: #selector(returnHome), for: .touchUpInside)
        btn_return.frame = CGRect(x: 40, y: counter * 100 + 50, width: 200, height:40);
        resultView.addSubview(btn_return)
        
        
        /*let btn_print = UIButton()
        btn_print.backgroundColor = UIColor.red
        btn_print.setTitle("Print", for: .normal)
        btn_print.addTarget(self, action: #selector(printScreen), for: .touchUpInside)
        btn_print.frame = CGRect(x: Int(UIScreen.main.bounds.midX), y: counter * 100 + 75, width: 1000, height:40);*/
        
    
        resultView.contentSize = CGSize(width: resultView.contentSize.width, height: resultView.contentSize.height + 20)
        
        self.view = resultView;
        self.view.backgroundColor = UIColor.white
    }
    
    @objc func printScreen()
    {
        
    }
    
    @objc func returnHome(sender: UIButton!)
    {
        self.performSegue(withIdentifier: "to_Main", sender: sender);
    }
}

class ResultView: UIScrollView {
    
}



