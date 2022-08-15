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
    false
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
