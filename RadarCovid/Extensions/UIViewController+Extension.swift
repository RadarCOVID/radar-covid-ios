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

    @objc func onWebTap(tapGestureRecognizer: UITapGestureRecognizer) {
        onWebTap(tapGestureRecognizer: tapGestureRecognizer, urlString: (tapGestureRecognizer.view as? UILabel)?.text)
    }

    @objc func onWebTap(tapGestureRecognizer: UITapGestureRecognizer?, urlString: String? = nil) {
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
