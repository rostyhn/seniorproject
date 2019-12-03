//
//  QuestionViewController.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/23/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//
//TODO: figure out more intelligent way to place UI components rather than hard coding them
import Foundation
import UIKit

var answerData = AnswerData(patientID: patientID, answers: Array<Answer>())
//the full file to be uploaded to the server
//MARK: AnswerData
struct AnswerData: Codable, Equatable {
    var patientID: String
    var answers: Array<Answer>
    
    init(patientID: String, answers: Array<Answer>)
    {
        self.patientID = patientID
        self.answers = answers
    }
}
//MARK: Answer
//struct for uploading answers
struct Answer : Codable, Equatable {
    var QuestionID: Int
    var Answer: String
}

//questionnaire view controller
class QuestionViewController: UIViewController {
    let serverAddress = "http://" + (UserDefaults.standard.string(forKey:"serverAddress")!) + ":5000"
    let questionView = QuestionView()
    
    //MARK: On view load
    override func viewDidLoad() {
        super.viewDidLoad()
        questionView.frame = view.bounds
        questionView.contentSize = view.bounds.size
        questionView.translatesAutoresizingMaskIntoConstraints = false
        questionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        
        let url = URL(string: serverAddress + "/data/download_questions")
        let jsonData = try? Data(contentsOf: url!, options: .mappedIfSafe)
        
        if(UserDefaults.standard.bool(forKey: "debugMode"))
        {
        //debug - gives you the string of data read in
            let rawData = String(decoding: jsonData!, as: UTF8.self);
            print(rawData)
        }
        let questions = try? JSONDecoder().decode(Question.self, from: jsonData!)
        
        var counter = 0;
        //MARK: Load questions from server
        for question in questions!
        {
            let currentQuestionLabel = UILabel()
            currentQuestionLabel.numberOfLines = 0
            currentQuestionLabel.textColor = UIColor.black
            currentQuestionLabel.text = String(counter + 1) + ". " + question.question
            currentQuestionLabel.frame = CGRect(x: 40, y: counter * 100 + 50, width: 1000, height:40)
            questionView.contentSize = CGSize(width: questionView.contentSize.width, height: questionView.contentSize.height + 20)

            questionView.addSubview(currentQuestionLabel)
            
            
            //MARK: Generate UI based on question type
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
                questionView.contentSize = CGSize(width: questionView.contentSize.width, height: questionView.contentSize.height + 35)
                questionView.addSubview(segControl)
                break;
                //text field
                case 2:
                let textField = UITextField()
                textField.borderStyle = .bezel
                textField.clearsOnBeginEditing = true
                textField.frame = CGRect(x: 40, y: counter * 100 + 100, width: 250, height:40)
                questionView.contentSize = CGSize(width: questionView.contentSize.width, height: questionView.contentSize.height + 20)
                textField.addTarget(self, action: #selector(textFieldFinishedEditing), for: .editingDidEnd)
                textField.tag = question.questionID
                
                questionView.addSubview(textField)
                break;
                default:
                print("Question type not supported.")
                break;
            }
            counter = counter + 1;
        }
        
        //MARK: Generate next button
        let nextScreenButton = UIButton()
        nextScreenButton.setTitleColor(UIColor.blue, for: .normal)
        nextScreenButton.setTitle("Begin test", for: .normal)
        nextScreenButton.addTarget(self, action: #selector(finishQuestions), for: .touchUpInside)
        nextScreenButton.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height:50.0)
        nextScreenButton.center = CGPoint(x: UIScreen.main.bounds.midX, y: CGFloat(counter) * 100.0 + 100.0)
        nextScreenButton.translatesAutoresizingMaskIntoConstraints = false
        questionView.addSubview(nextScreenButton)
                
        self.view.removeBlurLoader()
        view = questionView
        view.backgroundColor = UIColor.white
        
    }
    
    //MARK: Leave view
    @objc private func finishQuestions()
    {
        let alertController = UIAlertController(title: "Test Starting", message: "The test will now begin. Circle every "  + UserDefaults.standard.string(forKey: "targetSymbol")! + " you can find.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Begin Test", style: .default, handler: {

            [unowned self] (action) -> Void in
        self.performSegue(withIdentifier: "to_Test", sender: self);
        })
        alertController.addAction(defaultAction)
        
        present(alertController, animated: false);
    }
    //MARK: UI component utility functions
    @objc func segmentedControlValueChanged(segment: UISegmentedControl!) {
        //check if the question has been already answered - if so, remove it
        for answer in answerData.answers
        {
            if(answer.QuestionID == segment.tag)
            {
                answerData.answers.remove(at: answerData.answers.firstIndex(of: answer)!)
            }
        }
        
        answerData.answers.append(Answer(QuestionID: segment.tag, Answer: segment.titleForSegment(at: segment.selectedSegmentIndex)!))
    }
    
    @objc func textFieldFinishedEditing(textField: UITextField!)
    {
        //change answer when the text field is finished begin edited
        for answer in answerData.answers
        {
            if(answer.QuestionID == textField.tag)
            {
                answerData.answers.remove(at: answerData.answers.firstIndex(of: answer)!)
            }
        }
        
        answerData.answers.append(Answer(QuestionID: textField.tag, Answer: textField.text!))
    }
    
}

class QuestionView: UIScrollView {
    
}
