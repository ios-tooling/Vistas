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
	var tintColor = Color(hex: 0xe2ad08)
	let closeOption: CloseButtonOption?

	@MainActor public init(manager: (any CameraManaging)? = nil, tintColor: Color = .cameraTint, closeOption: CloseButtonOption? = .xClose, imageCountLimit: Int? = 1, onImagesCaptured: (@MainActor ([UXImage]) -> Void)? = nil) {
		_manager = State(initialValue: manager ?? CameraManager.instance)
		_manager.wrappedValue.onImagesCaptured = onImagesCaptured
		_manager.wrappedValue.imageCountLimit = imageCountLimit
		self.tintColor = tintColor
		self.closeOption = closeOption
	}

	public var body: some View {
		let _ = Self._printChanges()
		ZStack {
			CameraView(manager: manager, onImagesCaptured: manager.onImagesCaptured)

			VStack(spacing: 16) {
				if manager.availableZoomFactors.count > 1 || manager.supportsMacro {
					ZoomControl(manager: manager)
				}
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
			}
			.padding(.bottom)
			.frame(maxHeight: .infinity, alignment: .bottom)

			AcceptPhotoView(manager: manager, image: manager.capturedImage, animationNamespace: animationNamespace)
			if isReviewingPhotos {
				ReviewPhotosView(manager: manager, isVisible: $isReviewingPhotos)
			}
			
			if !isReviewingPhotos, manager.capturedImage == nil, let closeOption {
				RoundSystemButton(closeOption)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: closeOption.alignment)
					.padding()
			}
		}
		.toolbar(manager.capturedImage == nil ? .visible : .hidden)
		.onDisappear {
			manager.reset()
		}
		.tint(tintColor)
		.toolbar(.hidden)
	}
}

#endif
