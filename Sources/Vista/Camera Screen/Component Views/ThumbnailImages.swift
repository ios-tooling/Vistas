//
//  ThumbnailImages.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import CrossPlatformKit

@available(iOS 17, *)
struct ThumbnailImages: View {
	var manager: any CameraManaging
	@Binding var isReviewingPhotos: Bool

	var animationNamespace: Namespace.ID
	let imageSize: Double = 50
	let badgeColor = Color.yellow
	let badgeTextColor = Color.white
	@State private var bounceScale = 1.0

	var body: some View {
		Button(action: { isReviewingPhotos.toggle() }) {
			ZStack {
				ForEach(Array(manager.savedImages.enumerated()), id: \.offset) { offset, image in
					Image(uiImage: image.image)
						.resizable()
						.frame(width: imageSize, height: imageSize)
						.offset(x: Double(offset * 2), y: Double(offset * 2))
						.aspectRatio(contentMode: .fit)
						.border(.black, width: 0.5)
				}
				
				if manager.isSavingImage, let image = manager.capturedImage {
					Image(uxImage: image)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: imageSize, height: imageSize)
						.clipped()
						.border(.black, width: 0.5)
						.matchedGeometryEffect(id: "keepImage", in: animationNamespace, isSource: false)
						.offset(x: Double(manager.savedImages.count * 2), y: Double(manager.savedImages.count * 2))
				}
			}
			.scaleEffect(bounceScale)
			.onChange(of: manager.savedImages.count) { old, new in
				guard new > old else { return }
				withAnimation(.spring(duration: 0.2, bounce: 0.5)) {
					bounceScale = 1.15
				} completion: {
					withAnimation(.spring(duration: 0.35, bounce: 0.6)) {
						bounceScale = 1.0
					}
				}
			}
			.overlay(alignment: .topTrailing) {
				if manager.savedImages.count > 1 {
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
		.buttonStyle(.plain)
	}
}


#endif
