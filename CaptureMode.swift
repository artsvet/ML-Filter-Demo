//
//  CaptureMode.swift
//  MLFilterApp
//

import Foundation


enum CaptureMode: String, CaseIterable, Identifiable {
  case single, live
  var id: Self { self }
}
