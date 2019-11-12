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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView = MTKView()
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        //sets the view to the metal view, automatically making it the size of the screen + giving us access directly to the touch gestures
        
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.framebufferOnly = false
        //double tapping gets us back to the main page
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        mtkView.addGestureRecognizer(tap)
        
        renderer = Renderer(view: mtkView, device: device, mode: 1)
        mtkView.delegate = renderer
        view = mtkView
    }
    
    @objc func doubleTapped()
    {
        self.performSegue(withIdentifier: "to_Main", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
