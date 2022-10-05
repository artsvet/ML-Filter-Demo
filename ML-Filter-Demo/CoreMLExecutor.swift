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

  /// Filter the image and let only image with stdev > passVal go through
  /// Return false if the image should be ignored, else true
  private func filter(imageBuffer: CVImageBuffer) -> Bool {
    
    //setpoint for filter sharpness
    let passVal : Int = 0

    //Cast CVImageBuffer to CVPixelBuffer and lock
    guard let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
    fatalError("Error acquiring pixel buffer.")
    }
    CVPixelBufferLockBaseAddress(pixelBuffer,
                             CVPixelBufferLockFlags.readOnly)

    //Copy luminance data
    let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
    let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
    let count = width * height
    let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
    let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
    let lumaCopy = UnsafeMutableRawPointer.allocate(byteCount: count,
                                                    alignment: MemoryLayout<Pixel_8>.alignment)
    lumaCopy.copyMemory(from: lumaBaseAddress!,
                        byteCount: count)

    //Unlock and pass luminance to edge filter
    CVPixelBufferUnlockBaseAddress(pixelBuffer,
                               CVPixelBufferLockFlags.readOnly)
    DispatchQueue.global(qos: .utility).async {
        self.processImage(data: lumaCopy,
                          rowBytes: lumaRowBytes,
                          width: width,
                          height: height,
                          sequenceCount: photo.sequenceCount,
                          expectedCount: photo.resolvedSettings.expectedPhotoCount,
                          orientation: photo.metadata[ String(kCGImagePropertyOrientation) ] as? UInt32)

        lumaCopy.deallocate()
    }

    //Return grayscale image  
    var sourceBuffer = vImage_Buffer(data: data,
                                     height: vImagePixelCount(height),
                                     width: vImagePixelCount(width),
                                     rowBytes: rowBytes)
    
    //Clear row byte padding
    var floatPixels: [Float]
    let count = width * height
    if sourceBuffer.rowBytes == width * MemoryLayout<Pixel_8>.stride {
        let start = sourceBuffer.data.assumingMemoryBound(to: Pixel_8.self)
        floatPixels = vDSP.integerToFloatingPoint(
            UnsafeMutableBufferPointer(start: start,
                                       count: count),
            floatingPointType: Float.self)
    } else {
      floatPixels = [Float](unsafeUninitializedCapacity: count) {
          buffer, initializedCount in

          var floatBuffer = vImage_Buffer(data: buffer.baseAddress,
                                          height: sourceBuffer.height,
                                          width: sourceBuffer.width,
                                          rowBytes: width * MemoryLayout<Float>.size)

          vImageConvert_Planar8toPlanarF(&sourceBuffer,
                                         &floatBuffer,
                                         0, 255,
                                         vImage_Flags(kvImageNoFlags))

          initializedCount = count
      }
    }

    //Perform convolution, get stdev of pixel values for sharpness
    let laplacian: [Float] = [-1, -1, -1,
                              -1,  8, -1,
                              -1, -1, -1]

    vDSP.convolve(floatPixels,
                  rowCount: height,
                  columnCount: width,
                  with3x3Kernel: laplacian,
                  result: &floatPixels)
    
    var mean = Float.nan
    var stdDev = Float.nan

    vDSP_normalize(floatPixels, 1,
                   nil, 1,
                   &mean, &stdDev,
                   vDSP_Length(count))

    if stDev > passVal {
      return true
    }
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
