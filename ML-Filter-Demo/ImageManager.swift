//
//  ImageManager.swift
//  MLFilterApp
//

import Foundation
import AVFoundation
import UIKit

final class ImageManager {

  /// Save the image to user library
  static func saveImageToLibrary(image: CVImageBuffer) throws {

  }

  /// Convert the image from CVImageBuffer to UIImage for display
  static func createUIImageFromCVImageBuffer(buffer: CVImageBuffer) throws -> UIImage {
    // Return a dummy image to avoid compiler error
    UIColor.red.imageWithColor()
  }

}

extension UIColor {
  func imageWithColor() -> UIImage {
    let size = CGSize(width: 200, height: 200)
    return UIGraphicsImageRenderer(size: size).image { rendererContext in
      setFill()
      rendererContext.fill(CGRect(origin: .zero, size: size))
    }
  }
}