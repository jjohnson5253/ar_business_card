//
//  Created by Jake Johnson
//  Credits to https://github.com/abdvl/ARKit-Card-Detection-and-Animation
//  Credits to https://github.com/Rightpoint/ARKit-CoreML
//

import ARKit
import SceneKit
import UIKit

final class ARSceneViewController: UIViewController {

    var catNode:SCNNode?
    let catScene = SCNScene(named: "cat.scn")

    let detectionImages = ARReferenceImage.referenceImages(
        inGroupNamed: "AR Resources",
        bundle: nil
    )

    lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.delegate = self
        return sceneView
    }()
}

extension ARSceneViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        catNode = catScene?.rootNode

        title = "Very Business"

        view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        resetTracking()
    }

    func resetTracking() {
        let config = ARWorldTrackingConfiguration()
        config.detectionImages = detectionImages
        config.maximumNumberOfTrackedImages = 1
        config.isLightEstimationEnabled = true
        config.isAutoFocusEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

}

extension ARSceneViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            var shapeNode:SCNNode?
            
            shapeNode = catNode
            
            guard let shape = shapeNode else {return}

            node.addChildNode(shape)
    }

}

extension ARSceneViewController {

    /// Adds a plane atop `imageAnchor`
    func addIndicatorPlane(to imageAnchor: ARImageAnchor) {
        let node = sceneView.node(for: imageAnchor)
        let size = imageAnchor.referenceImage.physicalSize
        let geometry = SCNPlane(width: size.width, height: size.height)
        let plane = SCNNode(geometry: geometry)
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        plane.geometry?.firstMaterial?.fillMode = .lines
        plane.eulerAngles.x = -.pi / 2
        
        node?.addChildNode(plane)
    }

    // Adds a label below `node`
    func attachLabel(_ title: String, to node: SCNNode) {
        let geometry = SCNText(string: title, extrusionDepth: 0)
        geometry.flatness = 0.1
        geometry.firstMaterial?.diffuse.contents = UIColor.darkText
        let text = SCNNode(geometry: geometry)
        text.scale = .init(0.00075, 0.00075, 0.00075)
        text.eulerAngles.x = -.pi / 2
        let box = text.boundingBox
        text.pivot.m41 = (box.max.x - box.min.x) / 2.0
        text.position.z = node.boundingBox.max.z + 0.012 // 1 cm below card
        node.addChildNode(text)
    }

}
