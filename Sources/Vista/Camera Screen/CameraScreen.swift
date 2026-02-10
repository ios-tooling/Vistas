//
//  CameraScreen.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

public extension Color {
	static let cameraTint = Color(hex: 0xe2ad08)
}

@available(iOS 17, *)
public struct CameraScreen: View {
	@State var manager: any CameraManaging
	@State var isReviewingPhotos = false
	@Namespace private var animationNamespace
	let onImagesCaptured: (@MainActor ([UXImage]) -> Void)?
	var tintColor = Color(hex: 0xe2ad08)

	public init(manager: any CameraManaging = CameraManager.instance, tintColor: Color = .cameraTint, onImagesCaptured: (@MainActor ([UXImage]) -> Void)? = nil) {
		_manager = State(initialValue: manager)
		self.onImagesCaptured = onImagesCaptured
		self.tintColor = tintColor
	}

	public var body: some View {
		ZStack {
			CameraView(manager: manager, onImagesCaptured: onImagesCaptured)

			HStack {
				let thumbnails = ThumbnailImages(manager: manager, isReviewingPhotos: $isReviewingPhotos, animationNamespace: animationNamespace)

				Spacer()
				thumbnails
				Spacer()
				TakePictureButton(manager: manager)
				Spacer()
				thumbnails.opacity(0)
				Spacer()
			}
			.padding(.bottom)
			.frame(maxHeight: .infinity, alignment: .bottom)

			CropView(manager: manager, image: manager.capturedImage, animationNamespace: animationNamespace)
			if isReviewingPhotos {
				ReviewPhotosView(manager: manager, isVisible: $isReviewingPhotos)
			}
		}
		.toolbar(manager.capturedImage == nil ? .visible : .hidden)
		.onDisappear {
			manager.reset()
		}
		.tint(tintColor)
	}
}

#endif
