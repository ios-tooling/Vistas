//
//  TakePictureScreen.swift
//  Vistas
//
//  Created by Ben Gottlieb on 9/27/24.
//

import SwiftUI
import Suite
import AVFoundation
import Photos

#if os(iOS)
public struct TakePictureScreen: View {
	@Environment(\.dismiss) var dismiss
	@Binding var image: UIImage?
	let fromLibrary: Bool
	@State private var permissionStatus: PermissionStatus = .notDetermined

	public init(fromLibrary: Bool = false, image: Binding<UIImage?>) {
		_image = image
		self.fromLibrary = Gestalt.isOnSimulator || fromLibrary
	}

	public var body: some View {
		Group {
			switch permissionStatus {
			case .authorized:
				if fromLibrary {
					SelectFromLibraryScreen(image: $image, dismiss: dismiss)
				} else {
					StockCameraScreen { image = $0 }
				}
			case .denied, .restricted:
				permissionDeniedView
			case .notDetermined:
				ProgressView(fromLibrary ? "Requesting photo library access..." : "Requesting camera access...")
			}
		}
		.onAppear {
			checkPermission()
		}
	}

	@ViewBuilder var permissionDeniedView: some View {
		VStack {
			Spacer()
			ZStack {
				Image(systemName: fromLibrary ? "photo.on.rectangle" : "camera")
					.font(.system(size: 40))
				Image(systemName: "circle.slash")
					.font(.system(size: 80))
					.foregroundStyle(.red)
			}
			Spacer()
			Text(permissionStatus == .denied ?
				"\(fromLibrary ? "Photo library" : "Camera") access is required. Please enable access in Settings." :
				"\(fromLibrary ? "Photo library" : "Camera") access is restricted on this device.")
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
				dismiss()
			}
			.buttonStyle(.bordered)
			Spacer()
		}
		.padding()
		.frame(maxWidth: 400)
	}

	private func checkPermission() {
		if fromLibrary {
			// Check photo library permission
			let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
			permissionStatus = PermissionStatus(from: status)

			if status == .notDetermined {
				PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
					Task { @MainActor in
						permissionStatus = PermissionStatus(from: newStatus)
					}
				}
			}
		} else {
			// Check camera permission
			let status = AVCaptureDevice.authorizationStatus(for: .video)
			permissionStatus = PermissionStatus(from: status)

			if status == .notDetermined {
				AVCaptureDevice.requestAccess(for: .video) { granted in
					Task { @MainActor in
						permissionStatus = granted ? .authorized : .denied
					}
				}
			}
		}
	}

	enum PermissionStatus {
		case notDetermined
		case authorized
		case denied
		case restricted

		init(from avStatus: AVAuthorizationStatus) {
			switch avStatus {
			case .authorized: self = .authorized
			case .denied: self = .denied
			case .restricted: self = .restricted
			case .notDetermined: self = .notDetermined
			@unknown default: self = .denied
			}
		}

		init(from phStatus: PHAuthorizationStatus) {
			switch phStatus {
			case .authorized, .limited: self = .authorized
			case .denied: self = .denied
			case .restricted: self = .restricted
			case .notDetermined: self = .notDetermined
			@unknown default: self = .denied
			}
		}
	}
}

struct SelectFromLibraryScreen: UIViewControllerRepresentable {
	@Binding var image: UIImage?
	let dismiss: DismissAction

	func makeUIViewController(context: Context) -> some UIViewController {
		context.coordinator.dismiss = { dismiss() }
		context.coordinator.imageBinding = $image
		return context.coordinator.controller
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
		context.coordinator.dismiss = { dismiss() }
		context.coordinator.imageBinding = $image
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		let controller = UIImagePickerController()
		var dismiss = { }
		var imageBinding: Binding<UIImage?>?

		override init() {
			super.init()

			controller.delegate = self
			controller.sourceType = .photoLibrary
		}
		
		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			dismiss()
		}
		
		public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			// Check for edited image first, then fall back to original
			if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
				imageBinding?.wrappedValue = image
			}
			dismiss()
		}
	}
}
#endif
