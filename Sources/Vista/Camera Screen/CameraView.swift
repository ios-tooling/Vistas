//
//  CameraView.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

@available(iOS 17, *)
public struct CameraView: View {
	@State var manager: any CameraManaging
	let onImagesCaptured: (@MainActor ([UXImage]) -> Void)?

	public init(manager: any CameraManaging = CameraManager.instance, onImagesCaptured: (@MainActor ([UXImage]) -> Void)? = nil) {
		_manager = State(initialValue: manager)
		self.onImagesCaptured = onImagesCaptured
	}

	public var body: some View {
		Group {
			switch manager.permissionStatus {
			case .authorized:
				CameraPreviewLayer(session: manager.session)
					.ignoresSafeArea()

			case .denied, .restricted:
				permissionDeniedView

			case .notDetermined:
				ProgressView("Requesting camera access…")

			@unknown default:
				permissionDeniedView
			}
		}
		.onAppear {
			manager.checkPermissions()
			manager.startSession()
		}
		.onDisappear {
			manager.stopSession()
		}
		.background { Color.black.ignoresSafeArea() }
	}

	@ViewBuilder private var permissionDeniedView: some View {
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
			Text(manager.permissionStatus == .denied
				? "Camera access is required. Please enable it in Settings."
				: "Camera access is restricted on this device.")
				.multilineTextAlignment(.center)
				.font(.headline)
				.padding()
			Spacer()
			if manager.permissionStatus == .denied {
				Button("Open Settings") {
					if let url = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				}
				.buttonStyle(.borderedProminent)
				.padding(.bottom)
			}
			Spacer()
		}
		.padding()
		.frame(maxWidth: 400)
	}
}

#endif
