//
//  RoutingClient.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/6/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation
import MapKit

typealias RouteCompletion = (MKRoute?)->()
typealias PlaceCompletion = (ARCLPlace?)->()

final class RoutingClient {
    
    static var lastRoute: MKRoute?
    static var lastOrigin: ARCLPlace?
    static var lastDestination: ARCLPlace?
    
    static var originAddress: String?
    static var destAddress: String?
    
    static func routeTo(_ destination: String, from origin: String, completion: @escaping RouteCompletion) {
        geocode(address: destination, completion: { destPlace in
            geocode(address: origin, completion: { originPlace in
                guard let destPlace = destPlace, let originPlace = originPlace else {
                    completion(nil)
                    return
                }
                requestRoute(from: originPlace, to: destPlace, completion: completion)
            })
        })
    }
    
    static func requestRoute(from origin: ARCLPlace, to destination: ARCLPlace, completion: @escaping RouteCompletion) {
        let request: MKDirections.Request = MKDirections.Request()
        
        request.source = origin.mapItem
        request.destination = destination.mapItem
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate (completionHandler: { response, error in
            
            if var routeResponse = response?.routes, routeResponse.count > 0 {
                
                routeResponse = routeResponse.sorted(by: {
                    $0.expectedTravelTime < $1.expectedTravelTime
                })
                print(routeResponse)
                let route = routeResponse[0]
                print("got route with \(route.steps.count) steps")
                lastRoute = route
                lastOrigin = origin
                lastDestination  = destination
                completion(route)
            } else {
                completion(nil)
            }
        })
    }
    
    static func geocode(address: String, completion: @escaping PlaceCompletion) {
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if let first = placemarks?.first {
                let item = ARCLPlace(placemark: first)
                print("successfully geocoded \(first.name ?? "?????")")
                completion(item)
            } else {
                completion(nil)
            }
        }
    }
    
    static func locationFrom(coordinate: CLLocationCoordinate2D, completion: @escaping PlaceCompletion) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let first = placemarks?.first {
                let place = ARCLPlace(placemark: first)
                completion(place)
            } else {
                completion(nil)
            }
        }
    }
    
    static var hardCodedTestRoute: [MKPolyline] {
        get {
            let coords = CLLocationCoordinate2D.makeFrom(coordinateSet: [
                (37.433105, -122.107467),
                (37.433282, -122.107201),
                (37.432986, -122.106853),
                (37.432298, -122.106161)
            ])
            var lastCoord: CLLocationCoordinate2D? = nil
            var route = [MKPolyline]()
            coords.enumerated().forEach({step, thisCoord in
                if let lastCoord = lastCoord {
                    let polyline = MKPolyline(coordinates: [lastCoord, thisCoord], count: 2)
                        let loc1 = CLLocation(coordinate: lastCoord, altitude: 0)
                        let loc2 = CLLocation(coordinate: thisCoord, altitude: 0)
                        let dist = loc1.distance(from: loc2)
                        let delta = CLLocationCoordinate2D.bearingDelta(between: lastCoord, and: thisCoord)
                        print("step \(step) distance: \(dist) bearing: \(delta)")
                    route.append(polyline)
                }
                lastCoord = thisCoord
            })
            return route
        }
    }
}
