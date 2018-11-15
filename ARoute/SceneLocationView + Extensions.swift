//
//  OccludingSceneLocationView.swift
//  ARoute
//
//  Created by Edmund Holderbaum on 11/9/18.
//  Copyright © 2018 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation
import ARCL
import ARKit

extension SceneLocationView {
    
    func runWithVerticalDetection() {
        
        run() //need to call this to activate the timers
        session.pause()
        
        // Create a *new* session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        if orientToTrueNorth {
            configuration.worldAlignment = .gravityAndHeading
        } else {
            configuration.worldAlignment = .gravity
        }
        
        debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Run the view's session *again*
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        guard let plane = anchor as? ARPlaneAnchor,
//            let device = renderer.device,
//            let geometry = ARSCNPlaneGeometry(device: device)
//            else { return nil }
//        geometry.update(from: plane.geometry)
//        let maskMaterial = SCNMaterial()
//        maskMaterial.colorBufferWriteMask = []
//        geometry.materials = [maskMaterial]
//        let node = SCNNode(geometry: geometry)
//        node.renderingOrder = -1
//        return node
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = anchor as? ARPlaneAnchor,
            let geometry = node.geometry as? ARSCNPlaneGeometry
            else { return }
        geometry.update(from: plane.geometry)
        node.boundingBox = planeBoundary(extent: plane.extent)
    }
    
    private func planeBoundary(extent: float3) -> (min: SCNVector3, max: SCNVector3) {
        let radius = extent * 0.5
        return (min: SCNVector3(-radius), max: SCNVector3(radius))
    }
}
