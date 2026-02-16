//
//  CameraManaging.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/9/26.
//

#if os(iOS)
import AVFoundation
import CrossPlatformKit
import Observation

@available(iOS 17, *)
@MainActor public protocol CameraManaging: AnyObject, Observable {
	static var instance: Self { get }
	var isRunning: Bool { get set }
	var cameraPosition: AVCaptureDevice.Position { get set }
	var permissionStatus: AVAuthorizationStatus { get set }
	var capturedImage: UXImage? { get set }
	var savedImages: [CapturedImage] { get set }
	var isSavingImage: Bool { get set }
	var session: AVCaptureSession { get }
	var currentZoom: CGFloat { get set }
	var availableZoomFactors: [CGFloat] { get set }
	var isMacroEnabled: Bool { get set }
	var supportsMacro: Bool { get }

	func checkPermissionsAndStart()
	func startSession()
	func stopSession()
	func switchCamera()
	func reset()
	func capturePhoto()
	func saveImage(_ image: UXImage?)
	func setZoom(_ factor: CGFloat)
}

@available(iOS 17, *)
public extension CameraManaging {
	func removeSavedImage(at index: Int) {
		savedImages.remove(at: index)
	}
	
	func removeSavedImage(id: UUID) {
		if let index = savedImages.firstIndex(where: { $0.id == id }) {
			removeSavedImage(at: index)
		}
	}

	func toggleMacro() {
		isMacroEnabled.toggle()
		if isMacroEnabled, let ultraWide = availableZoomFactors.first, ultraWide < 1.0 {
			setZoom(ultraWide)
			isMacroEnabled = true
		} else {
			isMacroEnabled = false
			setZoom(1.0)
		}
	}
}

#endif
