//
//  ContentView.swift
//  VistasTestHarness
//
//  Created by Ben Gottlieb on 2/8/26.
//

import SwiftUI
import Vistas

struct ContentView: View {
	@State private var selectedImage: UIImage?
	
	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					CameraScreen { image in print(image) }
				} label: {
					Text("Custom Camera Screen")
				}
				
				NavigationLink {
					StockCameraScreen { image in print(image) }
				} label: {
					Text("Stock Camera Screen")
				}
				
				NavigationLink {
					TakePictureScreen(fromLibrary: true, image: $selectedImage)
				} label: {
					Text("Choose from Library")
				}
				
				NavigationLink {
					TakePictureScreen(fromLibrary: false, image: $selectedImage)
				} label: {
					Text("Open Camera")
				}
				
			}
			.onChange(of: selectedImage) {
				print(String(describing: selectedImage))
			}
		}
	}
}

#Preview {
    ContentView()
}
