//
//  StoryViewController.swift
//  ARKit-Demo
//
//  Created by Alejandro Mendoza on 2/12/19.
//  Copyright © 2019 Alejandro Mendoza. All rights reserved.
//

import UIKit
import ARKit

enum gameState {
    case selectingPlane
    case viewingStory
}

class StoryViewController: UIViewController{

    @IBOutlet weak var crosshair: UIView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var objectName: UILabel!
    @IBOutlet weak var objectDescription: UILabel!
    
    var gameState: gameState = .selectingPlane
    
    var storyAnchorExtent: simd_float3? = nil
    
    var debugPlanes = [SCNNode]()
    
    var countries = [SCNNode]()
    
    var countryColors: [UIColor] = [.red, .blue, .green, .cyan]
    
    
    var viewCenter: CGPoint {
        let viewBounds = view.bounds
        return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crosshair.layer.cornerRadius = 10
        informationView.isHidden = true
        
        loadSceneModels()
        setupConfiguration()
    }
    
    func setupConfiguration(){
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
        sceneView.debugOptions = .showFeaturePoints
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .selectingPlane {
            if let hit = sceneView.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first{
                
                let hittedAnchor = hit.anchor as? ARPlaneAnchor
                
                storyAnchorExtent = hittedAnchor?.extent
                
                sceneView.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
                sceneView.debugOptions = []
                
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = []
                
                sceneView.session.run(configuration)
                
                gameState = .viewingStory
                removeDebugPlanes()
                
            }
        }
        
    }
    
    func loadSceneModels(){
        let storyScene = SCNScene(named: "StoryAssets.scnassets/Models/America.scn")!
        
        for childNode in storyScene.rootNode.childNodes {
            print("\"" + childNode.name! + "\"", terminator: ",")
            childNode.geometry?.firstMaterial = SCNMaterial()
            childNode.geometry?.firstMaterial?.diffuse.contents = countryColors.randomElement()!.withAlphaComponent(0.8)
            childNode.rotation = SCNVector4(0, 0, 0, 90)
            countries.append(childNode)
        }
        
    }
    
    func removeDebugPlanes(){
        for debugPlaneNode in debugPlanes {
            debugPlaneNode.removeFromParentNode()
        }
        debugPlanes = []
    }
    

}

extension StoryViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
            debugPlanes.append(plane)
            
            DispatchQueue.main.async {
                node.addChildNode(plane)
            }
        }
        else {
            DispatchQueue.main.async {
                [unowned self] in
                
                for country in self.countries {
                    country.scale = SCNVector3(0.1, 0.1, 0.1)
                    country.position = SCNVector3(0.39, 0, 0.7)
                    node.addChildNode(country)
                }
                
                node.position = SCNVector3(0, 0, 0)
            
                
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        if node.childNodes.count > 0 {
            updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            [unowned self] in
            switch self.gameState{
            case .selectingPlane:
                if let _ = self.sceneView?.hitTest(self.viewCenter, types: [.existingPlaneUsingExtent]).first {
                    self.crosshair.backgroundColor = UIColor.green
                }
                else {
                    self.crosshair.backgroundColor = UIColor.lightGray
                }
            case .viewingStory:
                
                if let hit = self.sceneView.hitTest(self.viewCenter, options: nil).first {
                    guard let nodeName = hit.node.name else {return}
                    
                    self.crosshair.backgroundColor = UIColor.green.withAlphaComponent(0.8)
                    self.informationView.isHidden = false
                    self.objectName.text = nodeName
                    
                    
                }
                else {
                    self.informationView.isHidden = true
                    self.crosshair.backgroundColor = UIColor.lightGray
                }
            }
        }
    }
    
}
