//
//  igViewController.swift
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

import UIKit
import AVFoundation

@objc(igViewController)
class igViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let highlightView = UIView()
    private let label = UILabel()
    private var lastCapture: String?

    private let barCodeTypes: [AVMetadataObject.ObjectType] = [
        .upce, .code39, .code39Mod43, .ean13, .ean8,
        .code93, .code128, .pdf417, .qr, .aztec
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        highlightView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        highlightView.layer.borderColor = UIColor.green.cgColor
        highlightView.layer.borderWidth = 3
        view.addSubview(highlightView)

        label.frame = CGRect(x: 0, y: view.bounds.size.height - 40, width: view.bounds.size.width, height: 40)
        label.autoresizingMask = .flexibleTopMargin
        label.backgroundColor = UIColor(white: 0.15, alpha: 0.65)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "(none)"
        view.addSubview(label)

        guard let device = AVCaptureDevice.default(for: .video) else {
            print("Error: no video capture device available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
        } catch {
            print("Error: \(error)")
        }

        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        // Capture sessions block the calling thread when started; run it off the main thread.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        var highlightViewRect = CGRect.zero

        for metadata in metadataObjects {
            guard barCodeTypes.contains(metadata.type),
                  let readable = metadata as? AVMetadataMachineReadableCodeObject,
                  let detectionString = readable.stringValue else {
                label.text = "(none)"
                continue
            }

            if let transformed = previewLayer?.transformedMetadataObject(for: readable) {
                highlightViewRect = transformed.bounds
            }

            if detectionString != lastCapture {
                print("Activate session \(detectionString)")
                DBZ_ServerCommunication.activateSession(detectionString)
                NotificationCenter.default.post(name: Notification.Name("SessionActivated"), object: nil)
            }
            lastCapture = detectionString
            break
        }

        highlightView.frame = highlightViewRect
    }
}
