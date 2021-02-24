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

class QrScannerViewController: UIViewController, QrScannerViewDelegate {
    
    @IBOutlet weak var qrScannerView: QrScannerView!
    
    @IBOutlet weak var targetImage: UIImageView!
    
    var router: AppRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrScannerView.delegate = self
        
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
        
        let pathBigRect = UIBezierPath(rect: view.bounds)
        let inset = CGFloat(15)
        let pathSmallRect = UIBezierPath(rect: targetImage.frame.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)))

        pathBigRect.append(pathSmallRect)
        pathBigRect.usesEvenOddFillRule = true
        
        fillLayer.path = pathBigRect.cgPath
        
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.blueyGrey62.cgColor
        
        view.layer.addSublayer(fillLayer)
    }
    
    func qrScanningDidFail() {
        debugPrint("Scan Failed")
    }
    
    func qrScanningSucceededWithCode(_ result: String?) {
        router.route(to: .qrResult, from: self, parameters: result)
    }
    
    func qrScanningDidStop() {
        debugPrint("Scan stopped")
    }

}
