//
//  TakePictureScreen.swift
//  Vistas
//
//  Created by Ben Gottlieb on 9/27/24.
//

import SwiftUI
import Suite

public struct TakePictureScreen: UIViewControllerRepresentable {
	@Environment(\.dismiss) var dismiss
	@Binding var image: UIImage?
	let fromLibrary: Bool
	
	public init(fromLibrary: Bool = false, image: Binding<UIImage?>) {
		_image = image
		self.fromLibrary = Gestalt.isOnSimulator || fromLibrary
	}
	
	public func makeUIViewController(context: Context) -> some UIViewController {
		context.coordinator.dismiss = { dismiss() }
		context.coordinator.imageBinding = $image
		return context.coordinator.controller
	}
	
	public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
		context.coordinator.dismiss = { dismiss() }
		context.coordinator.fromLibrary = fromLibrary
		context.coordinator.imageBinding = $image
	}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		let controller = UIImagePickerController()
		var dismiss = { }
		var imageBinding: Binding<UIImage?>?
		var fromLibrary = false { didSet {
			controller.sourceType = fromLibrary ? .photoLibrary : .camera
		}}
		
		public override init() {
			super.init()
			
			controller.delegate = self
			controller.sourceType = Gestalt.isOnSimulator ? .photoLibrary : .camera
		}
		
		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			dismiss()
		}
		
		public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let image = info[.originalImage] as? UIImage {
				imageBinding?.wrappedValue = image
			}
			dismiss()
		}
	}
}
