//
//  Question.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/23/19.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

import Foundation

//struct for loading in questions
// MARK: - QuestionElement
struct QuestionElement: Codable {
    let possibleAnswers, question: String
    let questionID, questionType: Int

    enum CodingKeys: String, CodingKey {
        case possibleAnswers = "PossibleAnswers"
        case question = "Question"
        case questionID = "QuestionID"
        case questionType = "QuestionType"
    }
}

typealias Question = [QuestionElement]

