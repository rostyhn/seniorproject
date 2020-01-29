//
//  TestObj.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/2/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit


//horrible name, but this serves as the top layer for the json object
//loaded into memory, contains an array of symbols
//MARK: SymbolData
struct SymbolData: Codable {
    let isTextual: Bool
    let symbols: [Symbol]
    let possibleTargets: [String]
}


// MARK: - Symbol
struct Symbol: Codable, Hashable {
    let name: String
    let x, y: Int
    let id: Int
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case name, x, y
        case id = "ID"
    }
}
// MARK: TouchData
struct TouchData: Codable, Hashable {
    //set of points that were drawn while touching - NOT UITouch
    var x,y,force,altitudeAngle,azimuthAngle: CGFloat
    //Xcode complained that DispatchTime was not hashable so I'll just include the uint instead
    var time: TimeInterval
    
    init(x: CGFloat, y: CGFloat, force: CGFloat, time: TimeInterval, altitudeAngle: CGFloat, azimuthAngle: CGFloat)
    {
        self.x = x;
        self.y = y;
        self.force = force;
        self.time = time;
        self.altitudeAngle = altitudeAngle;
        self.azimuthAngle = azimuthAngle;
    }
    
    enum CodingKeys: String, CodingKey {
        case x,y,force,time, altitudeAngle,azimuthAngle
    }
    
}
//MARK: Test object
class CancellationTest : Codable
{
    var testName: String
    //date will be converted to int; seconds since JAN 1, 2001 00:00
    var testStartTime: Date
    var testEndTime: Date?
    var isTextual: Bool;
    var answerSymbol: String;
    var symbols: [Symbol];
    var patientID: String
    var doctorID: String
    //two seperate arrays so that order is preserved - a dictionary is unordered
    var patientAnswers: [Symbol]
    var patientAnswerTouchData: Array<Array<TouchData>>
    let bBoxWidth = 25;
    let bBoxHeight = 25;
    
    //MARK: Init
    init(jsonName: String, patientID: String)
    {
        self.doctorID = UserDefaults.standard.string(forKey: "doctorID")!
        self.testName = jsonName
        self.answerSymbol = UserDefaults.standard.string(forKey: "targetSymbol")!
        self.patientID = patientID
        self.patientAnswers = []
        self.patientAnswerTouchData = []
        //Date() is the time right now in UTC; in the upload function I convert it to the timezone the iPad is in
        self.testStartTime = Date()
        //MARK: If load locally
        if(UserDefaults.standard.bool(forKey: "loadLocally"))
        {
            let path = Bundle.main.path(forResource: jsonName, ofType: "json")!
            
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            
            //debug - gives you the string of data read in
            //var rawData = String(decoding: jsonData!, as: UTF8.self);
            
            let symbolData = try? JSONDecoder().decode(SymbolData.self, from: jsonData!)
            
            self.symbols = symbolData!.symbols
            self.isTextual = symbolData!.isTextual
        }
        //MARK: If load from server
        else
        {
            let targetURL = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000" + "/data/download/" + UserDefaults.standard.string(forKey: "testSelected")!)
            
            let targetJsonData = try? Data(contentsOf: targetURL!, options: .mappedIfSafe)
            
            let symbolData = try? JSONDecoder().decode(SymbolData.self, from: targetJsonData!)
            
            self.symbols = symbolData!.symbols
            self.isTextual = symbolData!.isTextual
        }
    }
    
    //MARK: Set end time
    func setTestEndTime()
    {
        self.testEndTime = Date()
    }
    
    //MARK: Render symbols
    func draw(context:CGContext)
    {
        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.boldSystemFont(ofSize: 20.0),
            .foregroundColor: UIColor.black]
        
        //MARK: If test is textual
        if(isTextual)
        {
            /*use names of symbols instead of image files
              saves the annoyance of having to create a lot of seperate
              bitmap files for symbols might also be nice for debugging*/
            
            for symbol in symbols
            {
                let symText = symbol.name
                let attributedString = NSAttributedString(string: symText, attributes: attributes)
                
                let stringRect = CGRect(x: symbol.x, y: symbol.y, width: bBoxWidth, height: bBoxHeight)
                attributedString.draw(in: stringRect)
                
                if(UserDefaults.standard.bool(forKey: "debugMode"))
                {
                    context.beginPath()
                    context.stroke(stringRect)
                }
            }
        }
        //MARK: If test is graphical
        else
        {
            for symbol in symbols
                       {
                        let imgRect = CGRect(x: symbol.x, y: symbol.y, width: bBoxWidth, height: bBoxHeight)
                        
                        let path = Bundle.main.path(forResource: symbol.name, ofType: "PNG", inDirectory: "res")!
                        
                        let image = UIImage.init(data: try! Data(contentsOf: URL(fileURLWithPath: path)))
                        
                        image?.draw(in: imgRect)
                        
                           if(UserDefaults.standard.bool(forKey: "debugMode"))
                           {
                            //for bounding box rendering
                               context.beginPath()
                               context.stroke(imgRect)
                           }
                       }
        }
    }
    
}
