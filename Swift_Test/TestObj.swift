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
struct SymbolData: Codable {
    let symbols: [Symbol]
}


// MARK: - Symbol
struct Symbol: Codable, Hashable {
    let name: String
    let x, y: Int
    let imgPath: String
    let id: Int
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case name, x, y, imgPath
        case id = "ID"
    }
}

struct TouchData: Codable, Hashable {
    //set of points that were drawn while touching - NOT UITouch
    var x,y,force: CGFloat
    //Xcode complained that DispatchTime was not hashable so I'll just include the uint instead
    var time: dispatch_time_t
    
    init(x: CGFloat, y: CGFloat, force: CGFloat, time:dispatch_time_t)
    {
        self.x = x;
        self.y = y;
        self.force = force;
        self.time = time;
    }
    
    enum CodingKeys: String, CodingKey {
        case x,y,force,time
    }
    
}

class Test : Codable
{
    var testName: String
    var testStartTime: dispatch_time_t
    var testEndTime: dispatch_time_t
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
    
    init(testName:String,isTextual:Bool, jsonName: String, answerSymbol: String, patientID: String)
    {
        self.doctorID = UserDefaults.standard.string(forKey: "doctorID")!
        self.testName = testName
        self.isTextual = isTextual;
        self.answerSymbol = answerSymbol;
        self.patientID = patientID
        patientAnswers = [];
        patientAnswerTouchData = [];
        //data: try Data(contentsOf: url)
        self.testStartTime = DispatchTime.now().rawValue
        self.testEndTime = 0;
        //TODO: add functionality to read from the server
        let path = Bundle.main.path(forResource: jsonName, ofType: "json")!
        
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe);
        
        //debug - gives you the string of data read in
        //var rawData = String(decoding: jsonData!, as: UTF8.self);
        
        let symbolData = try? JSONDecoder().decode(SymbolData.self, from: jsonData!);
        
        symbols = symbolData!.symbols;
        
    }
    
    func setTestEndTime(testEndTime: dispatch_time_t)
    {
        self.testEndTime = testEndTime
    }
    
    func draw(context:CGContext)
    {
        
        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center
        
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.boldSystemFont(ofSize: 20.0),
            .foregroundColor: UIColor.black
            
        ]
        
        if(isTextual)
        {
            /*use names of symbols instead of image files
              saves the annoyance of having to create a lot of seperate
              bitmap files for symbols might also be nice for debugging*/
            
            for symbol in symbols
            {
                let symText = symbol.name;
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
        else
        {
            //add functionality to draw symbols that are images here
        }
    }
    
}
