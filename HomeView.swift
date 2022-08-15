//
//  ContentView.swift
//  MLFilterApp
//

import SwiftUI


struct HomeView: View {

  @State private var selectedModel: CoreMLExecutor.Model = .ModelA
  @State private var selectedCaptureMode: CaptureMode = .single
  @State private var showCameraView: Bool = false

  var body: some View {

    Text("MyApp")
     .bold()
     .padding()

    Form {
      Section(header: Text("Select a model:")) {
        Picker("Model", selection: $selectedModel) {
          ForEach(CoreMLExecutor.Model.allCases) { type in
            Text(type.rawValue)
          }
        }
         .pickerStyle(.segmented)

      }


      Section(header: Text("Select a capture mode:")) {
        Picker("CaptureMode", selection: $selectedCaptureMode) {
          ForEach(CaptureMode.allCases) { type in
            Text(type.rawValue)
          }
        }
         .pickerStyle(.segmented)
      }

      Button("Start") {
        print("selectedModel is \(selectedModel)")
        print("selectedCaptureMode is \(selectedCaptureMode)")
        showCameraView.toggle()
      }
       .padding()
       .sheet(isPresented: $showCameraView) {
         CameraView(model: selectedModel, captureMode: selectedCaptureMode)
       }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
