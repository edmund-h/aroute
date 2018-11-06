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

final class RoutingClient {
    
    static var lastRoute: MKRoute?
    
    static func routeTo(_ destination: String, from origin: String, completion: @escaping RouteCompletion) {
        geocode(address: destination, completion: { destItem in
            geocode(address: origin, completion: { originItem in
                guard let destItem = destItem, let originItem = originItem else {
                    completion(nil)
                    return
                }
                requestRoute(from: originItem, to: destItem, completion: completion)
            })
        })
    }
    
    static func requestRoute(from: MKMapItem, to: MKMapItem, completion: @escaping RouteCompletion) {
        let request: MKDirections.Request = MKDirections.Request()
        
        request.source = from
        request.destination = to
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate (completionHandler: {
            response, error in
            if var routeResponse = response?.routes, routeResponse.count > 0 {
                routeResponse = routeResponse.sorted(by: {$0.expectedTravelTime <
                    $1.expectedTravelTime})
                let route = routeResponse[0]
                print("got route with \(route.steps.count) steps")
                completion(route)
            } else {
                completion(nil)
            }
        })
    }
    
    static func geocode(address: String, completion: @escaping (MKMapItem?)->()) {
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if let first = placemarks?.first {
                let mkFirst = MKPlacemark(placemark: first)
                let item = MKMapItem(placemark: mkFirst)
                print("successfully geocoded \(first.name ?? "?????")")
                completion(item)
            } else {
                completion(nil)
            }
        }
    }
    
    static func locationFrom(coordinate: CLLocationCoordinate2D, completion: @escaping (CLLocation?)->()) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let first = placemarks?.first {
                completion(first.location)
            } else {
                completion(nil)
            }
        }
    }
}
