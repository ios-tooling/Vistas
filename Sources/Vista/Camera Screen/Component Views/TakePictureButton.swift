//
//  TakePictureButton.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/8/26.
//

#if os(iOS)
import SwiftUI
import AVFoundation
import CrossPlatformKit

@available(iOS 17, *)
struct TakePictureButton: View {
	var manager: any CameraManaging
	var body: some View {
		Button(action: {
			manager.capturePhoto()
		}) {
			Circle()
				.fill(.white)
				.padding(4)
				.overlay {
					Circle()
						.stroke(.black.opacity(0.5), lineWidth: 5)
				}
				.frame(height: 80)
		}
		.disabled(manager.imageCountLimit == manager.savedImages.count)
		.opacity(manager.imageCountLimit == manager.savedImages.count ? 0.5 : 1)
	}
}

#Preview {
	if #available(iOS 17, *) {
		ZStack {
			Color.red
				.ignoresSafeArea()
			TakePictureButton(manager: CameraManager.instance)
		}
	}
}

#endif
