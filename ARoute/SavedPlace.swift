//
//  SavedPlace.swift
//  ARKit+CoreLocation
//
//  Created by Edmund Holderbaum on 11/29/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import Foundation

struct SavedPlace {
    let lat: Double
    let lon: Double
    let alt: Double
    let text: String
    let imgName = "pin"
    
    var data: [String: Any] {
        var dict: [String: Any] = [:]
        dict[SavedPlace.latKey] = lat
        dict[SavedPlace.lonKey] = lon
        dict[SavedPlace.altKey] = alt
        dict[SavedPlace.textKey] = text
        return dict
    }
    
    init? (data: [String: Any]) {
        guard let lat = data[SavedPlace.latKey] as? Double,
            let lon = data[SavedPlace.lonKey] as? Double,
            let alt = data[SavedPlace.altKey] as? Double,
            let text = data[SavedPlace.textKey] as? String else {return nil}
        self.lat = lat
        self.lon = lon
        self.alt = alt
        self.text = text
    }
    
    static let latKey = "lat"
    static let lonKey = "lon"
    static let altKey = "alt"
    static let textKey = "text"
}
