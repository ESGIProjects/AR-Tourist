//
//  Place.swift
//  ARProject
//
//  Created by Jason Pierna on 14/05/2018.
//  Copyright © 2018 Jason Pierna. All rights reserved.
//

import Foundation
import CoreLocation
import ARKit

class Place {
	var name: String
	var location: CLLocation
	var rating: Double?
	var anchor: ARAnchor?
	var address: String?
	
	init(name: String, location: CLLocation) {
		self.name = name
		self.location = location
	}
}
