//
//  NodeFactory.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/6/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation
import MapKit
import SceneKit
import ARCL

typealias NodeCompletion = ([LocationAnnotationNode])->()

final class NodeFactory {
    static func buildDemoData(completion: @escaping NodeCompletion) {
        var nodes: [LocationAnnotationNode] = []
        
        
        let address1 = "65 Park Terrace E, New York, NY 10034"
        let address2 = "600 W 218th St, New York, NY 10034"
        
        print("start")
        
        RoutingClient.routeTo(address2, from: address1, completion: { route in
            guard let route = route else { completion([]); return }
            nodesFromRoute(route: route, completion: { routeNodes in
                if let origin = RoutingClient.lastOrigin {
                    nodes.append(origin)
                }
                nodes.append(contentsOf: routeNodes)
                if let destination = RoutingClient.lastDestination {
                    nodes.append(destination)
                }
                completion(nodes)
            })
        })
    }
    
    static func nodesFromRoute(route: MKRoute, completion: @escaping NodeCompletion) {
        var nodes: [LocationAnnotationNode] = []
        let nodeGroup = DispatchGroup()
        for (index, step) in route.steps.enumerated() {
            nodeGroup.enter()
            let polyCoord = step.polyline.coordinate
            RoutingClient.locationFrom(coordinate: polyCoord, completion: { location in
                guard let coord = location?.coordinate, let alt = location?.altitude else {
                    nodeGroup.leave()
                    return
                }
                let lat = coord.latitude
                let lon = coord.longitude
                let node = buildNode(latitude: lat, longitude: lon, altitude: alt, imageName: Constants.downArrow)
                nodes.append(node)
                print("got node for step \(index)")
                nodeGroup.leave()
            })
        }
        nodeGroup.notify(queue: .main) {
            print("finished getting nodes")
            completion(nodes)
        }
    }
    
    static func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let image = UIImage(named: imageName)!
        return LocationAnnotationNode(location: location, image: image)
    }
}
