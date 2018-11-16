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
        
        let addr1 = "3600 W Bayshore RdPalo Alto, CA 94303"
        let addr2 = "4050 Middlefield Rd, Palo Alto, CA 94303"
        let address1 = RoutingClient.originAddress ?? addr1
        let address2 = RoutingClient.destAddress ?? addr2
        
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
//        let pointCount = route.polyline.pointCount
//        for i in 0 ..< pointCount {
//            let point = route.polyline.points()[i]
//            let lat = point.coordinate.latitude
//            let lon = point.coordinate.longitude
//            if i % 2 == 0 {
//                nodes[i + 1] = buildNode(latitude: lat, longitude: lon, altitude: 0, imageName: Constants.tinyTrsp)
//            }
//        }
//
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
