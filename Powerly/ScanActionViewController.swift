//
//  ScanActionViewController.swift
//  PowerShare
//
//  Created by admin on 17/12/22.
//  
//
import AVFoundation
import UIKit

class ScanActionViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet var qrView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    private let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)

    func turnOnOffFlash() {
        do {
            try captureDevice?.lockForConfiguration()
            if captureDevice?.torchMode == .on {
                captureDevice?.torchMode = .off
                flashButton.setImage(UIImage(named: "flashlight.off.fill"), for: .normal)
            } else {
                captureDevice?.torchMode = .on
                flashButton.setImage(UIImage(named: "flashlight.on.fill"), for: .normal)
            }
            captureDevice?.unlockForConfiguration()
        } catch {
            print("Error while trying to turn on flash: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.previewLayer?.frame = self.qrView.layer.bounds
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CommonUtils.logFacebookCustomEvents("scan_qr_open", contentType: [:])
        if captureSession?.isRunning == false {
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        }
        if captureSession == nil {
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                self.startSession()
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        //DispatchQueue.main.async {
                            self.startSession()
                       // }
                    } else {
                        DispatchQueue.main.async {
                            self.alertPromptToAllowCameraAccessViaSetting()
                        }
                    }
                })
            }
        }
    }
    
    func initUI() {
        titleLabel.font = .robotoMedium(ofSize: 16)
    }
    
    func startSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer?.videoGravity = .resizeAspectFill
        
        DispatchQueue.main.async {
            if let layer = self.previewLayer {
                self.qrView.layer.addSublayer(layer)
            }
            self.captureSession.startRunning()
            self.previewLayer?.frame = self.qrView.layer.bounds
        }
    }
    
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func found(code: String) {
        if self.checkScanAction(name: code) {
            self.captureSession.stopRunning()
        } else {
            
        }
        self.tabBarController?.selectedIndex = 0
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @IBAction func didTapOnFlashButton(_ sender: Any) {
        self.turnOnOffFlash()
    }
}

extension ScanActionViewController:  AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            //captureSession.stopRunning()

            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }
        }
}
