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
    case countrySelected
}

class StoryViewController: UIViewController{

    @IBOutlet weak var crosshair: UIView!
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var countryName: UIView!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var showFood: UIView!
    
    @IBOutlet weak var backToMap: UIView!
    
    @IBOutlet weak var foodInformation: UIView!
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    
    @IBOutlet weak var foodDescription: UILabel!
    
    
    var gameState: gameState = .selectingPlane
    
    var storyAnchorExtent: simd_float3? = nil
    
    var debugPlanes = [SCNNode]()
    
    var countries = [SCNNode]()
    
    var countryColors: [UIColor] = [.red, .blue, .green, .cyan, .gray]
    
    var continent = SCNNode()
    
    var selectedContry: String?
    
    
    var viewCenter: CGPoint {
        let viewBounds = view.bounds
        return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crosshair.layer.cornerRadius = 15
        countryName.layer.cornerRadius = 10
        showFood.layer.cornerRadius = 10
        backToMap.backgroundColor = showFood.backgroundColor
        backToMap.layer.cornerRadius = 10
        foodInformation.layer.cornerRadius = 10
        
        countryName.isHidden = true
        showFood.isHidden = true
        backToMap.isHidden = true
        foodInformation.isHidden = true
        
        //informationView.isHidden = true
        
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
    
    
    @IBAction func backToMap(_ sender: UIButton) {
        for country in continent.childNodes{
            country.isHidden = false
            if country.childNodes.count > 0 {
                for child in country.childNodes {
                    child.removeFromParentNode()
                }
            }
        }
        gameState = .viewingStory
        
        backToMap.isHidden = true
    }
    
    @IBAction func showFood(_ sender: Any) {
        
        backToMap.isHidden = false
        
        gameState = .countrySelected
        
        showFood.isHidden = true
        
        var countryPosition = SCNVector3(x: 0, y: 0, z: 0)
        
        guard let countryName = selectedContry else { return }
        
        for country in continent.childNodes {
            if country.name != countryName {
                country.isHidden = true
            }
            else {
                countryPosition = country.worldPosition
                print(country.position)
                print(country.worldPosition)
                print(country.worldOrientation)
                //make a fruits
                let someFruit = SCNNode(geometry: SCNSphere(radius: 0.03))
                someFruit.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                someFruit.name = "Food-Manzana-manzana-Fruto del manzano, comestible, de forma redondeada y algo hundida por los extremos, piel fina, de color verde, amarillo o rojo, carne blanca y jugosa, de sabor dulce o ácido, y semillas en forma de pepitas encerradas en una cápsula de cinco divisiones."
                someFruit.position = SCNVector3(countryPosition.x - 3, countryPosition.y, countryPosition.z - 10)
                
                let otherFruit = SCNNode(geometry: SCNSphere(radius: 0.03))
                otherFruit.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
                otherFruit.name = "Food-Naranja-naranja-Fruto del naranjo, comestible, de forma redonda, cáscara gruesa y rugosa y pulpa dividida en gajos, agridulce y muy jugosa."
                otherFruit.position = SCNVector3(countryPosition.x - 3, countryPosition.y, countryPosition.z - 11)
                
                country.addChildNode(otherFruit)
                country.addChildNode(someFruit)
                otherFruit.scale = SCNVector3(10,10,10)
                someFruit.scale = SCNVector3(10, 10, 10)
            }
            
        }
        
    }
    
    
    
    
    func cleanCountryName(_ name: String) -> String {
        let undesired = ["World", "Map", "South", "North", "America"]
        
        var cleanName = name
        
        for word in undesired {
            cleanName = cleanName.replacingOccurrences(of: word, with: "")
        }
        
        cleanName = cleanName.replacingOccurrences(of: "_", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanName
        
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
                
                let planeExtention = self.storyAnchorExtent!
                
                for country in self.countries {
                    country.scale = SCNVector3(0.1, 0.1, 0.1)
                    country.position = SCNVector3(0.39, 0, 0.7)
                    self.continent.addChildNode(country)
                }
                
                self.continent.scale = SCNVector3(x: planeExtention.z, y: 0.3, z: planeExtention.z)
                
                node.addChildNode(self.continent)
            
                
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
                    guard self.gameState != .countrySelected else {return}
                    
                    guard let nodeName = hit.node.name else {return}
                    
                    self.selectedContry = nodeName
                    
                    let countryName = self.cleanCountryName(nodeName)
                    
                    self.crosshair.backgroundColor = UIColor.green.withAlphaComponent(0.8)
                    self.countryNameLabel.text = countryName
                    
                    self.countryName.isHidden = false
                    self.showFood.isHidden = false
                    
                    
                }
                else {
                    
                    self.selectedContry = nil
                    
                    self.countryName.isHidden = true
                    self.showFood.isHidden = true
                    self.crosshair.backgroundColor = UIColor.lightGray
                }
            case .countrySelected:
                if let hit = self.sceneView.hitTest(self.viewCenter, options: nil).first {
                    
                    guard let nodeName = hit.node.name else {return}
                    
                    if !nodeName.contains("-"){ return }
                    
                    let data = nodeName.split(separator: "-")
                    
                    self.foodName.text = String(data[1])
                    self.foodImage.image = UIImage(named: String(data[2]))
                    self.foodDescription.text = String(data[3])
                    
                    self.foodInformation.isHidden = false
                    
                    self.crosshair.backgroundColor = UIColor.green.withAlphaComponent(0.8)
                }
                else {
                    
                    self.foodInformation.isHidden = true
                    self.crosshair.backgroundColor = UIColor.lightGray
                    
                }
                
            }
        }
    }
    
}
