//
//  File.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

import Foundation

#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

@available(iOS 17, *)
public struct CropView: View {
	let manager: CameraManager
	let image: UXImage?
	
	public var body: some View {
		ZStack {
			if let image {
				Image(uxImage: image)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(maxHeight: .infinity, alignment: .center)
			}

			HStack {
				Button("Retake") {
					withAnimation { manager.capturedImage = nil }
				}
				Spacer()
				Button("Keep") {
					if let image {
						manager.savedImages.append(image)
						withAnimation { manager.capturedImage = nil }
					}
				}
			}
			.buttonStyle(.bordered)
			.padding()
			.tint(.primary)
			.frame(maxHeight: .infinity, alignment: .top)
		}
		.background {
			Color.systemBackground
				.ignoresSafeArea()
		}
		.opacity(image == nil ? 0 : 1)
	}
}

#endif
