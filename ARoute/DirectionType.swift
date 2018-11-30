//
//  DirectionType.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/19/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit

enum DirectionType: String {
    case rightTurn = "turn right"
    case leftTurn = "turn left"
    case exit = "take exit"
    case merge = "merge"
    case destination = "down-arrow-2"
    
    static func from(direction: String)-> String {
        guard let dirTypeString = direction.lowercased().components(separatedBy: " onto ").first else {
            return DirectionType.destination.rawValue
        }
        let directionType = DirectionType(rawValue: dirTypeString) ?? .destination
        return directionType.rawValue
    }
}
