//
//  CapturedImage.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/9/26.
//

import Foundation
import CrossPlatformKit

public struct CapturedImage: Identifiable, Equatable {
	public let id = UUID()
	
	var image: UXImage
	
	init(_ image: UXImage) {
		self.image = image
	}
}
