//
//  ViewController+ARSKViewDelegate.swift
//  ARProject
//
//  Created by Jason Pierna on 14/05/2018.
//  Copyright © 2018 Jason Pierna. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit
import CoreLocation

extension ViewController: ARSKViewDelegate {
	
	func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
		guard let place = places[anchor.identifier] else { return nil }
		
		let labelNode = SKLabelNode(text: place.name)
		labelNode.horizontalAlignmentMode = .center
		labelNode.verticalAlignmentMode = .center

		let size = labelNode.frame.size.applying(CGAffineTransform(scaleX: 1.1, y: 1.4))
		let backgroundNode = SKShapeNode(rectOf: size, cornerRadius: 10)

		backgroundNode.fillColor = UIColor(hue: CGFloat(GKRandomSource.sharedRandom().nextUniform()), saturation: 0.5, brightness: 0.4, alpha: 0.9)

		backgroundNode.strokeColor = backgroundNode.fillColor.withAlphaComponent(1)
		backgroundNode.lineWidth = 2

		backgroundNode.addChild(labelNode)
		return backgroundNode
	}
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.requestLocation()
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error.localizedDescription)
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		
		if userLocation.distance(from: location) > 200 {
			userLocation = location
			
			DispatchQueue.global().async { [weak self] in
				self?.downloadData()
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		
		userHeadingCount += 1
		if userHeadingCount != 2 { return }
		
		userHeading = newHeading.magneticHeading
		locationManager.stopUpdatingHeading()
		
		DispatchQueue.main.async { [weak self] in
			self?.renderPlaces()
		}
	}
}
