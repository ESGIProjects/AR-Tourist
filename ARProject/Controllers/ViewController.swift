//
//  ViewController.swift
//  ARProject
//
//  Created by Jason Pierna on 14/05/2018.
//  Copyright © 2018 Jason Pierna. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreLocation
import GameplayKit
import SwiftyJSON
import MapKit

class ViewController: UIViewController {
    
	var sceneView: ARSKView!
	
	let locationManager = CLLocationManager()
	var userLocation = CLLocation()
//	var userLocation = CLLocation(latitude: 48.8471823389362, longitude: 2.27918617147502)
	
	var placesJSON: JSON!
	
	var userHeading = 0.0
	var userHeadingCount = 0
	
	var places = [UUID: Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupLayout()
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
	}
	
	func downloadData() {
		let stringURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAWxsQwFDY2qmM4p36Dsqnbm5evpLmMV88&location=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&type=bar&rankby=distance"
		guard let url = URL(string: stringURL) else { return }
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		let session = URLSession(configuration: .default)
		session.dataTask(with: request) { [unowned self] data, _, error in
			if let data = data {
				print(data)
				self.placesJSON = JSON(data)
				
				self.locationManager.startUpdatingHeading()
				
			} else if let error = error {
				print(error.localizedDescription)
			}
		}.resume()
	}
	
	func renderPlaces() {
		removeAllPlaces()
		
		for result in placesJSON["results"].arrayValue {
			// Retrieve coordinates
			let latitude = result["geometry"]["location"]["lat"].doubleValue
			let longitude = result["geometry"]["location"]["lng"].doubleValue
			
			// Comppute distance from user, azimuth and angle
			let location = CLLocation(latitude: latitude, longitude: longitude)
			let distance = Float(userLocation.distance(from: location))
			let azimuth = userLocation.direction(to: location)
			
			let angle = (azimuth - userHeading).radians
			
			let rotationHorizontal = simd_float4x4(SCNMatrix4MakeRotation(Float(angle), 1, 0, 0))
			let rotationVertical = simd_float4x4(SCNMatrix4MakeRotation(computeVertical(from: angle), 0, 1, 0))
			
			let rotation = simd_mul(rotationHorizontal, rotationVertical)
			
			guard let frame = sceneView.session.currentFrame else { print("No frame"); continue }
			let cameraRotation = simd_mul(frame.camera.transform, rotation)

			// Placing POI on camera
			var translation = matrix_identity_float4x4
			translation.columns.3.z = -(distance / 400)
			let transform = simd_mul(cameraRotation, translation)

			let anchor = ARAnchor(transform: transform)
			sceneView.session.add(anchor: anchor)
			
			// Storing Place object
			let place = Place(name: result["name"].stringValue, location: location)
			place.rating = result["rating"].double
			place.anchor = anchor
			place.address = result["vicinity"].string
			
			places[anchor.identifier] = place
		}
	}
	
	func computeVertical(from angle: Double) -> Float {
		let degrees = angle.degrees
		let range = (degrees - 45)...(degrees + 45)
		var numberOfItemsInRange: Double = 0
		
		for place in places.values {
			let distance = Float(userLocation.distance(from: place.location))
			let azimuth = userLocation.direction(to: place.location)
			
			let angle = azimuth - userHeading
			
			if range.contains(angle) {
				numberOfItemsInRange += 1
			}
		}
		
//		-0.2 + Float(distance / 4000)
		return -0.2 + Float(numberOfItemsInRange * 0.05)
	}
	
	func removeAllPlaces() {
		for place in places.values {
			guard let anchor = place.anchor else { continue }
			sceneView.session.remove(anchor: anchor)
		}
		
		places.removeAll()
	}
}
