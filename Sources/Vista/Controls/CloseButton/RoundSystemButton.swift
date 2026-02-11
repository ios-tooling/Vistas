//
//  RoundSystemButton.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/10/26.
//

import SwiftUI
public struct RoundSystemButton: View {
	@MainActor var action: (() -> Void)?
	@Environment(\.dismiss) var dismiss
	var systemImageName: String
	
	public init(systemName: String, action: (@MainActor () -> Void)? = nil) {
		self.action = action
		self.systemImageName = systemName
	}
	
	public init(_ closeOption: CloseButtonOption) {
		self.action = closeOption.action
		self.systemImageName = closeOption.systemImageName
	}
	
	public var body: some View {
		if #available(iOS 26.0, *) {
			button(showBorder: false)
				.glassEffect()
		} else {
			button(showBorder: true)
		}
	}
	
	@ViewBuilder func button(showBorder: Bool) -> some View {
		Button(action: {
			if let action {
				action()
			} else {
				dismiss()
			}
		}) {
			Image(systemName: systemImageName)
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

