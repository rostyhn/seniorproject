//
//  JOLOTest.swift
//  Swift_Test
//
//  Created by Auriemma, Thomas Henry on 1/27/20.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

struct Line: Codable {
    var id: Int
    var point1: CGPoint
    var point2: CGPoint
}

struct Response: Codable {
    var responseDataList: [ResponseData]
    
    init(responseDataList: [ResponseData])
    {
        self.responseDataList = responseDataList
    }
}

struct ResponseData : Codable {
    // stuff that's in the segment
    var responsePart: String
    var timestamp: TimeInterval
    var confidence: Float
    var duration: TimeInterval

    
    init(responsePart: String, timestamp: TimeInterval, confidence: Float, duration: TimeInterval)
    {
        self.responsePart = responsePart;
        self.timestamp = timestamp;
        self.confidence = confidence;
        self.duration = duration;
    }
}


struct Stimulus: Codable {
    var stimuliID: Int
    var line1: Int?
    var line2: Int?
    var line3: Int?
    var line4: Int?
    var offX: CGFloat
    var offY: CGFloat
    var scalar: CGFloat
}

typealias Stimuli = [Stimulus]

class JOLOTest: Codable {
    var testStartTime: Date
    var testEndTime: Date?
    var patientID: String
    var doctorID: String
    //var patientAnswers: [Response]
    var stimuli: [Stimulus]?
    var exampleLines: [Line]?
    var responses: [Response]
    
    
    init(patientID: String, bounds: CGRect)
    {
        self.testStartTime = Date();
        self.patientID = patientID;
        self.doctorID = "123456789";
        self.responses = []
        self.exampleLines = populateLines(midX: bounds.midX, maxY: bounds.maxY);
        let serverAddress = "http://" + (UserDefaults.standard.string(forKey:"serverAddress")!) + ":5000"
        let url = URL(string: serverAddress + "/data/getStimuli")
        let jsonData = try? Data(contentsOf: url!, options: .mappedIfSafe)

        self.stimuli = try? JSONDecoder().decode(Stimuli.self, from: jsonData!)
        
    }
    func populateLines(midX: CGFloat, maxY: CGFloat) -> [Line]
    {

        let botY = maxY - 50;
        var lines = [Line]()
        
        let center = CGPoint(x: 510, y: 1320)
        let startAngle: CGFloat = .pi
        let endAngle: CGFloat = 0
        let innerCircle = BezierPath(arcCenter: center,
                                radius: 40.0 - 1.5,
                               startAngle: startAngle,
                                 endAngle: endAngle,
                                clockwise: true)
        let outerCircle = BezierPath(arcCenter: center,
                                radius: 175 - 1.5,
                               startAngle: startAngle,
                                 endAngle: endAngle,
                                clockwise: true)
        
        innerCircle.lineWidth = 1.5
        
        //remove duplicates - the top of the arc was in the set twice
        innerCircle.generateLookupTable();
        outerCircle.generateLookupTable();
        
        let startPoints = Array(NSOrderedSet(array: innerCircle.lookupTable))
        let endPoints = Array(NSOrderedSet(array: outerCircle.lookupTable))
        
        for i in 0...startPoints.count-1 {
            

                lines.append(Line(id: (i),  point1: startPoints[i] as! CGPoint, point2: endPoints[i] as! CGPoint));
            
        }
        return lines;
    }
    
}
