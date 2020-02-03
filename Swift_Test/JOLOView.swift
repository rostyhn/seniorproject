//
//  JOLOView.swift
//  Swift_Test
//
//  Created by Auriemma, Thomas Henry on 1/27/20.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import AVFoundation

class JOLOView: UIView {
    // weak var can be deallocated from memory
    // Remember to attach ! to view controller so it gets unpacked
    weak var vc: TestViewController!
    var test: JOLOTest!
    var count: Int = 0;
    var pathLayer: CAShapeLayer!
    var stopButton = UIButton(frame: CGRect(x:800,y:30,  width:75, height:50))
    var startButton = UIButton(frame: CGRect(x:200,y:30, width:75, height:50))
    var isRecording = false

    // Override required here
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        self.layer.sublayers = nil
        if #available(iOS 13.0, *) {
            context.setFillColor(CGColor(srgbRed: 255, green: 255, blue: 255, alpha: 0))
        } else {
            // Fallback on earlier versions
        }
        context.fill(UIScreen.main.bounds)
    
        
        drawExample(context: context)
        drawStimulus(stimulus: test.stimuli![count], context: context)
        
        //later add this to only be in debug mode
        renderButton()
    }
    
    func renderButton()
    {
        stopButton.backgroundColor = UIColor.red
        stopButton.setTitle("STOP", for: .normal)
        stopButton.addTarget(self, action: #selector(finishRecording), for: .touchUpInside)
        self.addSubview(stopButton)
        stopButton.isEnabled = false;
        stopButton.alpha = 0.0
        
        startButton.backgroundColor = UIColor.green
        startButton.setTitle("START", for: .normal)
        startButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        self.addSubview(startButton)
    }
    
    //this will eventually just be triggered when the user stops talking - a bit complicated for now
    @objc func startRecording(sender: UIButton!){
        if(!isRecording)
        {
        //need to setup async function here to wait until data is posted to continue
            self.vc.startRecording()
            isRecording = true;
            sender.isEnabled = false;
            stopButton.isEnabled = true;
            sender.alpha = 0.0
            stopButton.alpha = 1.0
        }
    }
    
    @objc func finishRecording(sender: UIButton!)
    {
        if(self.vc.audioRecorder.url.absoluteString != "" && isRecording)
        {
            isRecording = false;
            sender.isEnabled = false;
            sender.alpha = 0.0
            startButton.isEnabled = true;
            startButton.alpha = 1.0
            
            DispatchQueue.main.async {
                self.showBlurLoader()
            }
            
            let opQueue = OperationQueue()
                       opQueue.maxConcurrentOperationCount = 1
                       
            let group = DispatchGroup()
            
            let doProcessing = BlockOperation {
                    group.enter()
                    self.vc.finishRecording(success: true)
            }
            
            doProcessing.completionBlock = { [unowned doProcessing] in
                group.leave()
            }
    
            opQueue.addOperation(doProcessing)
            
            group.wait()

        }
    }
    
    @objc func decrementCounter(sender: UIButton!)
    {
        count = count - 1;
        self.setNeedsDisplay()
    }
    @objc func incrementCounter(sender: UIButton!)
    {
        count = count + 1;
        self.setNeedsDisplay()
    }
    
    
    func drawExample(context: CGContext)
    {
        for line in test.exampleLines! {
            drawLine(start: line.point1, end: line.point2, context: context, offX: 0.0, offY: 0.0, id: line.id);
        }
    }
    
    
    func drawStimulus(stimulus: Stimulus, context: CGContext)
    {
        let mirror = Mirror(reflecting: stimulus)
        
        for child in mirror.children {
            if child.label!.contains("line") {
                let val = (child.value as? Int)
                if(val != nil)
                {
                    drawLine(start: test.exampleLines![val!].point1, end: test.exampleLines![val!].point2, context: context, offX: 0.0, offY: 600.0)
                }
            }
        }
    }
    
    //draw stimulus lines without a number
    func drawLine(start: CGPoint, end: CGPoint, context: CGContext, offX: CGFloat, offY:CGFloat)
    {
        let adj_start = CGPoint(x: start.x - offX, y: start.y - offY);
        let adj_end = CGPoint(x: end.x - offX, y: end.y - offY);
        pathLayer = CAShapeLayer();
        let linePath = UIBezierPath();
        linePath.move(to: adj_start);
        linePath.addLine(to: adj_end);
        pathLayer.path = linePath.cgPath
        pathLayer.strokeColor = UIColor.black.cgColor;
        pathLayer.lineWidth = 2;
        pathLayer.lineJoin = CAShapeLayerLineJoin.round;
        self.layer.addSublayer(pathLayer);
    }
    
    //draw them with a number
    func drawLine(start: CGPoint, end: CGPoint, context: CGContext, offX: CGFloat, offY:CGFloat, id: Int)
    {
        let adj_start = CGPoint(x: start.x - offX, y: start.y - offY);
        let adj_end = CGPoint(x: end.x - offX, y: end.y - offY);
        pathLayer = CAShapeLayer();
        let linePath = UIBezierPath();
        linePath.move(to: adj_start);
        linePath.addLine(to: adj_end);
        pathLayer.path = linePath.cgPath
        pathLayer.strokeColor = UIColor.black.cgColor;
        pathLayer.lineWidth = 2;
        
        pathLayer.lineJoin = CAShapeLayerLineJoin.round;
        self.layer.addSublayer(pathLayer);
        
        
        let center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 50)
        let startAngle: CGFloat = .pi
        let endAngle: CGFloat = 0
        
        let outestCircle = BezierPath(arcCenter: center,
                                radius:  190,
                               startAngle: startAngle,
                                 endAngle: endAngle,
                                clockwise: true)
        
        outestCircle.lineWidth = 1.5
        
        outestCircle.generateLookupTable();
        
        //remove duplicates - the top of the arc was in the set twice
        let startPoints = Array(NSOrderedSet(array: outestCircle.lookupTable))
        
        
        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.boldSystemFont(ofSize: 20.0),
            .foregroundColor: UIColor.black]
            
            
            let symText =  String(id + 1)
            let attributedString = NSAttributedString(string: symText, attributes: attributes)
        let xCoord = (startPoints[id] as! CGPoint).x
        let yCoord = (startPoints[id] as! CGPoint).y
        let stringRect = CGRect(x: xCoord - 12.5, y: yCoord - 12.5, width: 25, height: 25)
            attributedString.draw(in: stringRect)
    }

}


