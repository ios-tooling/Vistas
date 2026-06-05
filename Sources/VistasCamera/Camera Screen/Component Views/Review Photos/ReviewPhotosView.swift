//
//  ReviewPhotosView.swift
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
	@State private var selectedID: UUID = UUID()
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		let _ = Self._printChanges()
			if isVisible {
				NavigationStack {
					ZStack {
						GeometryReader { geo in
							TabView(selection: $selectedID) {
								ForEach(manager.savedImages) { image in
									Image(uxImage: image.image)
										.resizable()
										.aspectRatio(contentMode: .fit)
										.frame(maxWidth: geo.width, maxHeight: geo.height)
										.transition(.scale)
										.tag(image.id)
								}
							}
						}
						.ignoresSafeArea()

						HStack {
							DeleteButton(manager: manager, id: selectedID) { withAnimation { isVisible = false }}
						}
						.padding(.bottom)
						.frame(maxHeight: .infinity, alignment: .bottom)
					}
					.tabViewStyle(.page(indexDisplayMode: .never))
					.toolbar(.hidden)
					.background {
						ZStack {
							Color.systemBackground
							Color.primary.opacity(0.2)
						}
					}
					.ignoresSafeArea()
				}
				.overlay(alignment: .top) {
					HStack {
						BackButton { isVisible = false }
							.padding()
						
						Spacer()
						
						Button("Done") {
							manager.finish()
							dismiss()
						}
						.buttonStyle(.bordered)
						.tint(.primary)
						.padding()
					}
				}
				.zIndex(10)
				.onChange(of: manager.savedImages, initial: true) {
					if let id = manager.savedImages.first?.id { selectedID = id }}
			}
	}
	
}

#endif


