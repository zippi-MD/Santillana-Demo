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
    case onGame
}

class StoryViewController: UIViewController{
    
    var countriesInfo = [String: Country]()
    
    //variables for game flow
    
    var questions = [CountryQuestion]()
    
    var actualQuestion: CountryQuestion!
    
    var leftLives: Int = 0
    
    // end variables for game flow
    @IBOutlet weak var crosshair: UIView!
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var countryName: UIView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    
    @IBOutlet weak var showFood: UIView!
    
    @IBOutlet weak var backToMap: UIView!
    
    @IBOutlet weak var scorePanel: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var foodInformation: UIView!
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    
    @IBOutlet weak var foodDescription: UILabel!
    
    @IBOutlet weak var selectCountry: UIView!
    @IBOutlet weak var questionPanel: UIView!
    @IBOutlet weak var questionTitle: UILabel!
    
    @IBOutlet weak var startGame: UIView!
    

    @IBOutlet weak var gameStateButton: UIButton!
    
    
    var gameState: gameState = .selectingPlane
    
    var storyAnchorExtent: simd_float3? = nil
    
    var storyAnchorCenter: simd_float3? = nil
    
    var debugPlanes = [SCNNode]()
    
    var countries = [SCNNode]()
    
    var countryColors: [UIColor] = [.red, .blue, .green, .cyan, .gray]
    
    var continent = SCNNode()
    
    var selectedContry: String?
    var selectedCountryHitPosition: SCNVector3?
    var selectedCountryOriginalPosition: SCNVector3?
    
    
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
        questionPanel.layer.cornerRadius = 10
        startGame.layer.cornerRadius = 10
        scorePanel.layer.cornerRadius = 10
        selectCountry.layer.cornerRadius = 10
        
        countryName.isHidden = true
        scorePanel.isHidden = true
        showFood.isHidden = true
        backToMap.isHidden = true
        foodInformation.isHidden = true
        questionPanel.isHidden = true
        startGame.isHidden = true
        
        //informationView.isHidden = true
        
        loadSceneModels()
        setupConfiguration()
        loadQuestions()
        loadCountries()
    }
    
    func setupConfiguration(){
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
        sceneView.debugOptions = .showFeaturePoints
        sceneView.showsStatistics = true
    }
    
    //Creo que queda mejor poner loadQuestions
    func loadQuestions(){
        //Aquí deberíamos de poner un un Forced Unwrap, porque si no existe el archivo no tiene sentido que la aplicación cargue
        let path = Bundle.main.path(forResource: "questions", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        
        let data = try? Data(contentsOf: url)
        
        questions = try! JSONDecoder().decode([CountryQuestion].self, from: data!)
        
    }
    
    //MARK: loadCountries
    
    func loadCountries(){
        let path = Bundle.main.path(forResource: "Countries", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        
        let data = try? Data(contentsOf: url)
        let countriesData = try! JSONDecoder().decode([Country].self, from: data!)
        
        for country in countriesData {
            countriesInfo[country.id] = country
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .selectingPlane {
            if let hit = sceneView.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first{
                
                let hittedAnchor = hit.anchor as? ARPlaneAnchor
                
                storyAnchorExtent = hittedAnchor?.extent
                storyAnchorCenter = hittedAnchor?.center
                
                sceneView.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
                sceneView.debugOptions = [.showBoundingBoxes]
                
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
            SCNTransaction.animationDuration = 0.5
            country.opacity = 1
            
            for food in country.childNodes {
                food.removeFromParentNode()
            }
            
            if country.name == selectedContry!{
                country.position = selectedCountryOriginalPosition!
            }
        }
        gameState = .viewingStory
        
        startGame.isHidden = false
        foodInformation.isHidden = true
        backToMap.isHidden = true
    }
    
    
    @IBAction func startGame(_ sender: UIButton) {
        if gameState != .onGame{
            gameState = .onGame
            self.leftLives = 3
            foodInformation.isHidden = true
            countryName.isHidden = true
            foodInformation.isHidden = true
            backToMap.isHidden = true
            
            questionPanel.isHidden = false
            scorePanel.isHidden = false
            
            gameStateButton.setTitle("Abandonar", for: .normal)
            
            startGame.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            //logic of game
            
            actualQuestion = self.questions.randomElement()!
            questionTitle.text = actualQuestion.question
        }else{
            gameState = .viewingStory
            questionPanel.isHidden = true
            scorePanel.isHidden = true
            gameStateButton.setTitle("Juego", for: .normal)
            
            startGame.backgroundColor = backToMap.backgroundColor
        }
    }
    
    @IBAction func selectAnswer(_ sender: UIButton) {
        guard let hit = self.sceneView.hitTest(self.viewCenter, options: nil).first else {
            let alert = UIAlertController(title: nil, message: "Porfavor apunta hacia un país.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
            return
            
        }
        guard let nodeName = hit.node.name else { return }
        if cleanCountryName(nodeName) == actualQuestion.answer{
            print("Respuesta correcta")
        }else{
            self.leftLives -= 1
        }
        self.actualQuestion = self.questions.randomElement()!
        self.questionTitle.text = actualQuestion.question
    }
    
    @IBAction func showFood(_ sender: Any) {
        
        backToMap.isHidden = false
        
        gameState = .countrySelected
        
        showFood.isHidden = true
        
        questionPanel.isHidden = true
        
        startGame.isHidden = true
        
        guard let countryName = selectedContry else { return }
        
        
        for country in continent.childNodes {
            if country.name != countryName {
                SCNTransaction.animationDuration = 0.5
                country.opacity = 0
            }
            else {
                
                selectedCountryOriginalPosition = country.position
                
                var foodPosition = SCNVector3(selectedCountryHitPosition!.x - (country.boundingBox.max.z)/2, selectedCountryHitPosition!.y, selectedCountryHitPosition!.z - (country.boundingBox.max.x)/2)

                //make a fruits
                let apple = SCNNode(geometry: SCNSphere(radius: 0.04))
                apple.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                apple.name = "Food-Manzana-manzana-Fruto del manzano, comestible, de forma redondeada y algo hundida por los extremos, piel fina, de color verde, amarillo o rojo, carne blanca y jugosa, de sabor dulce o ácido, y semillas en forma de pepitas encerradas en una cápsula de cinco divisiones."
                
                
                
                apple.worldPosition = foodPosition
                
            
                let naranja = SCNNode(geometry: SCNSphere(radius: 0.04))
                naranja.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
                naranja.name = "Food-Naranja-naranja-Fruto del naranjo, comestible, de forma redonda, cáscara gruesa y rugosa y pulpa dividida en gajos, agridulce y muy jugosa."
                
                foodPosition = SCNVector3(selectedCountryHitPosition!.x + (country.boundingBox.max.z)/2, selectedCountryHitPosition!.y, selectedCountryHitPosition!.z + (country.boundingBox.max.x)/2)
                
                
                naranja.worldPosition = foodPosition
                
                
                let banana = SCNNode(geometry: SCNSphere(radius: 0.04))
                banana.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
                banana.name = "Food-Platano-platano-Fruto del platanero, comestible, de forma alargada y algo curvada, pulpa de color blanco y piel lisa de color amarillo que se desprende con facilidad."
                
                foodPosition = SCNVector3(selectedCountryHitPosition!.x - (country.boundingBox.max.z)/2, selectedCountryHitPosition!.y, selectedCountryHitPosition!.z + (country.boundingBox.max.x)/2)
                
                
                banana.worldPosition = foodPosition
                
                
                let pear = SCNNode(geometry: SCNSphere(radius: 0.04))
                pear.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                pear.name = "Food-Pera-pera-Fruto del peral, comestible, de color verde, amarillo o encarnado, ancho por la parte de abajo y delgado por la de arriba (donde tiene el pedúnculo), de piel fina y pulpa blanca, muy jugosa, sabor dulce y, en el centro, unas semillas pequeñas de color negro."
                
                foodPosition = SCNVector3(selectedCountryHitPosition!.x + (country.boundingBox.max.z)/2, selectedCountryHitPosition!.y, selectedCountryHitPosition!.z - (country.boundingBox.max.x)/2)
                
                
                pear.worldPosition = foodPosition
                
                
                

                country.addChildNode(naranja)
                naranja.scale = SCNVector3(10, 10 , 10)
                
                country.addChildNode(apple)
                apple.scale = SCNVector3(10, 10, 10)
                
                country.addChildNode(banana)
                banana.scale = SCNVector3(10, 10, 10)
                
                country.addChildNode(pear)
                pear.scale = SCNVector3(10, 10, 10)
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
                self.continent.scale = SCNVector3(x: 1.0, y: 0.3, z: 1.0)
                
                self.continent.position = SCNVector3(planeExtention.z/2, 0, planeExtention.z/2)
                
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
                    
                    self.selectedCountryHitPosition = hit.localCoordinates
                    
                    self.selectedContry = nodeName
                    
                    self.countryImage.image = nil
                    
                    
                    if let imageName = self.countriesInfo[nodeName]?.flag.uppercased() {
                        if let image = UIImage(named: imageName){
                            self.countryImage.image = image
                        }
                    }
                

                    
                    if !nodeName.contains("Food"){
                        let countryName = self.countriesInfo[nodeName]?.name ?? "Otro país"
                        self.countryNameLabel.text = countryName
                    }
                    
                    
                    self.crosshair.backgroundColor = UIColor.green.withAlphaComponent(0.8)
                    
                    
                    self.countryName.isHidden = false
                    self.countryImage.isHidden = false
                    self.startGame.isHidden = false
                    self.showFood.isHidden = false
                    
                    
                }
                else {
                    
                    self.selectedContry = nil
                    
                    self.countryName.isHidden = true
                    self.countryImage.isHidden = true
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
                    self.backToMap.isHidden = true
                    
                    self.crosshair.backgroundColor = UIColor.green.withAlphaComponent(0.8)
                }
                else {
                    
                    self.foodInformation.isHidden = true
                    self.backToMap.isHidden = false
                    self.crosshair.backgroundColor = UIColor.lightGray
                    
                }
                
            case .onGame:
                if self.leftLives > 0{
                    if let hit = self.sceneView.hitTest(self.viewCenter, options: nil).first{
                        guard let nodeName = hit.node.name else { return }
                        
                        self.crosshair.backgroundColor = UIColor.green.withAlphaComponent(0.8)
                        
                        self.countryNameLabel.text = self.countriesInfo[nodeName]?.name
                        
                        //hay que hacer una función porque se usa en varias partes
                        self.countryImage.image = nil
                        if let imageName = self.countriesInfo[nodeName]?.flag.uppercased() {
                            if let image = UIImage(named: imageName){
                                self.countryImage.image = image
                            }
                        }
                        
                        self.scoreLabel.text = String(self.leftLives)
                        
                        self.countryName.isHidden = false
                        
                    }else{
                        self.countryName.isHidden = true
                        self.crosshair.backgroundColor = .lightGray
                    }
                }else{
                    //alert end game
                    let alert = UIAlertController(title: "Fin del juego", message: "Se han acabado todas tus vidas", preferredStyle: .alert)
                    let backAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(backAction)
                    self.present(alert, animated: true, completion: nil)
                    //
                    self.gameState = .viewingStory
                    self.questionPanel.isHidden = true
                    self.scorePanel.isHidden = true
                    self.gameStateButton.setTitle("Juego", for: .normal)
                    
                    self.startGame.backgroundColor = self.backToMap.backgroundColor
                }
                
            }
        }
    }
    
}
