//
//  TestNameFromJSON.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 11/6/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation

// MARK: - TestNameFromJSONElement
struct TestNameFromJSONElement : Codable {
    let name: String
}


typealias TestNamesFromJSON = [TestNameFromJSONElement]
