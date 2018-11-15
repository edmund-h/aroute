//
//  GoogleElevationClient.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/13/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation

final class GoogleElevationClient {
    
    private static let altitudeRequestURL = "https://maps.googleapis.com/maps/api/elevation/json?"
    private static let key = "AIzaSyCXKo1eNruHTH3sC5sog6_OzaFSq-9FTh0"
    
    static func getElevationFor(nodes: OrderedNodes, completion: NodeCompletion) {
        var pathParams = ""
        for index in 0 ..< nodes.count {
            guard let place = nodes[index] as? ARCLPlace,
                let coord = place.coordinate else {continue}
            let coordStr = "\(coord.latitude),\(coord.longitude)"
            pathParams.append(coordStr)
            if index + 1 < nodes.count {
                pathParams.append("|")
            }
        }
        guard var urlComponents = URLComponents(string: altitudeRequestURL) else {return}
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: key),
            URLQueryItem(name: "locations", value: pathParams)
        ]
        guard let url = urlComponents.url else {return}
        let task = URLSession.shared.dataTask(with: url) { d,r,e in
            guard let data = d else {return}
            do {
                let serializedObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let json = serializedObject as? [String:Any],
                let results = json["results"] as? [[String:Any]] else {return}
                for (index, result) in results.enumerated() {
                    guard let elevation = result["elevation"] else {continue}
                    print("\(index): \(elevation)")
                }
                
            } catch {
                return
            }
            
        }
        task.resume()
    }
    
}
