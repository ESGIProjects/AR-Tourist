//
//  Scene.swift
//  ARProject
//
//  Created by Jason Pierna on 16/05/2018.
//  Copyright © 2018 Jason Pierna. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
	
	weak var viewController: ViewController?
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let sceneView = self.view as? ARSKView else { return }
		
		if viewController?.posterPosition != nil, let currentFrame = sceneView.session.currentFrame {
			
			guard let touch = touches.first else { return }
			
			let location = touch.location(in: self)
			let hit = nodes(at: location)
			
			if let node = hit.first {
				editObject(sceneView: sceneView, node: node)
			} else {
				addNewObject(sceneView: sceneView, currentFrame: currentFrame)
			}
		}
	}
	
	func addNewObject(sceneView: ARSKView, currentFrame: ARFrame) {
		// Create a transform with a translation of 10 cms in front of the camera
		var translation = matrix_identity_float4x4
		translation.columns.3.z = -0.2
		let transform = simd_mul(currentFrame.camera.transform, translation)
		
		let alert = UIAlertController(title: "Nouvel objet", message: nil, preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "Nom"
		}
		
		alert.addTextField { textField in
			textField.placeholder = "Emoji"
		}
		
		alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
		
		alert.addAction(UIAlertAction(title: "Ajouter", style: .default, handler: { action in
			guard let nameTextField = alert.textFields?[0] else { return }
			guard let emojiTextField = alert.textFields?[1] else { return }
			
			guard let name = nameTextField.text, let emoji = emojiTextField.text else { return }
			
			let anchor = ARAnchor(transform: transform)
			let item = ARItem(anchor: anchor, name: name, emoji: emoji)
			
			self.viewController?.items[anchor.identifier] = item
			sceneView.session.add(anchor: anchor)
		}))
		
		viewController?.present(alert, animated: true)
	}
	
	func editObject(sceneView: ARSKView, node: SKNode) {
		guard let anchor = sceneView.anchor(for: node) else { return }
		guard let item = viewController?.items[anchor.identifier] else { return }
		
		let alert = UIAlertController(title: "Suppression", message: "Supprimer \(item.name) \(item.emoji) ?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
		alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive) { _ in
			node.removeFromParent()
			sceneView.session.remove(anchor: anchor)
			self.viewController?.items.removeValue(forKey: anchor.identifier)
		})
		
		viewController?.present(alert, animated: true)
	}
}
