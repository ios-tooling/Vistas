//
//  File.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/9/26.
//

#if os(iOS)
import SwiftUI
import CrossPlatformKit

@available(iOS 17, *)
struct ReviewPhotosView: View {
	let manager: any CameraManaging
	@Binding var isVisible: Bool
		
	var body: some View {
		ZStack {
			if isVisible {
				NavigationStack {
					TabView {
						ForEach(manager.savedImages) { image in
							Image(uxImage: image.image)
								.resizable()
								.aspectRatio(contentMode: .fit)
						}
					}
					.tabViewStyle(.page(indexDisplayMode: .never))
					.toolbar {
						ToolbarItem(id: "back", placement: .cancellationAction) {
							Button("Done", systemImage: "chevron.left") {
								withAnimation {
									isVisible = false
								}
							}
							.buttonStyle(.bordered)
						}
					}
				}
			}
		}
		.background {
			ZStack {
				Color.systemBackground
				Color.primary.opacity(0.1)
			}
			.ignoresSafeArea()
			.opacity(manager.isSavingImage ? 0 : 1)
		}
		.opacity(isVisible ? 1 : 0)
	}
	
}

#endif


