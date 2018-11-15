//
//  ViewController.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/6/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit
import ARCL

class SceneViewController: UIViewController {
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    @IBOutlet weak var label: UILabel!
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var nodesAndLines: [LocationAnnotationNode : SCNNode?] = [:]
    var nodesOrdered: [Int : LocationAnnotationNode] = [:]
    var nodes: Nodes {
        return Array(nodesAndLines.keys)
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
            self.setNodes(nodes)
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
            let nodes = userInfo[name] as? OrderedNodes {
            setNodes(nodes)
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
        let sceneview = sceneLocationView as ARSCNView
        if let anchor = sceneview.anchor(for: node) {
            sceneview.session.add(anchor: anchor)
        }
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        debugNorthDirection()
        //addAnchorsToNodes()
        makeLinesForNodes()
    }
    
    func addAnchorsToNodes() {
        nodesOrdered.values.forEach({ node in
        })
    }
    
    func lineFrom(_ vector1: SCNVector3, to vector2: SCNVector3, radius: CGFloat = 1) -> SCNNode{
        
        let lengthVector = vector1 - vector2
        let length = lengthVector.length()
        let line = SCNCylinder(radius: radius, height: CGFloat(length))
        line.radialSegmentCount = 12
        let node = SCNNode(geometry: line)
        node.position = (vector1 + vector2)/2
        node.eulerAngles = SCNVector3.lineEulerAngles(vector: lengthVector)
        return node
    }
    
    func setNodes(_ newNodes: OrderedNodes) {
        nodesAndLines = [:]
        nodesOrdered = newNodes
        newNodes.values.forEach({
            sceneLocationView?.addLocationNodeWithConfirmedLocation(
                locationNode: $0
            )
        })
        makeLinesForNodes()
    }
    
    func makeLinesForNodes() {
        nodesOrdered.keys.forEach({ index in
            if let thisNode = nodesOrdered[index - 1],
                let nextNode = nodesOrdered[index] {
                let nextNodePosition = nextNode.position
                let thisNodePosition = thisNode.position
                let lineNode = lineFrom(thisNodePosition, to: nextNodePosition)
                lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.9)
                sceneLocationView.scene.rootNode.addChildNode(lineNode)
                if let oldLineOpt = nodesAndLines[thisNode], let oldLine = oldLineOpt {
                    oldLine.removeFromParentNode()
                }
                nodesAndLines[thisNode] = lineNode
            }
        })
    }
    
    func debugNorthDirection() {
        //this function from github is 3 feet more accurate than what is currently in the pod : [
        let now = mapView.userLocation.coordinate
        
        let coord = now.coordinateWithBearing(bearing: 0, distanceMeters: 500)
        let newcoord = now.newWayCoordinateWithBearing(bearing: 0, distanceMeters: 500)
        
        let latDelta = coord.latitude - newcoord.latitude
        let lonDelta = coord.longitude - newcoord.longitude
        let latDeltaStr = String(format: "latitude: %.20f", latDelta)
        let lonDeltaStr = String(format: "longitude: %.20f", lonDelta)
        print("\(latDeltaStr), \(lonDeltaStr)")
    }
}

extension CLLocationCoordinate2D {
    
    public func newWayCoordinateWithBearing(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        // formula by http://www.movable-type.co.uk/scripts/latlong.html
        let lat1 = self.latitude * Double.pi / 180
        let lon1 = self.longitude * Double.pi / 180
        
        let distance = distanceMeters / Constants.earthRadius
        let angularBearing = bearing * Double.pi / 180
        
        var lat2 = lat1 + distance * cos(angularBearing)
        let dLat = lat2 - lat1
        let dPhi = log(tan(lat2 / 2 + Double.pi/4) / tan(lat1 / 2 + Double.pi/4))
        let q = (dPhi != 0) ? dLat/dPhi : cos(lat1)  // E-W line gives dPhi=0
        let dLon = distance * sin(angularBearing) / q
        
        // check for some daft bugger going past the pole
        if fabs(lat2) > Double.pi/2 {
            lat2 = lat2 > 0 ? Double.pi - lat2 : -(Double.pi - lat2)
        }
        var lon2 = lon1 + dLon + 3 * Double.pi
        while lon2 > 2 * Double.pi {
            lon2 -= 2 * Double.pi
        }
        lon2 -= Double.pi
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}
