//
//  TestViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import UIKit

//MARK: View Controller Setup
class TestViewController: UIViewController {
    //starts the view controller and then loads in our view
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        override func loadView() {
            //later we will determine the type of test before setting the view but not today
            
            let view = JOLOView()
            view.test = JOLOTest(patientID: patientID, bounds: UIScreen.main.bounds)
            view.vc = self
            view.backgroundColor = UIColor.white
            view.clearsContextBeforeDrawing = true
            self.view = view
            
    }
}
