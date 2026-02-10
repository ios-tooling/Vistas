//
//  File.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/10/26.
//

#if os(iOS)
import SwiftUI
import CrossPlatformKit

@available(iOS 17, *)
extension ReviewPhotosView {
	struct DeleteButton: View {
		let manager: any CameraManaging
		let id: UUID
		var dismiss: () -> Void
		
		func delete() {
			withAnimation {
				manager.removeSavedImage(id: id)
			} completion: {
				if manager.savedImages.isEmpty {
					dismiss()
				}
			}
		}
		
		var body: some View {
			Button(action: { delete() }) {
				VStack {
					Circle()
						.fill(Color.systemBackground)
						.frame(width: 50, height: 50)
						.overlay {
							Image(systemName: "trash")
								.foregroundStyle(Color.primary)
								.imageScale(.large)
						}
					
					Text("Delete")
						.font(.system(size: 12, weight: .bold, design: .rounded))
						.foregroundStyle(Color.systemBackground)
						.shadow(color: .black.opacity(0.5), radius: 0.5)
				}
				
			}
		}
	}
}

@available(iOS 17, *)
#Preview {
	ReviewPhotosView.DeleteButton(manager: MockCameraManager(), id: UUID()) { }
		.padding(100)
		.background {
			Color.primary.opacity(0.2)
		}
}
#endif
