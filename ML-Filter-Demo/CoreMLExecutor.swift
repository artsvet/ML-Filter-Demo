//
//  CoreMLExecutor.swift
//  MLFilterApp
//

import AVFoundation
import CoreML
import Combine

class CoreMLExecutor {

  @Published var predictedImage: CVImageBuffer?
  @Published var composedImage: CVImageBuffer?

  private var disposables: Set<AnyCancellable> = []
  private var mlModel: MLModel?

  /// Setup a processing pipeline on incoming camera image
  func onIncomingCameraImage(_ cameraImage: Published<CVImageBuffer?>.Publisher) {
    cameraImage
     .compactMap { $0 }
     .filter { [self] cameraImage in
       self.filter(imageBuffer: cameraImage)
     }
     .sink { [weak self] cameraImage in
       guard let self = self
       else { return }
       do {
         let preprocessedImage = try self.preprocess(imageBuffer: cameraImage)
         let predictedImage = try self.runPrediction(on: preprocessedImage)
         let composedImage = try self.compose(cameraImage, with: predictedImage)
         self.predictedImage = predictedImage
         self.composedImage = composedImage
       } catch {
         // handle exception
       }
     }
     .store(in: &disposables)

  }

  /// Load the selected model and assign it to mlModel
  func loadModel(_ model: Model) throws {
    switch model {
      case .ModelA: return
      case .ModelB: return
      case .ModelC: return
    }
  }

  /// Filter the image and let only image with certain criteria go through
  /// Return false if the image should be ignored, else true
  private func filter(imageBuffer: CVImageBuffer) -> Bool {
    true
  }

  /// Do any preprocessing steps needed
  private func preprocess(imageBuffer: CVImageBuffer) throws -> CVImageBuffer {
    imageBuffer
  }

  /// Run the prediction on the image and return the predicted image
  private func runPrediction(on imageBuffer: CVImageBuffer) throws -> CVImageBuffer {
    imageBuffer
  }

  /// Compose camera image with predicted image
  private func compose(_ cameraImage: CVImageBuffer, with predictedImage: CVImageBuffer) throws -> CVImageBuffer {
    predictedImage
  }

  enum Model: String, CaseIterable, Identifiable {
    case ModelA
    case ModelB
    case ModelC
    var id: Self { self }
  }

}
