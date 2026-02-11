//
//  MockCameraManager.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/9/26.
//

#if os(iOS)
import AVFoundation
import CrossPlatformKit
import Observation

@available(iOS 17, *)
@MainActor @Observable
public final class MockCameraManager: CameraManaging {
	public static let instance = MockCameraManager()

	public var isRunning = false
	public var cameraPosition: AVCaptureDevice.Position = .back
	public var permissionStatus: AVAuthorizationStatus = .authorized
	public var capturedImage: UXImage?
	public var savedImages: [CapturedImage] = []
	public var isSavingImage = false
	public let session = AVCaptureSession()

	public var nextCapturedImage: UXImage?
	public var checkPermissionsCalled = false
	public var startSessionCalled = false
	public var stopSessionCalled = false
	public var switchCameraCalled = false
	public var resetCalled = false
	public var capturePhotoCalled = false

	public var sampleImages: [UXImage] = []
	
	public init() { }

	public func checkPermissionsAndStart() {
		checkPermissionsCalled = true
		startSession()
	}

	public func startSession() {
		startSessionCalled = true
		isRunning = true
	}

	public func stopSession() {
		stopSessionCalled = true
		isRunning = false
	}

	public func switchCamera() {
		switchCameraCalled = true
		cameraPosition = cameraPosition == .back ? .front : .back
	}

	public func reset() {
		resetCalled = true
		capturedImage = nil
		savedImages = []
		isSavingImage = false
	}

	public func capturePhoto() {
		capturePhotoCalled = true
		if !sampleImages.isEmpty {
			let image = sampleImages.removeFirst()
			capturedImage = image
			return
		}
		if let nextCapturedImage {
			capturedImage = nextCapturedImage
		}
	}
	
	public func saveImage(_ image: UXImage? = nil) {
		guard let saved = image ?? capturedImage else { return }
		savedImages.append(.init(saved))
		capturedImage = nil
		isSavingImage = false
	}
}

#endif
