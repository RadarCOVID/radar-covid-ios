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
import DP3TSDK
import SafariServices

class TimeExposedView: UIView {

    @IBAction func onCloseAction(_ sender: Any) {
        removePopUpView()
    }
    var parentViewController: UIViewController?
    var viewModel: HomeViewModel?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bullet1: UILabel!
    @IBOutlet weak var bullet2: UILabel!
    @IBOutlet weak var bullet3: UILabel!
    @IBOutlet weak var moreinfo: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBAction func onAcceptButton(_ sender: Any) {
        removePopUpView()
    }
    
    class func initWithParentViewController(viewController: HomeViewController)  {
        guard let timeExposedView = UINib(nibName: "TimeExposed", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TimeExposedView else {
            return
        }
        timeExposedView.parentViewController = viewController
        timeExposedView.viewModel = viewController.viewModel
        timeExposedView.initValues()
        let newFrame = CGRect(x: viewController.view.frame.origin.x, y: viewController.view.frame.origin.y, width: viewController.view.frame.width * 92 / 100, height: viewController.view.frame.height * 85 / 100)
        timeExposedView.frame = newFrame
        timeExposedView.center = viewController.view.center
        viewController.view.addSubview(timeExposedView)
    }
    
    func initValues() {
        containerView.layer.masksToBounds = true;
        containerView.layer.cornerRadius = 8;
        bullet1.isUserInteractionEnabled = true
        bullet2.isUserInteractionEnabled = true
        moreinfo.isUserInteractionEnabled = true
        bullet1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapPrecauciones(tapGestureRecognizer:))))
        bullet2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapSintomas(tapGestureRecognizer:))))
        moreinfo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userDidTapInformacion(tapGestureRecognizer:))))
        setupAccessibility()
    }
    
    func setupAccessibility() {
        closeButton.isAccessibilityElement = true
        closeButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        closeButton.accessibilityHint = "ACC_HINT".localized
        
        acceptButton.isAccessibilityElement = true
        acceptButton.accessibilityLabel = "ACC_BUTTON_ACCEPT".localized
        acceptButton.accessibilityHint = "ACC_HINT".localized
    }
    
    func removePopUpView() {
        viewModel?.setTimeExposedDismissed(value: true)
        for view in parentViewController?.view.subviews ?? [] {
            if view.tag == 1111 {
                view.fadeOut { (_) in
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    @objc func userDidTapClose(tapGestureRecognizer: UITapGestureRecognizer) {
        removePopUpView()
    }
    
    @objc func userDidTapPrecauciones(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "ALERT_HIGH_EXPOSURE_HEALED_BULLET_1_URL".localized)
    }
    
    @objc func userDidTapSintomas(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "ALERT_HIGH_EXPOSURE_HEALED_BULLET_2_URL".localized)
    }
    
    @objc func userDidTapInformacion(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: "ALERT_HIGH_EXPOSURE_HEALED_MORE_URL".localized)
    }
    
    @objc func onWebTap(tapGestureRecognizer: UITapGestureRecognizer, urlString: String? = nil) {
        guard var urlString = urlString else {
            return
        }

        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }
        if let url = URL(string: urlString) {
            let config = SFSafariViewController.Configuration()

            let viewController = SFSafariViewController(url: url, configuration: config)
            parentViewController?.present(viewController, animated: true)
        }
    }
    
}
