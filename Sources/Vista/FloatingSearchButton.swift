//
//  FloatingSearchButton.swift
//  Vistas
//
//  Created by Ben Gottlieb on 1/8/26.
//

import SwiftUI

@available(iOS 17.0, *)
public extension View {
	@ViewBuilder func addFloatingSearchButton<Content: View>(_ label: String = "Search", searchText: Binding<String>, content: @escaping @MainActor () -> Content) -> some View {
		
		if #available(iOS 26.0, *) {
			self
				.safeAreaBar(edge: .bottom, alignment: .center, content: {
					FloatingSearchButton(label, searchText: searchText, content: content)
				})
		} else {
			self
				.overlay(alignment: .bottom) {
					FloatingSearchButton(label, searchText: searchText, content: content)
				}
		}
	}
}

@available(iOS 17.0, *)
public struct FloatingSearchButton<Content: View>: View {
	@Binding var searchText: String
	let searchLabel: String
	let content: () -> Content
	
	@Namespace private var namespace
	@FocusState var isFocused: Bool

	@State private var isActive: Bool = false
	
	public init(_ label: String, searchText: Binding<String>, content: @escaping @MainActor () -> Content) {
		searchLabel = label
		_searchText = searchText
		self.content = content
	}
	
	public var body: some View {
		if #available(iOS 26.0, *) {
			GlassEffectContainer(spacing: 40.0) {
				HStack {
					if isActive {
						searchBar
							.glassEffect()
							.glassEffectID("trigger", in: namespace)
					}
										
					if !isActive {
						content()
							.frame(height: 44)
							.glassEffect()
							.glassEffectID("content", in: namespace)

						Spacer()
						toggleButton
							.glassEffect()
							.glassEffectID("bar", in: namespace)
					}
				}
			}
			.padding()
		} else {
			HStack {
				if isActive {
					searchBar
				}
				
				Spacer()
				
				if !isActive {
					toggleButton
				}
			}
		}
	}
	
	@ViewBuilder var searchBar: some View {
		SearchBar(searchLabel: searchLabel, searchText: $searchText, isActive: $isActive)
			.focused($isFocused, equals: true)
	}
	
	@ViewBuilder var toggleButton: some View {
		Button(action: {
			withAnimation {
				isActive.toggle()
				isFocused = true
			}
		}) {
			Image(systemName: "magnifyingglass")
				.frame(width: 44, height: 44)
		}
		.buttonBorderShape(.circle)
	}
	
	struct SearchBar: View {
		var searchLabel: String
		@Binding var searchText: String
		@Binding var isActive: Bool
		
		
		var body: some View {
			HStack {
				Image(systemName: "magnifyingglass")
					.frame(width: 44, height: 44)

				TextField(searchLabel, text: $searchText)
				
				Button(action: {
					withAnimation {
						isActive.toggle()
					}
				}) {
					Image(systemName: "xmark")
						.frame(width: 44, height: 44)
				}
			}
			
		}
	}
}

#Preview {
	if #available(iOS 26, *) {
		FloatingSearchButton("Search Me", searchText: .constant("")) { Text("Label here") }
	}
}
