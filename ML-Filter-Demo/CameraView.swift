//
//  CameraView.swift
//  MLFilterApp
//

import SwiftUI

struct CameraView: View {

  let model: CoreMLExecutor.Model
  let captureMode: CaptureMode

  @Environment(\.dismiss) var dismiss
  @State private var camera = CameraViewController()
  @State private var executor = CoreMLExecutor()
  @State private var previewImage: UIImage?

  var body: some View {
    NavigationView {
      ZStack {
        CameraPreview(camera: $camera)
         .ignoresSafeArea(.all, edges: .all)
        if let image = previewImage {
          Image(uiImage: image)
        }
      }
       .toolbar {
         Button("Done") {
           dismiss()
         }
       }
    }
     .onAppear { onAppear() }
     .onChange(of: executor.composedImage) { composedImage in
       /// Add custom logic and UI to display composed image or save it to user library
     }
  }

  private func onAppear() {
    do {
      try executor.loadModel(model)
      executor.onIncomingCameraImage(camera.$imageBuffer)
    } catch {
      // handle exception
    }
    // Show a dummy image
    previewImage = UIColor.red.imageWithColor()
  }
}


/// Integrate UIKit view with SwiftUI view
private struct CameraPreview: UIViewControllerRepresentable {

  @Binding var camera: CameraViewController

  func makeUIViewController(context: Context) -> CameraViewController {

    camera
  }

  func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {

  }
}
