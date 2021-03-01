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

class QrScannerViewController: BaseViewController, QrScannerViewDelegate {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var qrScannerView: QrScannerView!
    
    @IBOutlet weak var targetImage: UIImageView!
    
    var router: AppRouter!
    
    var venueRecordUseCase: VenueRecordUseCase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrScannerView.delegate = self
        
        
    }
    
    override func viewDidLayoutSubviews() {
        addQrTransparentWindowToBackground()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        qrScannerView.startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        qrScannerView.stopScanning()
        
        super.viewWillDisappear(animated)
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
        debugPrint("Scan Failed")
    }
    
    func qrScanningSucceededWithCode(_ result: String?) {
        venueRecordUseCase.getVenueInfo(qrCode: result ?? "").subscribe(
            onNext: { [weak self] exposition in
                guard let self = self else { return }
                self.router.route(to: .qrResult, from: self, parameters: result)
            }, onError: { [weak self] error in
                
//                TODO: duda pantalla de error??
                self?.showAlertOk(
                    title: "",
                    message: "ERROR SCANNER",
                    buttonTitle: "ALERT_ACCEPT_BUTTON".localized)
                
            }).disposed(by: disposeBag)
        
    }
    
    func qrScanningDidStop() {
        debugPrint("Scan stopped")
    }

}
