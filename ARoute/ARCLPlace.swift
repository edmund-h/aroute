//
//  ARCLPlacemark.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/6/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import MapKit
import ARCL

class ARCLPlace: LocationAnnotationNode {
    var clPlacemark: CLPlacemark
    
    var mkPlacemark: MKPlacemark {
        return MKPlacemark(placemark: clPlacemark)
    }
    
    var mapItem: MKMapItem {
        return MKMapItem(placemark: mkPlacemark)
    }
    
    var coordinate: CLLocationCoordinate2D? {
        return clPlacemark.location?.coordinate
    }
    
    var altitude: CLLocationDistance? {
        return clPlacemark.location?.altitude
    }
    
    init(placemark: CLPlacemark) {
        self.clPlacemark = placemark
        super.init(location: clPlacemark.location, image: #imageLiteral(resourceName: "down-arrow-2"))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
