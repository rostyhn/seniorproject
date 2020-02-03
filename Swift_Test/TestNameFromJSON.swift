//
//  TestNameFromJSON.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 11/6/19.
//  Copyright © 2020 Cogniscreen All rights reserved.
//

import Foundation

//struct for loading in possible tests
// MARK: - TestNameFromJSONElement
struct TestNameFromJSONElement : Codable {
    let name: String
}


typealias TestNamesFromJSON = [TestNameFromJSONElement]
