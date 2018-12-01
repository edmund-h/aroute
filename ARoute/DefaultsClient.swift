//
//  DefaultsClient.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/29/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import Foundation

class DefaultsClient {
    
    static let key  = "saved"
    static let count = "count"
    
    static func setup() {
        if let existingDict = UserDefaults.standard.value(forKey: key) as? [String:Any],
            let _ = existingDict[count] as? Int { return }
        let dict: [String : Any] = [ count : 0 ]
        UserDefaults.standard.set(dict, forKey: key)
    }
    
    static func add(place: SavedPlace) {
        guard var dict = UserDefaults.standard.value(forKey: key) as? [String:Any],
            var itemsCount = dict[count] as? Int else { return }
        dict["\(itemsCount)"] = place.data
        itemsCount+=1
        dict[count] = itemsCount
        UserDefaults.standard.set(dict, forKey: key)
    }
    
    static func get()-> [SavedPlace] {
        guard let dict = UserDefaults.standard.value(forKey: key) as? [String:Any],
            let itemsCount = dict[count] as? Int else { return [] }
        var output = [SavedPlace]()
        for index in 0 ..< itemsCount {
            guard let data = dict["\(index)"] as? [String:Any],
                let place = SavedPlace(data: data) else { continue }
            output.append(place)
        }
        return output
    }
    
    static func clear() {
        UserDefaults.standard.set(nil, forKey: key)
    }
}
