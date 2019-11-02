//
//  TestViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import UIKit


//set init settings here, can change them in the app

class TestViewController: UIViewController {
    //starts the view controller and then loads in our view
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        override func loadView() {
            let view = drawnView()
            //apple nerds will tell you this is bad design
            view.vc = self
            view.backgroundColor = UIColor.white
            self.view = view
            
    }
}

class drawnView: UIView {
    weak var vc: TestViewController!
    let serverAddress = "http://" + (UserDefaults.standard.string(forKey:"serverAddress")!) + ":5000"
    
    //data stuff
    var currentTest = Test(testName: "alphabet_test",isTextual:true, jsonName:"AlphabetTest", answerSymbol:"A", patientID: patientID);
    //for data gathering - this gets cleared every time a new drawing starts
    var touchData = Array<TouchData>()
    
    //UI stuff
    let statusLabel = UILabel()
    var statusText = "DEBUG"
    //hard coded for now, add constraints later
    let btn_end = UIButton(frame: CGRect(x:1075,y:30, width:25, height:25))
    
    //drawing stuff
    var points: [CGPoint]?
    var path: UIBezierPath?
    var pathLayer: CAShapeLayer!
    var touch = UITouch()
    var force:CGFloat = 0.0;
    var location = CGPoint(x:200, y:200);
    
     /*
     www.makeapppie.com/2018/05/30/apple-pencil-basics/
     updates the debug status bar and also pushes the data about the path into an array
     */
        func updateDisplay(touches: Set<UITouch>)
        {
            if let newTouch = touches.first{
                touch = newTouch
            }
            
            location = touch.location(in: self)
            force = touch.force
        
            if(UserDefaults.standard.bool(forKey: "debugMode"))
            {
                statusText = String(format: "Stylus X:%3.0f Y:%3.0f Force:%2.3f", location.x, location.y, force);
                statusLabel.text = statusText;
            }
            touchData.append(TouchData(x: touch.location(in: self).x, y: touch.location(in: self).y, force: touch.force, time: DispatchTime.now().rawValue))
        }
    
    /*
     adds debug status bar at the bottom
     */
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
    /*
     Adds a button programatically to stop the test
     */
    func addButton()
    {
        self.addSubview(btn_end)
        btn_end.backgroundColor = .red
        btn_end.setTitle("X", for: .normal)
        btn_end.addTarget(self, action: #selector(endTest), for: .touchUpInside)
    }
    
    //for some reason, the function is now in objective C
    @objc func endTest(sender: UIButton!)
    {
        if(currentTest.patientAnswers.count != 0)
        {
            let testEndTime = DispatchTime.now().rawValue
            currentTest.setTestEndTime(testEndTime: testEndTime)
        
            
            if(UserDefaults.standard.bool(forKey: "debugMode"))
            {
        //NOTE: every time value is a raw value in nanoseconds - calculate everything on the web app
            print("Test started at " + String(currentTest.testStartTime))
            print("Length of test " + String(testEndTime - currentTest.testStartTime))
            print("Test ended at " + String(testEndTime))
        
        //what are these fortran style for loops...
            for i in 0...currentTest.patientAnswers.count-1
            {
                let symbol = currentTest.patientAnswers[i];
                print("ID: " + String(symbol.id) + "\nName: " + symbol.name)
            
                print("\nTime drawing initiated: " + String(currentTest.patientAnswerTouchData[i].first!.time))

                for touch in currentTest.patientAnswerTouchData[i]
                {
                    print("\nTouch Data")
                    print("\nx: " + touch.x.description)
                    print("\ny: " + touch.y.description)
                    print("\nForce: " + touch.force.description)
                    print("\nTime: " + String(touch.time))
                }
                
                print("\n# of touches: " + String(currentTest.patientAnswerTouchData[i].count))
                print("\nTime drawing ended: " + String(currentTest.patientAnswerTouchData[i].last!.time))
                }
            }
        
        /*time to push the data to the server - that is where we will actually tie the two arrays together
        and maintain their order - you can easily find the order in which points where chosen and their data
        through simply iterating through the two arrays*/
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(currentTest)
        // Debug: gives you the actual json created from the test
        /*let json = String(data: jsonData!, encoding: String.Encoding.utf8)
        print(json)
        */
        //https://medium.com/@oleary.audio/simultaneous-asynchronous-calls-in-swift-9c1f5fd3ea32
            //creates an operationQueue to handle the async calls - we need the testData to be uploaded before the questionnaire data
        let opQueue = OperationQueue()
            opQueue.maxConcurrentOperationCount = 1
            
        let group = DispatchGroup()
        
        let url = URL(string: serverAddress + "/data/upload_patient_test_data")
        var request = URLRequest(url:url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //will leave the queue AFTER the data has been sent
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                group.leave()
            }
        
        let sendTestData = BlockOperation {
            group.enter()
            task.resume()
        }
        
        opQueue.addOperation(sendTestData)
        
        let answerJSONData = try? jsonEncoder.encode(answerData)
        
        // Debug: gives you the actual json created from the test
        /*let json = String(data: jsonData!, encoding: String.Encoding.utf8)
        print(json)
        */
        let answersUrl = URL(string: serverAddress + "/data/upload_patient_questionnaire_answers")
        var answerRequest = URLRequest(url:answersUrl!)
        answerRequest.httpMethod = "POST"
        answerRequest.httpBody = answerJSONData
        answerRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
            let task_answers = URLSession.shared.dataTask(with: answerRequest)
            
            //wait till we finish posting the data
            group.wait()
            
            let sendQuestionnaireData = BlockOperation {
                //then send the data
                task_answers.resume()
            }
            sendQuestionnaireData.addDependency(sendTestData)
            opQueue.addOperation(sendQuestionnaireData)
            
        
        
        /*show the alert that will end the test and return to the main screen
        / so that a new test can be administered
        */
    
        
        let alertController = UIAlertController(title: "Test Complete", message: "Please return the device to the test administator.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Done", style: .default, handler: {

            [unowned self] (action) -> Void in
            
            self.vc.performSegue(withIdentifier: "to_Main", sender: self);
        })
        alertController.addAction(defaultAction)
        
        self.vc.present(alertController, animated: false);
        }
        
    }
    
    /*
     Setup our view
     */
    
    override func draw(_ rect: CGRect){
        
        //grab the graphics context
        let context = UIGraphicsGetCurrentContext()!
        
        //draw the view and add labels - need to do it this way because draw() has been overridden
        currentTest.draw(context: context);
        if(UserDefaults.standard.bool(forKey: "debugMode"))
        {
            addStatusLabel()
        }
        addButton()
        
    }

    //overrides layoutSubviews otherwise stuff won't draw
    override func layoutSubviews() {
        //DO NOT DELETE
    }
    
    /*
     Runs when a path is started
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //create the path
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
    
    /*
     Runs when someone is touching the screen and moving
     */

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first {
            
            //fancy curve smoothing - makes it look nicer than jagged lines
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

    /*
     Runs when a touch ends - where our hit detection mechanism lies
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        pathLayer.path = UIBezierPath.interpolateHermiteFor(points: points!, closed: false).cgPath


        updateDisplay(touches: touches)
        
        //BUG: you can circle more than one at a time - it will stop at the first one it finds in the list
        
        //will consider implementing a quadtree if we need the computational boost
        
        for symbol in currentTest.symbols
        {
            if((pathLayer.path!.contains(CGPoint(x: CGFloat(symbol.x) + CGFloat(currentTest.bBoxWidth/2), y: CGFloat(symbol.y) + CGFloat(currentTest.bBoxHeight/2)), using: CGPathFillRule.evenOdd, transform: CGAffineTransform.identity)))
                {
                    if(UserDefaults.standard.bool(forKey: "debugMode"))
                    {
                        if(symbol.name == currentTest.answerSymbol)
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
                        statusLabel.text = "Selected " + symbol.name;
                    }
                    //gather the data here
                    currentTest.patientAnswers.append(symbol)
                    currentTest.patientAnswerTouchData.append(touchData)
                    //clear the touchData array to avoid having data points that belong to another path
                    touchData.removeAll()
                    return;
            }
        }
        points?.removeAll()
        //we don't remove the data here, we want to keep it in case the patient decides to do something other than circle things
        //touchData.removeAll()
        
    }
}

/*
 The code from here on handles the drawing functionality... no real reason to change this
 */
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
