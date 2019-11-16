//
//  AboutUsViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//
//absolutely unnecessary, I just wanted to challenge myself
import UIKit
import MetalKit
import ModelIO

class AboutUsViewController: UIViewController, UIGestureRecognizerDelegate {
    var mtkView: MTKView!
    var renderer: Renderer!
    var credits = ["The Cancellation Test",
                      "Project Sponsors: \n" +
                      "Dr. Libon \n" +
                      "Dr. Baliga",
                      "Swift Team: \n" +
                      "Rosty Hnatyshyn - Graphics, Web interop, Logic, UI \n" +
                      "Hiral Shah - Test design",
                      "Web Team: \n" +
                      "Thomas Auriemma - RESTful API, Web backend, Database design \n" +
                      "Richard Gonzalez - Database design \n" +
                      "Thomas Lentz - Web frontend \n" +
                      "Micheal Zacierka - Web backend",
                      "Purpose: \n" +
                      "This app is designed to facilitate the testing of patients who suspect they have symptoms of neurodegenerative disease. Dr. Libon suspects that the way a patient interacts with the test can reveal cognitive patterns that may be early warning signs of dementia or Alzheimer's.",
                      "Shader modified from \n" +
                      "http://glslsandbox.com/e#57026.0",
                      "THE END"]
    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        credits.reverse()
        
        //MARK: Metal View setup
        mtkView = MTKView()
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        //sets the view to the metal view, automatically making it the size of the screen + giving us access directly to the touch gestures
        
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.framebufferOnly = false
        
        
        //MARK: Gesture setup
        //single taps move the credits along
        let singletap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singletap.numberOfTapsRequired = 1
        singletap.numberOfTouchesRequired = 1
        
        //double tapping gets us back to the main page
        let dbltap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        dbltap.numberOfTapsRequired = 2
        dbltap.numberOfTouchesRequired = 1
        mtkView.addGestureRecognizer(dbltap)
        mtkView.addGestureRecognizer(singletap)
        
        renderer = Renderer(view: mtkView, device: device, mode: 1)
        mtkView.delegate = renderer
        view = mtkView
        
        //MARK: Label setup
        
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY)
        label.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        label.textAlignment = .center
        label.numberOfLines = 99
        label.layer.zPosition = 1
        label.textColor = UIColor.white
        label.font = UIFont(name: "Optima", size: 30.0)
        mtkView.addSubview(label)
        label.text = credits.popLast()
    }
    
    //MARK: Gesture functions
    @objc func singleTapped()
    {
        if(credits.count != 0)
        {
            if(label.alpha == 1)
            {
                fadeViewOut(view: label, delay: 1.0)
            }
            else
            {
                fadeViewIn(view: label, delay: 1.0)
                label.text = credits.popLast()
            }
        }
    }
    @objc func doubleTapped()
    {
       self.performSegue(withIdentifier: "to_Main", sender: self)
    }
    
    //MARK: Label fade in / out
    
    func fadeViewIn(view : UIView, delay: TimeInterval) {

        let animationDuration = 1.0
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
            
            })
    }
    func fadeViewOut(view : UIView, delay: TimeInterval) {
        let animationDuration = 1.0
        UIView.animate(withDuration: animationDuration, delay: delay, options: [], animations: { () -> Void in
            view.alpha = 0

            },
            completion: nil)
    }
}
