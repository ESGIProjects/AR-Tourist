//
//  ViewController.swift
//  ARProject
//
//  Created by Jason Pierna on 16/05/2018.
//  Copyright © 2018 Jason Pierna. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSKView!
	var scene: Scene?
	var posterPosition: matrix_float4x4?
	var anchors = [ARAnchor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
		
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") as? Scene {
            sceneView.presentScene(scene)
			self.scene = scene
			self.scene?.viewController = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
			fatalError("Missing expected asset catalog resources.")
		}
		
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
		configuration.detectionImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
	
	@IBAction func reset() {
		for anchor in anchors {
			sceneView.session.remove(anchor: anchor)
			print("Removed:", anchor)
		}
		
		Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
			for anchor in self.anchors {
				self.sceneView.session.add(anchor: anchor)
				print("Re-added:", anchor)
			}
			timer.invalidate()
		}
	}
}

// MARK: - ARSKViewDelegate
extension ViewController: ARSKViewDelegate {
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
		print(#function)
		
		if let imageAnchor = anchor as? ARImageAnchor {
			print("referenceImage name", imageAnchor.referenceImage.name ?? "Nope")
			
			posterPosition = imageAnchor.transform
			sceneView.session.setWorldOrigin(relativeTransform: imageAnchor.transform)
			
			Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
				self.sceneView.session.remove(anchor: anchor)
				timer.invalidate()
			}
			
			return nil
		}
		
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: "👾")
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode
    }
	
	func view(_ view: ARSKView, didRemove node: SKNode, for anchor: ARAnchor) {
		print(#function)
	}
}
