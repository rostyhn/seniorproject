//
//  TestViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    

        override func viewDidLoad() {
            super.viewDidLoad()
            
        }
        
        override func loadView() {
            view = drawnView()
            view.backgroundColor = UIColor.white
        }
    
    
    
}

class drawnView: UIView {
    

    var points: [CGPoint]?
    var path: UIBezierPath?
    var pathLayer: CAShapeLayer!
    
        let statusLabel = UILabel()
        var statusText = "DEBUG"
    
    
        var alphabet_Test = Test(isTextual:true, jsonName:"AlphabetTest", answerSymbol:"A");
        var touch = UITouch()
    
        var force:CGFloat = 0.0;
        var location = CGPoint(x:200, y:200);
    
    // www.makeapppie.com/2018/05/30/apple-pencil-basics/
        func updateDisplay(touches: Set<UITouch>)
        {
            if let newTouch = touches.first{
                touch = newTouch
            }
            location = touch.location(in: self)
            force = touch.force
        
            statusText = String(format: "Stylus X:%3.0f Y:%3.0f Force:%2.3f", location.x, location.y, force);
            statusLabel.text = statusText;
        }
    
    func addStatusLabel()
    {
        self.addSubview(statusLabel)
        statusLabel.text = "DEBUG"
        statusLabel.font = UIFont(name: "Menlo", size: 20)
        statusLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(50)
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints += [NSLayoutConstraint(item: statusLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        constraints += [NSLayoutConstraint(item: statusLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)]
        constraints += [NSLayoutConstraint(item: statusLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)]
        self.addConstraints(constraints)
    }
    
    override func draw(_ rect: CGRect){
        
        let context = UIGraphicsGetCurrentContext()!
        
        alphabet_Test.draw(context: context);
        addStatusLabel()
        
    }

    override func layoutSubviews() {

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        pathLayer = CAShapeLayer()
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.strokeColor = UIColor.red.cgColor
        pathLayer.lineWidth = 1
        pathLayer.lineJoin = CAShapeLayerLineJoin.round
        pathLayer.lineCap = CAShapeLayerLineCap.round
        self.layer.addSublayer(pathLayer)
        
        if let touch = touches.first {

            points = [touch.location(in: self)]
        }
                    updateDisplay(touches: touches)
        
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first {

            if #available(iOS 9.0, *) {

                if let coalescedTouches = event?.coalescedTouches(for: touch) {

                    points? += coalescedTouches.map { $0.location(in: self) }
                }
                else {

                    points?.append(touch.location(in: self))
                }

                if let predictedTouches = event?.predictedTouches(for: touch) {

                    let predictedPoints = predictedTouches.map { $0.location(in: self) }
                    pathLayer.path = UIBezierPath.interpolateHermiteFor(points: points! + predictedPoints, closed: false).cgPath
                }
                else {

                    pathLayer.path = UIBezierPath.interpolateHermiteFor(points: points!, closed: false).cgPath
                }
            }
            else {

                points?.append(touch.location(in: self))
                pathLayer.path = UIBezierPath.interpolateHermiteFor(points: points!, closed: false).cgPath
            }
        }

            updateDisplay(touches: touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        pathLayer.path = UIBezierPath.interpolateHermiteFor(points: points!, closed: false).cgPath

        updateDisplay(touches: touches)
        
        //BUG: you can circle more than one at a time - it will stop
        //at the first one it finds in the list
        
        for symbol in alphabet_Test.symbols
        {
            if((pathLayer.path!.contains(CGPoint(x: CGFloat(symbol.x) + 12.5, y: CGFloat(symbol.y) + 12.5), using: CGPathFillRule.evenOdd, transform: CGAffineTransform.identity)))
                {
                    
                    if(symbol.name == alphabet_Test.answerSymbol)
                    {
                        if #available(iOS 13.0, *) {
                        pathLayer.fillColor = CGColor.init(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
                        } else {
                        // Fallback on earlier versions
                        }
                    }
                    else
                    {
                        if #available(iOS 13.0, *) {
                        pathLayer.fillColor = CGColor.init(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
                        } else {
                        // Fallback on earlier versions
                        }
                    }
                    
                    var forceSum = Float(0.0);
                    for touch in touches {
                        forceSum = forceSum + Float(touch.force);
                    }
                    forceSum = forceSum/Float(touches.count);

                    statusLabel.text = "Selected " + symbol.name + " Average Force " + String(forceSum);
                    return;
            }
        }
        
        
        //the brute force is fast enough - hit detection for answers
        /*for coords in alphabet_Test.answerSymbols
        {
        if((pathLayer.path!.contains(CGPoint(x: coords.x, y:coords.y), using: CGPathFillRule.evenOdd, transform: CGAffineTransform.identity)))
        {
            if #available(iOS 13.0, *) {
            pathLayer.fillColor = CGColor.init(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
            } else {
            // Fallback on earlier versions
            }
            return;
        }
        else
        {
            if #available(iOS 13.0, *) {
            pathLayer.fillColor = CGColor.init(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
            } else {
            // Fallback on earlier versions
            }
        }*/
        
        points?.removeAll()
        
    }
}


    extension UIBezierPath {

    static func interpolateHermiteFor(points: [CGPoint], closed: Bool = false) -> UIBezierPath {
        guard points.count >= 2 else {
            return UIBezierPath()
        }

        if points.count == 2 {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: points[0])
            bezierPath.addLine(to: points[1])
            return bezierPath
        }

        let nCurves = closed ? points.count : points.count - 1

        let path = UIBezierPath()
        for i in 0..<nCurves {
            var curPt = points[i]
            var prevPt: CGPoint, nextPt: CGPoint, endPt: CGPoint
            if i == 0 {
                path.move(to: curPt)
            }

            var nexti = (i+1)%points.count
            var previ = (i-1 < 0 ? points.count-1 : i-1)

            prevPt = points[previ]
            nextPt = points[nexti]
            endPt = nextPt

            var mx: CGFloat
            var my: CGFloat
            if closed || i > 0 {
                mx  = (nextPt.x - curPt.x) * CGFloat(0.5)
                mx += (curPt.x - prevPt.x) * CGFloat(0.5)
                my  = (nextPt.y - curPt.y) * CGFloat(0.5)
                my += (curPt.y - prevPt.y) * CGFloat(0.5)
            }
            else {
                mx = (nextPt.x - curPt.x) * CGFloat(0.5)
                my = (nextPt.y - curPt.y) * CGFloat(0.5)
            }

            var ctrlPt1 = CGPoint.zero
            ctrlPt1.x = curPt.x + mx / CGFloat(3.0)
            ctrlPt1.y = curPt.y + my / CGFloat(3.0)

            curPt = points[nexti]

            nexti = (nexti + 1) % points.count
            previ = i;

            prevPt = points[previ]
            nextPt = points[nexti]

            if closed || i < nCurves-1 {
                mx  = (nextPt.x - curPt.x) * CGFloat(0.5)
                mx += (curPt.x - prevPt.x) * CGFloat(0.5)
                my  = (nextPt.y - curPt.y) * CGFloat(0.5)
                my += (curPt.y - prevPt.y) * CGFloat(0.5)
            }
            else {
                mx = (curPt.x - prevPt.x) * CGFloat(0.5)
                my = (curPt.y - prevPt.y) * CGFloat(0.5)
            }

            var ctrlPt2 = CGPoint.zero
            ctrlPt2.x = curPt.x - mx / CGFloat(3.0)
            ctrlPt2.y = curPt.y - my / CGFloat(3.0)
            
            path.addCurve(to: endPt, controlPoint1:ctrlPt1, controlPoint2:ctrlPt2)
        }

        if closed {
            path.close()
        }

        return path
    }
}
