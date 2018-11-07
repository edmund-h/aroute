//
//  ViewController.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/6/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit
import SceneKit
import MapKit
import ARCL

class SceneViewController: UIViewController {
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    @IBOutlet weak var label: UILabel!
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var nodes: Nodes = [] {
        didSet {
            nodes.forEach({
                sceneLocationView?.addLocationNodeWithConfirmedLocation(
                    locationNode: $0
                )
            })
        }
    }
    
    var updateUserLocationTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
        //        sceneLocationView.orientToTrueNorth = false
        
        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        sceneLocationView?.showAxesNode = false
        sceneLocationView?.locationDelegate = self
        
        let name = Notification.Name.init("newNodes")
        NotificationCenter.default.addObserver(self, selector: #selector(addNewNodes(_:)), name: name, object: nil)
        
        NodeFactory.buildDemoData(completion: { nodes in
            self.nodes.forEach({
                self.sceneLocationView.removeLocationNode(locationNode: $0)
            })
            self.nodes = nodes
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    @IBAction func setNorth() {
        mapView.setUserTrackingMode(.follow, animated: false)
        guard let heading = mapView.userLocation.heading else {return}
        let upperBound =  heading.trueHeading < 1.0
        let lowerBound = heading.trueHeading > -1.0
        if upperBound && lowerBound {
            var sceneFacingDegrees = sceneLocationView.sceneNode?.eulerAngles.y.radiansToDegrees ?? 0
            while sceneFacingDegrees > 180 {
                sceneLocationView.moveSceneHeadingAntiClockwise()
                sceneFacingDegrees = sceneLocationView.sceneNode?.eulerAngles.y.radiansToDegrees ?? 0
            }
            while sceneFacingDegrees < 180 {
                sceneLocationView.moveSceneHeadingClockwise()
                sceneFacingDegrees = sceneLocationView.sceneNode?.eulerAngles.y.radiansToDegrees ?? 0
            }
        }
    }
    
    @objc func addNewNodes(_ notification: Notification) {
        let name = Notification.Name.init("newNodes")
        if let userInfo = notification.userInfo,
            let nodes = userInfo[name] as? Nodes {
            self.nodes = nodes
        }
        
    }
}


extension SceneViewController: SceneLocationViewDelegate {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //print("add scene location estimate, position: \(position), location: \(location.coordinate), Xaccuracy: \(location.horizontalAccuracy), Yaccuracy: \(location.verticalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
        //print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
}
