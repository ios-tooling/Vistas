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
@MainActor @Observable final public class CameraManager: CameraManaging {
	public static let instance = CameraManager()

	public var isRunning = false
	public var cameraPosition: AVCaptureDevice.Position = .back
	public var permissionStatus: AVAuthorizationStatus = .notDetermined
	public var capturedImage: UXImage?
	public var savedImages: [CapturedImage] = []
	public var isSavingImage = false
	public var currentZoom: CGFloat = 1.0
	public var availableZoomFactors: [CGFloat] = [1]
	public var isMacroEnabled = false
	public var supportsMacro: Bool { availableZoomFactors.contains(where: { $0 < 1.0 }) }

	public nonisolated(unsafe) let session = AVCaptureSession()
	@ObservationIgnored nonisolated(unsafe) var videoDeviceInput: AVCaptureDeviceInput?
	@ObservationIgnored nonisolated(unsafe) var photoOutput = AVCapturePhotoOutput()
	nonisolated let sessionQueue = DispatchQueue(label: "camera.session.queue")
	@ObservationIgnored var captureProcessor: PhotoCaptureProcessor?

	public init() {
		
	}

	public func checkPermissionsAndStart() {
		permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)

		if permissionStatus == .notDetermined {
			AVCaptureDevice.requestAccess(for: .video) { granted in
				Task { @MainActor in
					self.permissionStatus = granted ? .authorized : .denied
					if granted {
						self.configureSession()
						self.startSession()
					}
				}
			}
		} else if permissionStatus == .authorized {
			configureSession()
			startSession()
		}
	}
	
	public func reset() {
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

			guard let device = Self.bestDevice(for: newPosition),
					let input = try? AVCaptureDeviceInput(device: device) else {
				self.session.commitConfiguration()
				return
			}

			if self.session.canAddInput(input) {
				self.session.addInput(input)
				self.videoDeviceInput = input
			}

			self.session.commitConfiguration()
			self.updateZoomFactors(for: device)
		}
	}

	public func setZoom(_ factor: CGFloat) {
		currentZoom = factor
		isMacroEnabled = false
		sessionQueue.async { [weak self] in
			guard let self, let device = self.videoDeviceInput?.device else { return }
			try? device.lockForConfiguration()
			device.videoZoomFactor = max(device.minAvailableVideoZoomFactor, min(factor, device.maxAvailableVideoZoomFactor))
			device.unlockForConfiguration()
		}
	}

	private func configureSession() {
		let position = cameraPosition
		sessionQueue.async { [weak self] in
			guard let self else { return }
			self.session.beginConfiguration()
			self.session.sessionPreset = .photo

			guard let camera = Self.bestDevice(for: position),
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
			self.updateZoomFactors(for: camera)
		}
	}

	nonisolated private static func bestDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
		if position == .back {
			let types: [AVCaptureDevice.DeviceType] = [
				.builtInTripleCamera,
				.builtInDualWideCamera,
				.builtInDualCamera,
				.builtInWideAngleCamera,
			]
			for type in types {
				if let device = AVCaptureDevice.default(type, for: .video, position: .back) {
					return device
				}
			}
			return nil
		}
		return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
	}

	nonisolated private func updateZoomFactors(for device: AVCaptureDevice) {
		var factors: [CGFloat] = [1.0]
		let switchOvers = device.virtualDeviceSwitchOverVideoZoomFactors.map { CGFloat($0.doubleValue) }
		factors.append(contentsOf: switchOvers)
		if device.minAvailableVideoZoomFactor < 1.0 {
			factors.insert(device.minAvailableVideoZoomFactor, at: 0)
		}
		let sorted = factors.sorted()
		Task { @MainActor in
			self.availableZoomFactors = sorted
			self.currentZoom = 1.0
		}
	}
}

#endif
