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

typealias Nodes = [LocationAnnotationNode]
typealias NodeCompletion = (Nodes)->()

final class NodeFactory {
    
    static func buildDemoData(completion: @escaping NodeCompletion) {
        var nodes: Nodes = []
        
        let chelsea1 = "229 West 26th Street, New York, NY"
        let chelsea2 = "333 W 23rd St, New York, NY 10011"
        let inwood1 = "65 Park Terrace E, New York, NY 10034"
        let inwood2 = "3050 Corlear Ave"
        
        let address1 = RoutingClient.originAddress ?? chelsea1
        let address2 = RoutingClient.destAddress ?? chelsea2
        
        print("start")
        
        RoutingClient.routeTo(address2, from: address1, completion: { route in
            guard let route = route else { completion([]); return }
            nodesFromRoute(route: route, completion: { routeNodes in
                if let origin = RoutingClient.lastOrigin {
                    origin.name = "origin"
                    nodes.append(origin)
                    print("got origin, alt: \(origin.altitude ?? 999)")
                }
                nodes.append(contentsOf: routeNodes)
                if let destination = RoutingClient.lastDestination {
                    destination.name = "destination"
                    nodes.append(destination)
                    print("got destination, alt: \(destination.altitude ?? 999)")
                }
                completion(nodes)
            })
        })
    }
    
    static func nodesFromRoute(route: MKRoute, completion: @escaping NodeCompletion) {
        var nodes: Nodes = []
        let nodeGroup = DispatchGroup()
        for (index, step) in route.steps.enumerated() {
            nodeGroup.enter()
            let polyCoord = step.polyline.coordinate
            RoutingClient.locationFrom(coordinate: polyCoord, completion: { location in
                guard let location = location else {
                    nodeGroup.leave()
                    return
                }
                location.name = "step \(index)"
                nodes.append(location)
                print("got node for step \(index), alt: \(location.altitude ?? 999)")
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
