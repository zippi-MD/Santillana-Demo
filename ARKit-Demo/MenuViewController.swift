//
//  MenuViewController.swift
//  ARKit-Demo
//
//  Created by Alejandro Mendoza on 3/12/19.
//  Copyright © 2019 Alejandro Mendoza. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var santillanaView: UIView!
    
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var buttonGradientView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToArExperience(sender:)))
        
        startView.addGestureRecognizer(tapGesture)
        
        
//        startView.layer.cornerRadius = 10
//        startView.layer.borderWidth = 3
//        startView.layer.borderColor = UIColor(red: 126/255, green: 211/255, blue: 247/255, alpha: 1.0).cgColor
        
        let titleGradient = generateGradientForView(view: titleView, colors: [UIColor(red: 236/255, green: 77/255, blue: 34/255, alpha: 1.0).cgColor, UIColor(red: 253/255, green: 185/255, blue: 19/255, alpha: 1.0).cgColor])
        
        titleView.layer.addSublayer(titleGradient)
        
        let title = UILabel(frame: titleView.bounds)
        title.text = "Experiencia  AR"
        title.font = UIFont.boldSystemFont(ofSize: 120)
        title.textAlignment = .left
        
        titleView.addSubview(title)
        titleView.mask = title
        
        
        let santillanaGradient = generateGradientForView(view: titleView, colors: [UIColor(red: 236/255, green: 77/255, blue: 34/255, alpha: 1.0).cgColor, UIColor(red: 253/255, green: 185/255, blue: 19/255, alpha: 1.0).cgColor])
        
        santillanaView.layer.addSublayer(santillanaGradient)
        
        let santillana = UILabel(frame: santillanaView.bounds)
        santillana.text = "Santillana"
        santillana.font = UIFont.boldSystemFont(ofSize: 130)
        santillana.textAlignment = .center
        
        santillanaView.addSubview(santillana)
        santillanaView.mask = santillana
        
        
        let startGradient = generateGradientForView(view: startView, colors: [UIColor(red: 25/255, green: 40/255, blue: 108/255, alpha: 1.0).cgColor, UIColor(red: 126/255, green: 211/255, blue: 247/255, alpha: 1.0).cgColor])
        
        buttonGradientView.layer.addSublayer(startGradient)
        
        buttonGradientView.mask = startButton
        
        
        
    }
    
    @objc func goToArExperience(sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "arexperience", sender: nil)
    }
    
    
    
    
    
    func generateGradientForView(view: UIView, colors: [CGColor]) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        gradient.frame = view.bounds
        
        return gradient
    }


}
