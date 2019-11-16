//
//  DoctorList.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 11/7/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

//struct for loading in doctor credentials
import Foundation

// MARK: - DoctorName
struct DoctorName : Codable {
    let DoctorID: Int
    let DoctorName: String
}

typealias DoctorNames = [DoctorName]
