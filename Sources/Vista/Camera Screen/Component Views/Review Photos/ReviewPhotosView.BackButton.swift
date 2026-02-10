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
	struct BackButton: View {
		var dismiss: () -> Void
		
		var body: some View {
			if #available(iOS 26.0, *) {
				button(showBorder: false)
					.glassEffect()
			} else {
				button(showBorder: true)
			}
		}
		
		@ViewBuilder func button(showBorder: Bool) -> some View {
			Button(action: {
				dismiss()
			}) {
				Image(systemName: "chevron.left")
					.foregroundStyle(.primary)
					.frame(width: 50, height: 50)
					.overlay {
						if showBorder {
							Circle()
								.stroke(.primary, lineWidth: 0.5)
						}
					}
					.contentShape(.circle)
			}
			.buttonStyle(.plain)
		}
	}
}

@available(iOS 17, *)
#Preview {
	ReviewPhotosView.BackButton { }
		.padding(100)
		.background {
			Color.primary.opacity(0.2)
		}
}
#endif
