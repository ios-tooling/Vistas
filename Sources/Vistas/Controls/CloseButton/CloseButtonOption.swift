//
//  CloseButtonOption.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/10/26.
//

import SwiftUI


public struct CloseButtonOption: Equatable {
	public var id = UUID().uuidString
	public var action: (@MainActor () -> Void)? = nil
	public let systemImageName: String
	public let alignment: Alignment
	
	public static func == (lhs: CloseButtonOption, rhs: CloseButtonOption) -> Bool {
		lhs.id == rhs.id
	}
}

public extension CloseButtonOption {
	static let navigationBack = CloseButtonOption(systemImageName: "chevron.left", alignment: .topLeading)
	static let sheetDismiss = CloseButtonOption(systemImageName: "chevron.down", alignment: .topTrailing)
	static let xClose = CloseButtonOption(systemImageName: "xmark", alignment: .topTrailing)
	
	static func navigationBack(_ action: @escaping @MainActor () -> Void) -> CloseButtonOption {
		CloseButtonOption(id: "navigationBack", action: action, systemImageName: "chevron.left", alignment: .topLeading)
	}
	static func sheetDismiss(_ action: @escaping @MainActor () -> Void) -> CloseButtonOption {
		CloseButtonOption(id: "sheetDismiss", action: action, systemImageName: "chevron.down", alignment: .topTrailing)
	}
	static func xClose(_ action: @escaping @MainActor () -> Void) -> CloseButtonOption {
		CloseButtonOption(id: "xClose", action: action, systemImageName: "xmark", alignment: .topTrailing)
	}
}
