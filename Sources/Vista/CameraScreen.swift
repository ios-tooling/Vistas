//
//  CameraView.swift
//  Vistas
//
//  Created by Ben Gottlieb on 9/22/25.
//


#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

public struct CameraScreen: View {
	@Binding var isPresented: Bool
	let onImageCaptured: @MainActor (UXImage) -> Void
	@State private var permissionStatus: AVAuthorizationStatus = .notDetermined
	@Environment(\.dismiss) private var dismiss

	public init(isPresented: Binding<Bool>, onImageCaptured: @escaping @MainActor (UXImage) -> Void) {
		_isPresented = isPresented
		self.onImageCaptured = onImageCaptured
	}

	public var body: some View {
		Group {
			switch permissionStatus {
			case .authorized:
				CameraView(isPresented: $isPresented, onImageCaptured: onImageCaptured)
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

public struct CameraView: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	let onImageCaptured: @MainActor (UXImage) -> Void

	public init(isPresented: Binding<Bool>, onImageCaptured: @escaping @MainActor (UXImage) -> Void) {
		_isPresented = isPresented
		self.onImageCaptured = onImageCaptured
	}
	
	public func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		picker.sourceType = .camera
		picker.allowsEditing = true
		return picker
	}
	
	public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		let parent: CameraView
		
		init(_ parent: CameraView) {
			self.parent = parent
		}
		
		public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			// Use edited image if available (since allowsEditing = true), otherwise fall back to original
			if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
				Task { @MainActor in
					parent.onImageCaptured(image)
					parent.isPresented = false
				}
			} else {
				Task { @MainActor in
					parent.isPresented = false
				}
			}
		}
		
		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			Task { @MainActor in
				parent.isPresented = false
			}
		}
	}
}
#endif
