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
typealias OrderedNodes = [Int: LocationAnnotationNode]
typealias NodeCompletion = (Nodes)->()
typealias OrderedNodeCompletion = (OrderedNodes)->()

final class NodeFactory {
    
    static func buildDemoData(completion: @escaping OrderedNodeCompletion) {
        var nodes: OrderedNodes = [:]
        
        let paloAlto = "3600 West Bayshore Rd, Palo Alto, CA, 94303"
        let cupertino = "17100 Montebello Rd, Cupertino, CA 95014"
        //let chelsea1 = "229 West 26th Street, New York, NY"
        //let chelsea2 = "333 W 23rd St, New York, NY 10011"
        //let inwood1 = "65 Park Terrace E, New York, NY 10034"
        //let inwood2 = "3050 Corlear Ave"
        
        let address1 = RoutingClient.originAddress ?? paloAlto
        let address2 = RoutingClient.destAddress ?? cupertino
        
        print("start")
        
        RoutingClient.routeTo(address2, from: address1, completion: { route in
            guard let route = route else { completion([:]); return }
            nodesFromRoute(route: route, completion: { routeNodes in
                if let origin = RoutingClient.lastOrigin {
                    origin.name = "origin"
                    nodes[0] = origin
                    print("got origin, alt: \(origin.altitude ?? 999)")
                }
                routeNodes.keys.forEach({nodes[$0] = routeNodes[$0]!})
                if let destination = RoutingClient.lastDestination {
                    destination.name = "destination"
                    nodes[nodes.count] = destination
                    print("got destination, alt: \(destination.altitude ?? 999)")
                }
                completion(nodes)
            })
        })
    }
    
    static func nodesFromRoute(route: MKRoute, completion: @escaping OrderedNodeCompletion) {
        var nodes: OrderedNodes = [:]
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
                nodes[index + 1] = location
                print("got node for step \(index), alt: \(location.altitude ?? 999)")
                nodeGroup.leave()
            })
        }
        nodeGroup.notify(queue: .main) {
            print("finished getting nodes")
            GoogleElevationClient.getElevationFor(nodes: nodes, completion: { _ in })
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

extension CLLocationCoordinate2D {
    static func == (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D)-> Bool {
        let latEqual = left.latitude == right.latitude
        let lonEqual = right.longitude == left.longitude
        return latEqual && lonEqual
    }
}
