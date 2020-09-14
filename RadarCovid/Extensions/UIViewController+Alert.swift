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

protocol AlertController: class{
    func showAlertOk(title: String, message: String, buttonTitle: String, _ callback: ((Any) -> Void)?)
    func showAlertCancelContinue(
        title: String,
        message: String,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        okHandler: ((UIAlertAction) -> Void)?,
        cancelHandler: ((UIAlertAction) -> Void)?
    )
    func showAlertCancelContinue(
        title: String,
        message: String,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        okHandler: ((UIAlertAction) -> Void)?
    )
}

extension UIViewController : AlertController {

    func showAlertOk(title: String, message: String, buttonTitle: String, _ callback: ((Any) -> Void)? = nil) {

        let uiAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: buttonTitle, style: .default) { (alert) in
            self.view.removeTransparentBackGround()
            callback?(alert)
        }
        uiAlert.addAction(action)
        let buttonView = uiAlert.view.subviews.first?.subviews.first?.subviews.first?.subviews[1]
        uiAlert.view.tintColor = UIColor.white
        buttonView?.backgroundColor  = #colorLiteral(red: 0.2, green: 0.1882352941, blue: 0.7254901961, alpha: 1)

        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1)
        self.present(uiAlert, animated: true, completion: nil)
    }

    func showAlertCancelContinue(
        title: String,
        message: String,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        okHandler: ((UIAlertAction) -> Void)? = nil,
        cancelHandler: ((UIAlertAction) -> Void)? = nil
    ) {

        let uiAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: buttonOkTitle, style: .default) { (action) in
            self.view.removeTransparentBackGround()
            okHandler?(action)
        }
        uiAlert.addAction(action)

        let actionCancel = UIAlertAction(title: buttonCancelTitle, style: .default) { (action) in
            self.view.removeTransparentBackGround()
            cancelHandler?(action)
        }
        uiAlert.addAction(actionCancel)
        let buttonView = uiAlert.view.subviews.first?.subviews.first?.subviews.first?.subviews[1]
        uiAlert.view.tintColor = UIColor.white
        buttonView?.backgroundColor  = #colorLiteral(red: 0.2, green: 0.1882352941, blue: 0.7254901961, alpha: 1)

        self.view.showTransparentBackground(withColor: UIColor.blueyGrey90, alpha: 1)
        self.present(uiAlert, animated: true, completion: nil)

    }

    func showAlertCancelContinue(
        title: String,
        message: String,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        okHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        showAlertCancelContinue(
            title: title,
            message: message,
            buttonOkTitle: buttonOkTitle,
            buttonCancelTitle: buttonCancelTitle,
            okHandler: okHandler,
            cancelHandler: nil
        )
    }

}
