//
//  CLLocationCoordinate2D + Extensions.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/16/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D {
    
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
}
