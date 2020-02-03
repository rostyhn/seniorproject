//
//  TestViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 9/15/19.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

//rename to JOLOViewController


import UIKit
import AVFoundation
import Speech
//MARK: View Controller Setup
class TestViewController: UIViewController, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var joloView: JOLOView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //starts the view controller and then loads in our view
        override func viewDidLoad() {
            super.viewDidLoad()
            
            recordingSession = AVAudioSession.sharedInstance()
            
            do {
                
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.startRecording()
                        } else {
                            self.showAlert(title: "Test Cancelled", message: "The test will now end.")
                        }
                    }
                }
            } catch {
                self.showAlert(title: "Test Cancelled", message: "The test will now end.")
            }
        }
        override func loadView() {
            //later we will determine the type of test before setting the view but not today
            joloView = JOLOView()
            joloView.test = JOLOTest(patientID: patientID, bounds: UIScreen.main.bounds)
            joloView.vc = self
            joloView.backgroundColor = UIColor.white
            joloView.clearsContextBeforeDrawing = true
            self.view = joloView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.deviceOrientation = .portrait
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    

    
    func startRecording()
    {
        let audioURL = self.getDataURL()

           let settings = [
               AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
               AVSampleRateKey: 12000,
               AVNumberOfChannelsKey: 1,
               AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
           ]

           do {
               audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
               audioRecorder.delegate = self
               audioRecorder.record()
           } catch {
               finishRecording(success: false)
           }
    }
    
    func finishRecording(success: Bool)
    {
        //if successful, send to backend
        if(success)
        {
            audioRecorder.stop();
            let loc = audioRecorder!.url
            
            SFSpeechRecognizer.requestAuthorization { authStatus in
                OperationQueue.main.addOperation {
                   switch authStatus {
                      case .authorized:
                        
                        self.transcribeFile(url: loc)
                      case .denied:
                        self.performSegue(withIdentifier: "to_Main", sender: self);
                      case .restricted:
                         self.performSegue(withIdentifier: "to_Main", sender: self);
                      case .notDetermined:
                         self.performSegue(withIdentifier: "to_Main", sender: self);
                   }
                }
            }
            
        }
        
        /*let serverAddress = "http://" + (UserDefaults.standard.string(forKey:"serverAddress")!) + ":5000"
        let url = URL(string: serverAddress + "/data/upload")
        let loc = audioRecorder!.url
        
        let answerData = try? Data(contentsOf: loc, options: .mappedIfSafe)
        
        var answerRequest = URLRequest(url:url!)
        answerRequest.httpMethod = "POST"
        answerRequest.httpBody = answerData
        answerRequest.setValue("audio/m4a", forHTTPHeaderField: "Content-Type")
        
        let task_answers = URLSession.shared.dataTask(with: answerRequest)
        task_answers.resume()*/
        
    }
    
    
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
     func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

      func getDataURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("audio-" + String(Date.init().timeIntervalSince1970) + ".m4a")
    }
    
    fileprivate func transcribeFile(url: URL) {

      // 1 make sure dictation is enabled on the device in settings for this to work.
      guard let recognizer = SFSpeechRecognizer() else {
        print("Speech recognition not available for specified locale")
        return
      }
      
        if #available(iOS 13, *) {
            recognizer.supportsOnDeviceRecognition = true
        } else {
            print("did not change supports")
        }
     
      
      // 2
      let request = SFSpeechURLRecognitionRequest(url: url)
        if #available(iOS 13, *) {
            request.requiresOnDeviceRecognition = true
        } else {
            print("did not change requires")
        }
      // 3
      recognizer.recognitionTask(with: request) {
        [unowned self] (result, error) in
        guard let result = result else {
          print("There was an error transcribing that file")
          DispatchQueue.main.async {
            self.joloView.removeBlurLoader()
          }
          return
        }
        // 4
        if result.isFinal {
           
            if #available(iOS 13, *) {
                print(recognizer.supportsOnDeviceRecognition)
                print(request.requiresOnDeviceRecognition)
            } else {
                print("network only")
            }
            
            // Increments to next stimuli if response is a number
            // If response starts with a WORD, then number won't continue either
            // Must start with a number
            if (result.bestTranscription.formattedString.isNumeric) {
                self.joloView.count = self.joloView.count + 1
            }
            
            var newResponse = Response(responseDataList: []);
            
            for segment in result.bestTranscription.segments {
                newResponse.responseDataList.append(ResponseData(responsePart: segment.substring, timestamp: segment.timestamp, confidence: segment.confidence, duration: segment.duration))
            }
            self.joloView.test.responses.append(newResponse)
            
            DispatchQueue.main.async {
                self.joloView.setNeedsDisplay()
                self.joloView.removeBlurLoader()
                print(self.joloView.test.responses)
            }
        }
        
        
      }
    }
}

extension String {
    var isNumeric : Bool {
        return Double(self) != nil
    }
}
