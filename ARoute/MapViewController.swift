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
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.setUserTrackingMode(.follow, animated: false)
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
        if let origin = RoutingClient.lastOrigin {
            mapView.addAnnotation(origin.mkPlacemark)
        }
        if let destination = RoutingClient.lastDestination {
            mapView.addAnnotation(destination.mkPlacemark)
        }
        route.steps.forEach({ step in
            let annotation = MKPlacemark(coordinate: step.polyline.coordinate)
            mapView.addAnnotation(annotation)
        })
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPlacemark {
            return MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotation")
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline),
            let polyline = overlay as? MKPolyline {
            let addr = polyline.points()
            
//            let pointee = addr.pointee
//            var pointsArray: [MKMapPoint] = []
//            while pointee is MKMapPoint {
//
//                print(pointee)
//            }
//            print("\(pointCount)")
            let red = UIColor.red.withAlphaComponent(0.75)
            polylineRenderer.strokeColor = red
            polylineRenderer.lineWidth = 5
        }
        return polylineRenderer
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text
        if textField == originTextField {
            RoutingClient.originAddress = text
        } else {
            RoutingClient.destAddress = text
        }
        NodeFactory.buildDemoData(completion: { nodes in
            let name = Notification.Name.init("newNodes")
            NotificationCenter.default.post(name: name, object: nil, userInfo: [name:nodes])
            if let route = RoutingClient.lastRoute {
                self.plotRoute(route)
            }
        })
        textField.resignFirstResponder()
        return true
    }
}
