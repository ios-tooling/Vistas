//
//  ZoomControl.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/15/26.
//

#if os(iOS)
import SwiftUI

@available(iOS 17, *)
struct ZoomControl: View {
	var manager: any CameraManaging
	private let buttonSize: CGFloat = 36

	var body: some View {
		HStack(spacing: 16) {
			if manager.supportsMacro {
				macroButton
			}
			zoomButtons
		}
	}

	private var macroButton: some View {
		Button {
			withAnimation(.easeInOut(duration: 0.2)) { manager.toggleMacro() }
		} label: {
			Image(systemName: "camera.macro")
				.font(.system(size: 14, weight: manager.isMacroEnabled ? .bold : .regular))
				.foregroundStyle(manager.isMacroEnabled ? Color.accentColor : Color.white)
				.frame(width: buttonSize, height: buttonSize)
				.background {
					Circle().fill(manager.isMacroEnabled ? .white : .black.opacity(0.4))
				}
		}
	}

	private var zoomButtons: some View {
		HStack(spacing: 4) {
			ForEach(manager.availableZoomFactors, id: \.self) { factor in
				let isSelected = !manager.isMacroEnabled && manager.currentZoom == factor
				Button {
					withAnimation(.easeInOut(duration: 0.2)) { manager.setZoom(factor) }
				} label: {
					Text(label(for: factor))
						.font(.system(size: 12, weight: isSelected ? .bold : .regular))
						.foregroundStyle(isSelected ? Color.accentColor : .white)
						.frame(width: buttonSize, height: buttonSize)
						.background {
							Circle().fill(isSelected ? .white : .clear)
						}
				}
			}
		}
		.padding(.horizontal, 4)
		.padding(.vertical, 2)
		.background {
			Capsule().fill(.black.opacity(0.4))
		}
	}

	private func label(for factor: CGFloat) -> String {
		let value = Double(factor)
		if factor < 1 {
			let formatted = value.formatted(.number.precision(.fractionLength(0...1)))
			return ".\(formatted.split(separator: ".").last ?? "5")"
		} else if factor == 1 {
			return "1x"
		} else {
			return value.formatted(.number.precision(.fractionLength(0)))
		}
	}
}

#endif
