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

var mtkView: MTKView!
var renderer: Renderer!


class AboutUsViewController: UIViewController, UIGestureRecognizerDelegate {
    var labelArray = ["The Cancellation Test",
                      "Swift Team: \n" +
                      "Rosty Hnatyshyn - Graphics, Web Interop, Logic \n" +
                      "Hiral Shah - Test Design, UI",
                      "Web Team: \n" +
                      "Thomas Auriemma - RESTful API, Backend, Database Design"]
    var label = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelArray.reverse()
        mtkView = MTKView()
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        //sets the view to the metal view, automatically making it the size of the screen + giving us access directly to the touch gestures
        
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.framebufferOnly = false
        //double tapping gets us back to the main page
        let singletap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singletap.numberOfTapsRequired = 1
        singletap.numberOfTouchesRequired = 1
        let dbltap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        dbltap.numberOfTapsRequired = 2
        dbltap.numberOfTouchesRequired = 1
        mtkView.addGestureRecognizer(dbltap)
        mtkView.addGestureRecognizer(singletap)
        
        renderer = Renderer(view: mtkView, device: device, mode: 1)
        mtkView.delegate = renderer
        view = mtkView
        label.frame = CGRect(x: UIScreen.main.bounds.maxX / 2 - 256, y: UIScreen.main.bounds.maxY / 2 - 256, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY)
        label.numberOfLines = 99
        label.layer.zPosition = 1
        label.textColor = UIColor.white
        label.font = UIFont(name: "Avenir-Light", size: 30.0)
        mtkView.addSubview(label)
        label.text = labelArray.popLast()
    }
    
    @objc func singleTapped()
    {
        if(labelArray.count != 0)
        {
            if(label.alpha == 1)
            {
                fadeViewOut(view: label, delay: 1.0)
            }
            else
            {
                fadeViewIn(view: label, delay: 1.0)
                label.text = labelArray.popLast()
            }

        }
    }
    
    @objc func doubleTapped()
    {
        self.performSegue(withIdentifier: "to_Main", sender: self)
    }
    
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
