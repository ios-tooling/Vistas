//
//  CameraPreviewLayer.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import AVFoundation

@available(iOS 17, *)
struct CameraPreviewLayer: UIViewRepresentable {
	let session: AVCaptureSession

	func makeUIView(context: Context) -> PreviewView {
		let view = PreviewView()
		view.previewLayer.session = session
		view.previewLayer.videoGravity = .resizeAspectFill
		return view
	}

	func updateUIView(_ uiView: PreviewView, context: Context) {
		if uiView.previewLayer.session !== session {
			uiView.previewLayer.session = session
		}
	}

	class PreviewView: UIView {
		override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

		var previewLayer: AVCaptureVideoPreviewLayer {
			layer as! AVCaptureVideoPreviewLayer
		}
	}
}

#endif
