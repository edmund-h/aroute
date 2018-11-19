//
//  CLLocationCoordinate2D + Extensions.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/16/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Equatable {
    
    public static func == (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D)-> Bool {
        let latEqual = left.latitude == right.latitude
        let lonEqual = right.longitude == left.longitude
        return latEqual && lonEqual
    }
    
    static func + (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D)-> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude + right.latitude, longitude: left.longitude + right.longitude)
    }
    
    static func - (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D)-> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude - right.latitude, longitude: left.longitude - right.longitude)
    }
    
    static func * (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D)-> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude * right.latitude, longitude: left.longitude * right.longitude)
    }
    
    static func / (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D)-> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude / right.latitude, longitude: left.longitude / right.longitude)
    }
    
    static func * (left: CLLocationCoordinate2D, right: Double)-> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude * right, longitude: left.longitude / right)
    }
    
    static func / (left: CLLocationCoordinate2D, right: Double)-> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude / right, longitude: left.longitude / right)
    }
    
    static func bearingDelta(between coord1: CLLocationCoordinate2D, and coord2: CLLocationCoordinate2D)-> Double {
        //thanks to Movable Type for this formula
        let phi1 = coord1.latitude
        let phi2 = coord2.latitude
        let lam1 = coord1.longitude
        let lam2 = coord2.longitude
        let y = sin(lam1 - lam2) * cos(phi2)
        let x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(lam1-lam2)
        return atan2(y, x).radiansToDegrees
    }
    
    static func makeFrom(coordinateSet: [(lat: Double, long: Double)])-> [CLLocationCoordinate2D] {
        return coordinateSet.map({ (lat: Double, long: Double) in
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        })
    }
}

extension CLLocationCoordinate2D: Hashable {
    public var hashValue: Int {
        get {
            return "Latitude:\(self.latitude),Longitude:\(self.longitude)".hashValue
        }
    }
}
