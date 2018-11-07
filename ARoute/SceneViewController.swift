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
            self.makeLinesForNodes()
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
            setNodes(nodes)
            makeLinesForNodes()
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
//        guard let pointOfView = sceneLocationView.pointOfView else { return }
//
//        let mat = pointOfView.transform
//        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
//        let currentPosition = pointOfView.position + (dir * SCNFloat(0.1))
//        locationNode.location.coordinate
//        if let thisNode = locationNode as? LocationAnnotationNode{
//        }
        makeLinesForNodes()
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
    
    func setNodes(_ newNodes: Nodes) {
        nodesAndLines = [:]
        nodesOrdered = [:]
        newNodes.forEach({
            sceneLocationView?.addLocationNodeWithConfirmedLocation(
                locationNode: $0
            )
        })
        newNodes.enumerated().forEach({index, node in
            nodesOrdered[index] = node
        })
        newNodes.forEach({ nodesAndLines[$0] = nil })
    }
    
    func makeLinesForNodes() {
        nodesOrdered.keys.forEach({ index in
            if let thisNode = nodesOrdered[index - 1],
                let nextNode = nodesOrdered[index] {
                let nextNodePosition = nextNode.position
                let thisNodePosition = thisNode.position
                let line = lineFrom(vector: nextNodePosition, toVector: thisNodePosition)
                let lineNode = SCNNode(geometry: line)
                lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.75)
                sceneLocationView.scene.rootNode.addChildNode(lineNode)
                if let oldLineOpt = nodesAndLines[thisNode], let oldLine = oldLineOpt {
                    oldLine.removeFromParentNode()
                }
                nodesAndLines[thisNode] = lineNode
                glLineWidth(20)
            }
        })
    }
}
