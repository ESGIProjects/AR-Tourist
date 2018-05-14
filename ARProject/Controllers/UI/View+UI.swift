//
//  View+UI.swift
//  ARProject
//
//  Created by Jason Pierna on 14/05/2018.
//  Copyright © 2018 Jason Pierna. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
	class UI {
		class func sceneView() -> ARSKView {
			let view = ARSKView(frame: .zero)
			view.translatesAutoresizingMaskIntoConstraints = false
			
			view.showsFPS = true
			view.showsNodeCount = true
			
			return view
		}
	}
	
	func getConstraints() -> [NSLayoutConstraint] {
		return [
			sceneView.topAnchor.constraint(equalTo: view.topAnchor),
			sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		]
	}
	
	func setUIComponents() {
		sceneView = UI.sceneView()
		sceneView.delegate = self
	}
	
	func setupLayout() {
		setUIComponents()
		
		view.addSubview(sceneView)
		
		NSLayoutConstraint.activate(getConstraints())
	}
}
