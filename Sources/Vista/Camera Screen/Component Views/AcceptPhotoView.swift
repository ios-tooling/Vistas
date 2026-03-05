//
//  AcceptPhotoView.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import CrossPlatformKit

@available(iOS 17, *)
struct AcceptPhotoView: View {
	let manager: any CameraManaging
	let image: UXImage?
	var animationNamespace: Namespace.ID
	@Environment(\.dismiss) var dismiss

	var body: some View {
		ZStack {
			if let image, !manager.isSavingImage {
				Image(uxImage: image)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.matchedGeometryEffect(id: "keepImage", in: animationNamespace, isSource: true)
					.frame(maxHeight: .infinity, alignment: .center)
			}

			HStack {
				Button("Retake") {
					withAnimation { manager.capturedImage = nil }
				}
				Spacer()
				Button("Keep") {
					keepImage()
				}
			}
			.buttonStyle(.bordered)
			.padding()
			.tint(.primary)
			.frame(maxHeight: .infinity, alignment: .top)
			.opacity(manager.isSavingImage ? 0 : 1)
		}
		.background {
			Color.systemBackground
				.ignoresSafeArea()
				.opacity(manager.isSavingImage ? 0 : 1)
		}
		.opacity(image == nil ? 0 : 1)
	}

	private func keepImage() {
		guard let image else { return }
		
		if manager.imageCountLimit == 1 {
			manager.saveImage(image)
			manager.finish()
			dismiss()
		} else {
			withAnimation(.easeInOut(duration: 0.4)) {
				manager.isSavingImage = true
			} completion: {
				manager.saveImage(image)
			}
		}
	}
}

#endif
