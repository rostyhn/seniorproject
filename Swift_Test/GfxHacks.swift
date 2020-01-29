//
//  GfxHacks.swift
//  Swift_Test
//
//  Created by Auriemma, Thomas Henry on 1/28/20.
//  Copyright © 2020 Rosty H. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

struct PathCommand {
    let type: CGPathElementType
    let point: CGPoint
    let controlPoints: [CGPoint]
}


// black magic from here on
extension CGPath {
    func points() -> [PathCommand] {
        var bezierPoints = [PathCommand]()
        self.forEach(body: { (element: CGPathElement) in
            guard element.type != .closeSubpath else {
                return
            }
            let numberOfPoints: Int = {
                switch element.type {
                case .moveToPoint, .addLineToPoint: // contains 1 point
                    return 1
                case .addQuadCurveToPoint: // contains 2 points
                    return 2
                case .addCurveToPoint: // contains 3 points
                    return 3
                case .closeSubpath:
                    return 0
                }
            }()
            var points = [CGPoint]()
            for index in 0..<(numberOfPoints - 1) {
                let point = element.points[index]
                points.append(point)
            }
            let command = PathCommand(type: element.type, point: element.points[numberOfPoints - 1], controlPoints: points)
            bezierPoints.append(command)
        })
        return bezierPoints
    }

    func forEach(body: @escaping @convention(block) (CGPathElement) -> Void){
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(_ info: UnsafeMutableRawPointer?, _ element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback as CGPathApplierFunction)
    }
}



class BezierPath: UIBezierPath {

    /// Lookup table is an array containing real points for the path.
     var lookupTable = [CGPoint]()

    func generateLookupTable() {
        let points = cgPath.points()
        var previousPoint: CGPoint?
        let lookupTableCapacity = 15
        let piecesCount = points.count
        guard piecesCount > 0 else {
            return
        }
        let capacityPerPiece = lookupTableCapacity / piecesCount
        for command in points {
            let endPoint = command.point
            guard let startPoint = previousPoint else {
                previousPoint = endPoint
                continue
            }
            switch command.type {
            case .addLineToPoint:
                // Line
                for i in 0...capacityPerPiece {
                    let t = CGFloat(i) / CGFloat(capacityPerPiece)
                    let point = calculateLinear(t: t, p1: startPoint, p2: endPoint)
                    lookupTable.append(point)
                }
            case .addQuadCurveToPoint:
                // Quad curve
                for i in 0...capacityPerPiece {
                    let t = CGFloat(i) / CGFloat(capacityPerPiece)
                    let point = calculateQuad(t: t, p1: startPoint, p2: command.controlPoints[0], p3: endPoint)
                    lookupTable.append(point)
                }
            case .addCurveToPoint:
                // Cube curve
                for i in 0...capacityPerPiece {
                    let t = CGFloat(i) / CGFloat(capacityPerPiece)
                    let point = calculateCube(t: t, p1: startPoint, p2: command.controlPoints[0], p3: command.controlPoints[1], p4: endPoint)
                    lookupTable.append(point)
                }
            default:
                break
            }
            previousPoint = endPoint
        }
    }
    /// Calculates a point at given t value, where t in 0.0...1.0
    private func calculateLinear(t: CGFloat, p1: CGPoint, p2: CGPoint) -> CGPoint {
        let mt = 1 - t
        let x = mt*p1.x + t*p2.x
        let y = mt*p1.y + t*p2.y
        return CGPoint(x: x, y: y)
    }

    /// Calculates a point at given t value, where t in 0.0...1.0
    private func calculateCube(t: CGFloat, p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint) -> CGPoint {
        let mt = 1 - t
        let mt2 = mt*mt
        let t2 = t*t

        let a = mt2*mt
        let b = mt2*t*3
        let c = mt*t2*3
        let d = t*t2

        let x = a*p1.x + b*p2.x + c*p3.x + d*p4.x
        let y = a*p1.y + b*p2.y + c*p3.y + d*p4.y
        return CGPoint(x: x, y: y)
    }

    /// Calculates a point at given t value, where t in 0.0...1.0
    private func calculateQuad(t: CGFloat, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        let mt = 1 - t
        let mt2 = mt*mt
        let t2 = t*t

        let a = mt2
        let b = mt*t*2
        let c = t2

        let x = a*p1.x + b*p2.x + c*p3.x
        let y = a*p1.y + b*p2.y + c*p3.y
        return CGPoint(x: x, y: y)
    }
}
