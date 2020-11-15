//
//  QRCodeScannerView.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 29/09/2020.
//

import SwiftUI

struct QRCodeScannerView: UIViewControllerRepresentable {
  final class Coordinator: QRCodeScannerViewControllerDelegate {
    private let parent: QRCodeScannerView
    
    init(_ parent: QRCodeScannerView) {
      self.parent = parent
    }
    
    func qrCodeScannerViewController(_ viewController: QRCodeScannerViewController, didFoundQRCode qrCode: String) {
      parent.qrCode = qrCode
    }
  }
  
  @Binding var qrCode: String?
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIViewController(context: Context) -> QRCodeScannerViewController {
    let vc = QRCodeScannerViewController()
    vc.delegate = context.coordinator
    return vc
  }
  
  func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {
    if qrCode == nil {
      uiViewController.startCapture()
    } else {
      uiViewController.stopCapture()
    }
  }
}
