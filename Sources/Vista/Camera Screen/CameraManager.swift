//
//  CameraManager.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

@available(iOS 17, *)
@MainActor @Observable public class CameraManager {
	public static let instance = CameraManager()

	var isRunning = false
	var cameraPosition: AVCaptureDevice.Position = .back
	var permissionStatus: AVAuthorizationStatus = .notDetermined
	var capturedImage: UXImage?
	var savedImages: [UXImage] = []
	var isSavingImage = false
	
	nonisolated(unsafe) let session = AVCaptureSession()
	@ObservationIgnored nonisolated(unsafe) var videoDeviceInput: AVCaptureDeviceInput?
	@ObservationIgnored nonisolated(unsafe) var photoOutput = AVCapturePhotoOutput()
	nonisolated let sessionQueue = DispatchQueue(label: "camera.session.queue")
	@ObservationIgnored var captureProcessor: PhotoCaptureProcessor?

	public init() { }

	public func checkPermissions() {
		permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)

		if permissionStatus == .notDetermined {
			AVCaptureDevice.requestAccess(for: .video) { granted in
				Task { @MainActor in
					self.permissionStatus = granted ? .authorized : .denied
					if granted { self.configureSession() }
				}
			}
		} else if permissionStatus == .authorized {
			configureSession()
		}
	}
	
	func reset() {
		capturedImage = nil
		savedImages = []
	}

	public func startSession() {
		guard permissionStatus == .authorized, !isRunning else { return }
		sessionQueue.async { [weak self] in
			self?.session.startRunning()
			Task { @MainActor in
				self?.isRunning = self?.session.isRunning ?? false
			}
		}
	}

	public func stopSession() {
		guard isRunning else { return }
		sessionQueue.async { [weak self] in
			self?.session.stopRunning()
			Task { @MainActor in
				self?.isRunning = false
			}
		}
	}

	public func switchCamera() {
		cameraPosition = cameraPosition == .back ? .front : .back
		let newPosition = cameraPosition
		sessionQueue.async { [weak self] in
			guard let self else { return }
			self.session.beginConfiguration()

			if let currentInput = self.videoDeviceInput {
				self.session.removeInput(currentInput)
			}

			guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
					let input = try? AVCaptureDeviceInput(device: device) else {
				self.session.commitConfiguration()
				return
			}

			if self.session.canAddInput(input) {
				self.session.addInput(input)
				self.videoDeviceInput = input
			}

			self.session.commitConfiguration()
		}
	}

	private func configureSession() {
		let position = cameraPosition
		sessionQueue.async { [weak self] in
			guard let self else { return }
			self.session.beginConfiguration()
			self.session.sessionPreset = .photo

			guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
					let input = try? AVCaptureDeviceInput(device: camera) else {
				self.session.commitConfiguration()
				return
			}

			if self.session.canAddInput(input) {
				self.session.addInput(input)
				self.videoDeviceInput = input
			}

			if self.session.canAddOutput(self.photoOutput) {
				self.session.addOutput(self.photoOutput)
			}

			self.session.commitConfiguration()
		}
	}
}

#endif
