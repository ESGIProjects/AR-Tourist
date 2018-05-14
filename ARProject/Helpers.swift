//
//  Helpers.swift
//  ARProject
//
//  Created by Jason Pierna on 14/05/2018.
//  Copyright © 2018 Jason Pierna. All rights reserved.
//

import Foundation
import CoreLocation

extension Double {
	var radians: Double {
		return self * .pi / 180.0
	}
	
	var degrees: Double {
		return self * 180.0 / .pi
	}
}

extension CLLocation {
	func direction(to location: CLLocation) -> Double {
		let lat1 = coordinate.latitude.radians
		let lon1 = coordinate.longitude.radians
		
		let lat2 = location.coordinate.latitude.radians
		let lon2 = location.coordinate.longitude.radians
		
		let lon_delta = lon2 - lon1
		let y = sin(lon_delta) * cos(lon2)
		let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon_delta)
		
		let radians = atan2(y, x)
		
		return radians.degrees
	}
}
