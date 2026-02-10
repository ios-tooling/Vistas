//
//  ContentView.swift
//  VistasTestHarness
//
//  Created by Ben Gottlieb on 2/8/26.
//

import Suite
import Vistas

struct ContentView: View {
	@State private var selectedImage: UIImage?
	@State private var showingCamera = false
	
	var cameraManager: CameraManaging { Gestalt.isOnSimulator ? MockCameraManager.instance : CameraManager.instance }
	
	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					CameraScreen(manager: cameraManager) { image in print(image) }
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
		.fullScreenCover(isPresented: $showingCamera) {
			CameraScreen(manager: cameraManager) { image in print(image) }
		}
		.onAppear {
			if Gestalt.isOnSimulator {
				MockCameraManager.instance.sampleImages = ["sample_1", "sample_2", "sample_3"].compactMap { UIImage(named: $0) }
				
				MockCameraManager.instance.saveImage(MockCameraManager.instance.sampleImages[0])
				MockCameraManager.instance.saveImage(MockCameraManager.instance.sampleImages[1])
				MockCameraManager.instance.saveImage(MockCameraManager.instance.sampleImages[2])
			}
			showingCamera = true
		}
	}
}

#Preview {
    ContentView()
}
