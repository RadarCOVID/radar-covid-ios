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
import RxCocoa
import RxSwift

protocol AlertController: class {
    func showAlertOk(title: String,
                     message: String,
                     buttonTitle: String,
                     _ callback: (() -> Void)?)
    
    func showAlertCancelContinue(
        title: NSAttributedString,
        message: NSAttributedString,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        buttonOkVoiceover: String?,
        buttonCancelVoiceover: String?,
        okHandler: (() -> Void)?,
        cancelHandler: (() -> Void)?
    )
    func showAlertCancelContinue(
        title: NSAttributedString,
        message: NSAttributedString,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        buttonOkVoiceover: String?,
        buttonCancelVoiceover: String?,
        okHandler: (() -> Void)?
    )
}

extension UIViewController: AlertController {
    
    func showAlertOk(title: String, message: String, buttonTitle: String, _ callback: (() -> Void)? = nil) {
        self.view.window?.rootViewController?.view.showTransparentBackground()

        let okButton = UIButton()
        okButton.setTitle(buttonTitle, for: .normal)
        okButton.setTitleColor(UIColor.white, for: .normal)
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
        okButton.setBackgroundImage(UIImage.init(named: "buttonsPrimary"), for: .normal)
        okButton.tag = CustomAlert.okTag
        okButton.isUserInteractionEnabled = true
        okButton.isAccessibilityElement = true
        okButton.accessibilityHint = "ACC_HINT".localized
        
        DispatchQueue.main.async { [weak self] in
            let viewShow = self?.view.window?.rootViewController?.view ?? self?.view ?? UIView()
            let _ = CustomAlert.initWithParentView(
                view:  viewShow
                , buttons: [okButton]
                , title: NSAttributedString(string: title)
                , message: NSAttributedString(string: message)
                , buttonClicked: {
                    _ in
                    viewShow.removeTransparentBackGround()
                    callback?()
                })
        }
    }

    func showAlertCancelContinue(
        title: NSAttributedString,
        message: NSAttributedString,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        buttonOkVoiceover: String? = nil,
        buttonCancelVoiceover: String? = nil,
        okHandler: (() -> Void)? = nil,
        cancelHandler: (() -> Void)? = nil
    ) {
        self.view.window?.rootViewController?.view.showTransparentBackground()

        let okButton = UIButton()
        okButton.setTitle(buttonOkTitle, for: .normal)
        okButton.setTitleColor(UIColor.white, for: .normal)
        okButton.setBackgroundImage(UIImage.init(named: "buttonsPrimary"), for: .normal)
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
        okButton.tag = CustomAlert.okTag
        okButton.isUserInteractionEnabled = true
        okButton.isAccessibilityElement = true
        okButton.accessibilityHint = "ACC_HINT".localized

        let cancelButton = UIButton()
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.tag = CustomAlert.cancelTag
        cancelButton.layer.borderColor = UIColor.degradado.cgColor
        cancelButton.setTitle(buttonCancelTitle, for: .normal)
        cancelButton.setTitleColor(UIColor.degradado, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
        cancelButton.accessibilityHint = "ACC_HINT".localized
        
        DispatchQueue.main.async { [weak self] in
            let viewShow = self?.view.window?.rootViewController?.view ?? self?.view ?? UIView()
            let _ = CustomAlert.initWithParentView(
                view: viewShow
                , buttons: [okButton, cancelButton]
                , title: title
                , message: message
                , buttonClicked: {
                    button in
                    viewShow.removeTransparentBackGround()
                    button === okButton
                        ? okHandler?()
                        : cancelHandler?()
                })
        }
    }

    func showAlertCancelContinue(
        title: NSAttributedString,
        message: NSAttributedString,
        buttonOkTitle: String,
        buttonCancelTitle: String,
        buttonOkVoiceover: String? = nil,
        buttonCancelVoiceover: String? = nil,
        okHandler: (() -> Void)? = nil
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
}
