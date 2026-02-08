//
//  StockCameraView.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

public struct StockCameraView: UIViewControllerRepresentable {
	var dismiss: () -> Void
	let onImageCaptured: @MainActor (UXImage) -> Void

	public init(onImageCaptured: @escaping @MainActor (UXImage) -> Void, dismiss: @escaping () -> Void) {
		self.dismiss = dismiss
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
		let parent: StockCameraView
		
		init(_ parent: StockCameraView) {
			self.parent = parent
		}
		
		public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			// Use edited image if available (since allowsEditing = true), otherwise fall back to original
			if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
				Task { @MainActor in
					parent.onImageCaptured(image)
					parent.dismiss()
				}
			} else {
				Task { @MainActor in
					parent.dismiss()
				}
			}
		}
		
		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			Task { @MainActor in
				parent.dismiss()
			}
		}
	}
}
#endif
