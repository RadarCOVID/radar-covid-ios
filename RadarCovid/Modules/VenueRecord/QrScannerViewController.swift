//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import UIKit
import RxSwift
import AVFoundation

class QrScannerViewController: BaseViewController, QrScannerViewDelegate {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var qrScannerView: QrScannerView!
    @IBOutlet weak var targetImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    
    var router: AppRouter!
    
    var venueRecordUseCase: VenueRecordUseCase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrScannerView.delegate = self
        setupView()
        setupAccesibility()
    }
    
    override func viewDidLayoutSubviews() {
        addQrTransparentWindowToBackground()
    }
    
    @IBAction func onFlashTap(_ sender: Any) {
        if let avDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            if avDevice.hasTorch {
                 do {
                     try avDevice.lockForConfiguration()
                    
                     if avDevice.isTorchActive {
                        switchTorchOff(avDevice)
                     } else {
                        switchTorchOn(avDevice)
                     }
                    
                 } catch {
                    debugPrint("Error configuring torch \(error.localizedDescription)")
                 }
             }
             avDevice.unlockForConfiguration()
         }
    }
    
    private func switchTorchOn(_ avDevice: AVCaptureDevice) {
        avDevice.torchMode = AVCaptureDevice.TorchMode.on
        flashButton.setImage(UIImage(named: "FlashOn"), for: .normal)
        flashButton.accessibilityLabel = "ACC_FLASH_ON".localized
        flashButton.accessibilityHint = "ACC_HINT_DISABLE".localized
    }
    
    private func switchTorchOff(_ avDevice: AVCaptureDevice) {
        avDevice.torchMode = AVCaptureDevice.TorchMode.off
        flashButton.setImage(UIImage(named: "FlashOff"), for: .normal)
        flashButton.accessibilityLabel = "ACC_FLASH_OFF".localized
        flashButton.accessibilityHint = "ACC_HINT".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrScannerView.startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        qrScannerView.stopScanning()
        super.viewWillDisappear(animated)
    }
    
    private func setupView() {
        self.title = "VENUE_QR_SCAN_TITLE".localized
    }
    
    private func setupAccesibility() {
        flashButton.isAccessibilityElement = true
        flashButton.accessibilityLabel = "ACC_FLASH_OFF".localized
        flashButton.accessibilityHint = "ACC_HINT".localized
        flashButton.accessibilityTraits.insert(UIAccessibilityTraits.button)
        
        headerLabel.isAccessibilityElement = true
        headerLabel.accessibilityTraits.insert(UIAccessibilityTraits.header)
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    private func addQrTransparentWindowToBackground() {
        
        let fillLayer = CAShapeLayer()
        
    
        let pathBigRect = UIBezierPath(rect: backgroundView.layer.bounds)
        let inset = CGFloat(15)
        let pathSmallRect = UIBezierPath(rect: targetImage.frame.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset , right: inset)))

        pathBigRect.append(pathSmallRect)
        pathBigRect.usesEvenOddFillRule = true
        
        fillLayer.path = pathBigRect.cgPath
        
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.blueyGrey62.cgColor
        
        backgroundView.layer.addSublayer(fillLayer)
    }
    
    func qrScanningDidFail() {
        router.route(to: .qrError, from: self)
    }
    
    func qrScanningSucceededWithCode(_ result: String?) {
        venueRecordUseCase.getVenueInfo(qrCode: result ?? "").subscribe(
            onNext: { [weak self] venueInfo in
                guard let self = self else { return }
                self.router.route(to: .qrResult, from: self, parameters: venueInfo)
            }, onError: { [weak self] error in
                debugPrint(error)
                guard let self = self else { return }
                self.router.route(to: .qrError, from: self, parameters: error)
            }).disposed(by: disposeBag)
        
    }
    
    func qrScanningDidStop() {
        debugPrint("Scan stopped")
    }

}

extension QrScannerViewController: AccTitleView {

    var accTitle: String? {
        get {
            "VENUE_QR_SCAN_TITLE".localized
        }
    }
}

