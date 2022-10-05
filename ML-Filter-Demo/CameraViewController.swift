//
//  CameraViewController.swift
//  MLFilterApp
//

import SwiftUI
import AVFoundation


class CameraViewController: UIViewController, ObservableObject {

  @Published var imageBuffer: CVImageBuffer?

  private var captureSession = AVCaptureSession()
  private var previewLayer: AVCaptureVideoPreviewLayer!

  override func viewDidLoad() {

    print("CameraViewController.viewDidLoad")

    guard requestCameraPermission()
    else { return }

    guard configureCaptureSession()
    else { return }

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.frame
    previewLayer.videoGravity = .resizeAspect
    view.layer.addSublayer(previewLayer)

  }

  /// Request permission to use camera device
  /// Return true if permission is granted, else false.
  private func requestCameraPermission() -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .authorized: // The user has previously granted access to the camera.
        return true
    
      case .notDetermined: // The user has not yet been asked for camera access.
        AVCaptureDevice.requestAccess(for: .video) { granted in
          if granted {
              return true
          }
        }
    
      case .denied: // The user has previously denied access.
        return false

      case .restricted: // The user can't grant access due to restrictions.
        return false
    }
  }

  /// Setup capture session, configure camera device
  /// Return true if success, else false.
  private func configureCaptureSession() -> Bool {
    
    // Look up and configure macro camera.
    // Macro only
    captureSession.beginConfiguration()  
    let macroDevice = AVCaptureDevice.default(.builtInUltraWideCamera, 
                                              for: .video, position: .back)
    
    guard let videoDeviceInput = try? AVCaptureDeviceInput(device: macroDevice!),
      captureSession.canAddInput(videoDeviceInput)
      else { return }
    captureSession.addInput(videoDeviceInput)

    let photoOutput = AVCapturePhotoOutput()
    guard captureSession.canAddOutput(photoOutput) else { return }
    captureSession.sessionPreset = .photo
    captureSession.addOutput(photoOutput)
    captureSession.commitConfiguration()
    return true
   
  }
  
  /// Configure Lidar inputs 
  private func configureLidar() -> AVCaptureDevice { 

    guard let lidarDevice = try? AVCaptureDevice.default(.builtInLiDARDepthCamera, 
                                                          for: .video, position: .back)
      else { throw ConfigurationError.lidarDeviceUnavailable }

    // Find a match that outputs video data in the format the app's custom Metal views require.
    guard let format = (lidarDevice.formats.last { format in
      format.formatDescription.dimensions.width == preferredWidthResolution &&
      format.formatDescription.mediaSubType.rawValue == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange &&
      !format.isVideoBinned &&
      !format.supportedDepthDataFormats.isEmpty
    }) else {
      throw ConfigurationError.requiredFormatUnavailable
    }
  
    // Begin the device configuration.
    try lidarDevice.lockForConfiguration()

    // Configure the device and depth formats.
    lidarDevice.activeFormat = format
    lidarDevice.activeDepthDataFormat = depthFormat

    // Finish the device configuration.
    lidarDevice.unlockForConfiguration()
    return lidarDevice
  }

  ///sync lidar with macro 
  private func configureCaptureOutputs() -> AVCaptureDataOutputSynchronizer {

     // Create an object to output video sample buffers.
    videoDataOutput = AVCaptureVideoDataOutput()
    captureSession.addOutput(videoDataOutput)

    // Create an object to output depth data.
    depthDataOutput = AVCaptureDepthDataOutput()
    depthDataOutput.isFilteringEnabled = false
    captureSession.addOutput(depthDataOutput)

    // Create an object to synchronize the delivery of depth and video data.
    outputVideoSync = AVCaptureDataOutputSynchronizer(dataOutputs: [depthDataOutput, videoDataOutput])
    outputVideoSync.setDelegate(self, queue: videoQueue)

    // Create an object to output photos.
    photoOutput = AVCapturePhotoOutput()
    photoOutput.maxPhotoQualityPrioritization = .quality
    captureSession.addOutput(photoOutput)

    // Enable delivery of depth data after adding the output to the capture session.
    photoOutput.isDepthDataDeliveryEnabled = true

  }
}  


extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

  func captureOutput(_ output: AVCaptureOutput,
                     didOutput sampleBuffer: CMSampleBuffer,
                     from connection: AVCaptureConnection) {

    guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    else { return }

    imageBuffer = buffer
  }
}

///