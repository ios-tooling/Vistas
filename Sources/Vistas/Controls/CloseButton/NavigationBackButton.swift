//
//  NavigationBackButton.swift
//  Vistas
//
//  Created by Ben Gottlieb on 2/10/26.
//

import SwiftUI

public struct NavigationBackButton: View {
	@MainActor var action: (() -> Void)?
	
	public init(action: (@MainActor () -> Void)? = nil) {
		self.action = action
	}
	
	public init(option: CloseButtonOption) {
		self.action = option.action
	}
	
	public var body: some View {
		RoundSystemButton(systemName: "chevron.left", action: action)
	}
}
