//
//  ThumbnailImages.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

@available(iOS 17, *)
struct ThumbnailImages: View {
	var manager: CameraManager
	let imageSize: Double = 50
	let badgeColor = Color.yellow
	let badgeTextColor = Color.white

	var body: some View {
		ZStack {
			ForEach(manager.savedImages.enumerated(), id: \.offset) { offset, image in
				Image(uiImage: image)
					.resizable()
					.frame(width: imageSize, height: imageSize)
					.offset(x: Double(offset * 2), y: Double(offset * 2))
					.aspectRatio(contentMode: .fit)
					.border(.black, width: 0.5)
			}
		}
		.overlay(alignment: .topTrailing) {
			if manager.savedImages.count > 0 {
				Text(manager.savedImages.count.formatted())
					.padding(6)
					.font(.caption.bold())
					.foregroundStyle(badgeTextColor)
					.background {
						Circle()
							.fill(badgeColor)
					}
					.offset(x: 12, y: -12)
			}
		}
	}
}

#endif


