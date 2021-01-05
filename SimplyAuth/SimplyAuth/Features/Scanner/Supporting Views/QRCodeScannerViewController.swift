//
//  QRCodeScannerViewController.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 29/09/2020.
//

import AVFoundation
import Combine
import UIKit

protocol QRCodeScannerViewControllerDelegate: AnyObject {
  func qrCodeScannerViewController(_ viewController: QRCodeScannerViewController, didFoundQRCode qrCode: String)
}

final class QRCodeScannerViewController: UIViewController {
  private var captureSession: AVCaptureSession?
  private var previewLayer: AVCaptureVideoPreviewLayer?
  private var sessionCreationFailed = false
  
  weak var delegate: QRCodeScannerViewControllerDelegate?
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.black
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    createCaptureSession()
    startCapture()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if sessionCreationFailed {
      sessionCreationFailed = false
      failed()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    stopCapture()
    deleteCaptureSession()
  }
  
  func startCapture() {
    if captureSession?.isRunning == false {
      captureSession?.startRunning()
    }
  }
  
  func stopCapture() {
    if captureSession?.isRunning == true {
      captureSession?.stopRunning()
    }
  }
  
  private func createCaptureSession() {
    captureSession = AVCaptureSession()
    
    guard
      let videoCaptureDevice = AVCaptureDevice.default(for: .video)
    else {
      sessionCreationFailed = true
      return
    }
    let videoInput: AVCaptureDeviceInput
    
    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      sessionCreationFailed = true
      return
    }
    
    if captureSession?.canAddInput(videoInput) == true {
      captureSession?.addInput(videoInput)
    } else {
      sessionCreationFailed = true
      return
    }
    
    let metadataOutput = AVCaptureMetadataOutput()
    
    if captureSession?.canAddOutput(metadataOutput) == true {
      captureSession?.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.qr]
    } else {
      sessionCreationFailed = true
      return
    }
    
    if let session = captureSession {
      previewLayer = AVCaptureVideoPreviewLayer(session: session)
      previewLayer!.frame = view.layer.bounds
      previewLayer!.videoGravity = .resizeAspectFill
      view.layer.addSublayer(previewLayer!)
    }
  }
  
  private func deleteCaptureSession() {
    captureSession = nil
    previewLayer?.removeFromSuperlayer()
    previewLayer = nil
  }
  
  private func failed() {
    let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    captureSession = nil
  }
  
  private func found(code: String) {
    print(code)
    delegate?.qrCodeScannerViewController(self, didFoundQRCode: code)
  }
}


extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
    if let metadataObject = metadataObjects.first {
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let stringValue = readableObject.stringValue else { return }
      found(code: stringValue)
    }
  }
}
