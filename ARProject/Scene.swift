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
	
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
		
		
				
		// Create anchor using the camera's current position
		if viewController?.posterPosition != nil, let currentFrame = sceneView.session.currentFrame {
            // Create a transform with a translation of 10 cms in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.1
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
				self.viewController?.sceneView.session.add(anchor: anchor)
			}))
			
			viewController?.present(alert, animated: true)
		}
    }
}
