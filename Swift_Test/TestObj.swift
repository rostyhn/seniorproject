//
//  TestObj.swift
//  Swift_Test
//
//  Created by Shashank Sastri on 10/2/19.
//  Copyright © 2019 Rosty H. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

//horrible name, but this serves as the top layer for the json object
//loaded into memory, contains an array of symbols
struct SymbolData: Codable {
    let symbols: [Symbol]
}


// MARK: - Symbol
struct Symbol: Codable {
    let name: String
    let x, y: Int
    let imgPath: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case name, x, y, imgPath
        case id = "ID"
    }
}

class Test
{

    var isTextual: Bool;
    var answerSymbol: String;
    var symbols: [Symbol];
    
    init(isTextual:Bool, jsonName: String, answerSymbol: String)
    {
        self.isTextual = isTextual;
        self.answerSymbol = answerSymbol;
        
        //data: try Data(contentsOf: url)
        
        
        let path = Bundle.main.path(forResource: jsonName, ofType: "json")!
        
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe);
        
        //debug - gives you the string of data read in
        //var rawData = String(decoding: jsonData!, as: UTF8.self);
        
        let symbolData = try? JSONDecoder().decode(SymbolData.self, from: jsonData!);
        
        symbols = symbolData!.symbols;
        
    }
    
    func draw(context:CGContext)
    {
        
        
        
        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center
        
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.boldSystemFont(ofSize: 20.0),
            .foregroundColor: UIColor.black
            
        ]
        
        if(isTextual)
        {
            /*use names of symbols instead of image files
              saves the annoyance of having to create a lot of seperate
              bitmap files for symbols might also be nice for debugging*/
            
            for symbol in symbols
            {
                let symText = symbol.name;
                let attributedString = NSAttributedString(string: symText, attributes: attributes)

                let stringRect = CGRect(x: symbol.x, y: symbol.y, width: 25, height: 25)
                attributedString.draw(in: stringRect)

            }
        }
        else
        {
            
        }
    }
    
}
