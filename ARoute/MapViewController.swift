//
//  MapViewController.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/6/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if let route = RoutingClient.lastRoute {
            plotRoute(route)
        }
    }
    
    func plotRoute(_ route: MKRoute) {
        mapView.addOverlay(route.polyline)
        let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        mapView.setVisibleMapRect(
            route.polyline.boundingMapRect,
            edgePadding: insets,
            animated: false
        )
    }
}

extension MapViewController: MKMapViewDelegate {
    
}
