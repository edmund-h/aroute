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
    var lines: [SCNNode?] {
        return Array(nodesAndLines.values)
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNodes {
            print("run")
            //sceneLocationView.runWithVerticalDetection()
            self.sceneLocationView.run()
        }
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
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
       
        makeLinesForNodes()
    }
    
    func lineFrom(_ vector1: SCNVector3, to vector2: SCNVector3, radius: CGFloat = 1) -> SCNNode{
        
        let lengthVector = vector1 - vector2
        let length = lengthVector.length()
        let line = SCNCylinder(radius: radius, height: CGFloat(length))
        line.radialSegmentCount = 24
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
    
    func getNodes(then completion: @escaping ()->()) {
        NodeFactory.buildDemoData(completion: { nodes in
            self.nodes.forEach({
                self.sceneLocationView.removeLocationNode(locationNode: $0)
            })
            self.lines.forEach({
                $0?.removeFromParentNode()
            })
            self.setNodes(nodes)
            completion()
        })
    }
}
