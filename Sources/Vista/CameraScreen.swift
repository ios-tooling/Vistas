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
	let onImageCaptured: (UXImage) -> Void
	
	public init(isPresented: Binding<Bool>, onImageCaptured: @escaping (UXImage) -> Void) {
		_isPresented = isPresented
		self.onImageCaptured = onImageCaptured
	}
	
	public var body: some View {
		CameraView(isPresented: $isPresented, onImageCaptured: onImageCaptured)
			.edgesIgnoringSafeArea(.all)
	}
}

public struct CameraView: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	let onImageCaptured: (UXImage) -> Void
	
	public init(isPresented: Binding<Bool>, onImageCaptured: @escaping (UXImage) -> Void) {
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
			if let image = info[.originalImage] as? UIImage {
				parent.onImageCaptured(image)
			}
			parent.isPresented = false
		}
		
		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.isPresented = false
		}
	}
}
#endif
