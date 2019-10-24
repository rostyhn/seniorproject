//
//  QuestionViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/23/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation
import UIKit

struct Answer : Codable, Equatable {
    var QuestionID: Int
    var Answer: String
}

class QuestionViewController: UIViewController {
    var answers = Array<Answer>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func loadView() {
        view = QuestionView()
        view.backgroundColor = UIColor.white
        
        let url = URL(string: "http://192.168.1.160:5000/data/download_questions")
        let jsonData = try? Data(contentsOf: url!, options: .mappedIfSafe);
        
        //debug - gives you the string of data read in
        /*var rawData = String(decoding: jsonData!, as: UTF8.self);
        print(rawData)
        
        print(jsonData)
        */
        
        
        
        let questions = try? JSONDecoder().decode(Question.self, from: jsonData!)
        
        var counter = 0;
        
        for question in questions!
        {
            var currentQuestionLabel = UILabel()
            currentQuestionLabel.numberOfLines = 0
            currentQuestionLabel.textColor = UIColor.black
            currentQuestionLabel.text = String(counter + 1) + ". " + question.question
            currentQuestionLabel.frame = CGRect(x: 40, y: counter * 100 + 50, width: 1000, height:40)
            
            view.addSubview(currentQuestionLabel)
            
            switch(question.questionType)
            {
                //segmented control
                case 1:
                let segControl = UISegmentedControl()
                let answersAsArray = question.possibleAnswers.split(separator: "#")
                segControl.tag = question.questionID
                
                for i in 0...answersAsArray.count - 1
                {
                    segControl.insertSegment(withTitle: answersAsArray[i].description, at: i, animated: true)
                }
                
                segControl.frame = CGRect(x: 40, y: counter * 100 + 100, width: 1000, height:40)
                
                segControl.addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
                
                view.addSubview(segControl)
                break;
                //text field
                case 2:
                var textField = UITextField()
                textField.borderStyle = .bezel
                textField.clearsOnBeginEditing = true
                textField.frame = CGRect(x: 40, y: counter * 100 + 100, width: 250, height:40)
                textField.addTarget(self, action: #selector(textFieldFinishedEditing), for: .editingDidEnd)
                textField.tag = question.questionID
                
                view.addSubview(textField)
                break;
                default:
                print("Question type not supported.")
                break;
            }
            counter = counter + 1;
        }
        
        //button that will get us out of here
        let nextScreenButton = UIButton()
        nextScreenButton.setTitleColor(UIColor.blue, for: .normal)
        nextScreenButton.setTitle("Begin test", for: .normal)
        nextScreenButton.addTarget(self, action: #selector(finishQuestions), for: .touchUpInside)
        nextScreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(nextScreenButton)
                
        NSLayoutConstraint.activate([
            nextScreenButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 48.0),
            nextScreenButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -48.0),
            nextScreenButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0),
            nextScreenButton.heightAnchor.constraint(equalToConstant: 48.0)
        ])
        
            
        }
    
    @objc private func finishQuestions()
    {
        if(!answers.isEmpty)
        {
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(answers)
            // Debug: gives you the actual json created from the test
            /*let json = String(data: jsonData!, encoding: String.Encoding.utf8)
            print(json)
            */
            
            let url = URL(string: "http://192.168.1.160:5000/data/upload_patient_questionnaire_answers")
            var request = URLRequest(url:url!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
        let alertController = UIAlertController(title: "Test", message: "The test will now begin.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Begin Test", style: .default, handler: {

            [unowned self] (action) -> Void in

        self.performSegue(withIdentifier: "to_Test", sender: self);
        })
        alertController.addAction(defaultAction)
        
        present(alertController, animated: false);
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl!) {
        //check if the question has been already answered - if so, remove it
        for answer in answers
        {
            if(answer.QuestionID == segment.tag)
            {
                answers.remove(at: answers.firstIndex(of: answer)!)
            }
        }
        
        answers.append(Answer(QuestionID: segment.tag, Answer: segment.titleForSegment(at: segment.selectedSegmentIndex)!))
    }
    
    @objc func textFieldFinishedEditing(textField: UITextField!)
    {
        for answer in answers
        {
            if(answer.QuestionID == textField.tag)
            {
                answers.remove(at: answers.firstIndex(of: answer)!)
            }
        }
        
        answers.append(Answer(QuestionID: textField.tag, Answer: textField.text!))
    }
    
        
        
}

class QuestionView: UIView {
    
}
