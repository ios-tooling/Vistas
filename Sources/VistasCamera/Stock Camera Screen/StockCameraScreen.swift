//
//  StockCameraScreen.swift
//  Vistas
//
//  Created by Ben Gottlieb on 9/22/25.
//


#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

public struct StockCameraScreen: View {
	@Binding var isPresented: Bool
	let useIsPresentedBinding: Bool
	let onImageCaptured: @MainActor (UXImage) -> Void
	@State private var permissionStatus: AVAuthorizationStatus = .notDetermined
	@Environment(\.dismiss) private var dismiss

	public init(onImageCaptured: @escaping @MainActor (UXImage) -> Void) {
		_isPresented = .constant(true)
		useIsPresentedBinding = false
		self.onImageCaptured = onImageCaptured
	}
	
	public init(isPresented: Binding<Bool>, onImageCaptured: @escaping @MainActor (UXImage) -> Void) {
		_isPresented = isPresented
		useIsPresentedBinding = true
		self.onImageCaptured = onImageCaptured
	}

	public var body: some View {
		Group {
			switch permissionStatus {
			case .authorized:
				StockCameraView(onImageCaptured: onImageCaptured) {
					if useIsPresentedBinding {
						isPresented = false
					} else {
						dismiss()
					}
				}
				.edgesIgnoringSafeArea(.all)
		
			case .denied, .restricted:
				permissionDeniedView
			case .notDetermined:
				ProgressView("Requesting camera access...")
			@unknown default:
				permissionDeniedView
			}
		}
		.onAppear {
			checkCameraPermission()
		}
		.background {
			Color.black
				.ignoresSafeArea()
		}
	}

	@ViewBuilder var permissionDeniedView: some View {
		VStack {
			Spacer()
			ZStack {
				Image(systemName: "camera")
					.font(.system(size: 40))
				Image(systemName: "circle.slash")
					.font(.system(size: 80))
					.foregroundStyle(.red)
			}
			Spacer()
			Text(permissionStatus == .denied ?
				"Camera access is required to take photos. Please enable camera access in Settings." :
				"Camera access is restricted on this device.")
				.multilineTextAlignment(.center)
				.font(.headline)
				.padding()
			Spacer()
			if permissionStatus == .denied {
				Button("Open Settings") {
					if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(settingsURL)
					}
				}
				.buttonStyle(.borderedProminent)
				.padding(.bottom)
			}
			Button("Cancel") {
				isPresented = false
				dismiss()
			}
			.buttonStyle(.bordered)
			Spacer()
		}
		.padding()
		.frame(maxWidth: 400)
	}

	private func checkCameraPermission() {
		permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)

		if permissionStatus == .notDetermined {
			AVCaptureDevice.requestAccess(for: .video) { granted in
				Task { @MainActor in
					permissionStatus = granted ? .authorized : .denied
				}
			}
		}
	}
}
#endif
