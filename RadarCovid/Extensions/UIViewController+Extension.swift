//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import UIKit
import SafariServices

extension UIViewController {

    func open(phone: String) {
        let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))")

        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            debugPrint("Cant open dialer: \(String(describing: url?.description))")
        }
    }

    func showAlertOk(title: String, message: String, buttonTitle: String, buttonVoiceover: String, _ callback: ((Any) -> Void)? = nil) {

        let uiAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: buttonTitle, style: .default) { (alert) in
            self.view.removeTransparentBackGround()
            callback?(alert)
        }
        action.isAccessibilityElement = true
        action.accessibilityLabel = buttonVoiceover
        uiAlert.addAction(action)
        let buttonView = uiAlert.view.subviews.first?.subviews.first?.subviews.first?.subviews[1]
        uiAlert.view.tintColor = UIColor.white
        buttonView?.backgroundColor  = #colorLiteral(red: 0.4550000131, green: 0.5799999833, blue: 0.92900002, alpha: 1)

        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1)
        self.present(uiAlert, animated: true, completion: nil)
    }

    func showAlertCancelContinue(
        title: String,
        message: String,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        buttonOkVoiceover: String,
        buttonCancelVoiceover: String,
        okHandler: ((UIAlertAction) -> Void)? = nil,
        cancelHandler: ((UIAlertAction) -> Void)? = nil
    ) {

        let uiAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: buttonOkTitle, style: .default) { (action) in
            self.view.removeTransparentBackGround()
            okHandler?(action)
        }
        action.isAccessibilityElement = true
        action.accessibilityLabel = buttonOkVoiceover
        uiAlert.addAction(action)

        let actionCancel = UIAlertAction(title: buttonCancelTitle, style: .default) { (action) in
            self.view.removeTransparentBackGround()
            cancelHandler?(action)
        }
        actionCancel.isAccessibilityElement = true
        actionCancel.accessibilityLabel = buttonCancelVoiceover
        uiAlert.addAction(actionCancel)
        let buttonView = uiAlert.view.subviews.first?.subviews.first?.subviews.first?.subviews[1]
        uiAlert.view.tintColor = UIColor.white
        buttonView?.backgroundColor  = #colorLiteral(red: 0.4550000131, green: 0.5799999833, blue: 0.92900002, alpha: 1)

        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1)
        self.present(uiAlert, animated: true, completion: nil)

    }

    func showAlertCancelContinue(
        title: String,
        message: String,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        buttonOkVoiceover: String,
        buttonCancelVoiceover: String,
        okHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        showAlertCancelContinue(
            title: title,
            message: message,
            buttonOkTitle: buttonOkTitle,
            buttonCancelTitle: buttonCancelTitle,
            buttonOkVoiceover: buttonOkVoiceover,
            buttonCancelVoiceover: buttonCancelVoiceover,
            okHandler: okHandler,
            cancelHandler: nil
        )
    }

    @objc func onWebTap(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: (tapGestureRecognizer.view as? UILabel)?.text)
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
            present(viewController, animated: true)
        }
    }

}
