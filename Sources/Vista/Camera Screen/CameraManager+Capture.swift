//
//  CameraManager+Capture.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
@preconcurrency import AVFoundation
import CrossPlatformKit
import SwiftUI

@available(iOS 17, *)
extension CameraManager {
	public func capturePhoto() {
		let settings = AVCapturePhotoSettings()
		let processor = PhotoCaptureProcessor(manager: self)
		captureProcessor = processor
		sessionQueue.async { [weak self] in
			self?.photoOutput.capturePhoto(with: settings, delegate: processor)
		}
	}
	
	public func saveImage(_ image: UXImage? = nil) {
		guard let saved = image ?? capturedImage else { return }
		savedImages.append(saved)
		capturedImage = nil
		isSavingImage = false
	}
}

@available(iOS 17, *)
final class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
	weak var manager: CameraManager?

	init(manager: CameraManager) {
		self.manager = manager
	}

	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		defer {
			Task { @MainActor in self.manager?.captureProcessor = nil }
		}

		guard error == nil,
				let data = photo.fileDataRepresentation(),
				let image = UXImage(data: data) else { return }

		Task { @MainActor in
			withAnimation {
				manager?.capturedImage = image
			}
		}
	}
}

#endif
