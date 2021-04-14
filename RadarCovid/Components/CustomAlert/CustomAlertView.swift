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

protocol CustomAlertProtocol {
    func hiddenTermsdView()
}

class CustomAlert: UIView {
    
    static let cancelTag = 128
    static let okTag = 127

    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonContainerHeight: NSLayoutConstraint!
    
    private weak var cancelButton: UIButton?
    private weak var okButton: UIButton?

    var parentView: UIView?
    
    let buttonHeight: CGFloat = 60
    
    class func initWithParentView(view: UIView, buttons: [UIButton], title: NSAttributedString, message: NSAttributedString, buttonClicked: @escaping (_ button: UIButton) -> Void ) -> CustomAlert? {
        
        guard let alert = UINib(nibName: "CustomAlert", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? CustomAlert else {
            return nil
        }
        alert.setupAccesibility()
        
        let buttonsHeight = CGFloat(alert.buttonHeight * CGFloat(buttons.count))
        alert.buttonContainerHeight.constant = buttonsHeight
        
        buttons.forEach { button in
            if button.tag == CustomAlert.cancelTag {
                alert.cancelButton = button
            } else if button.tag == CustomAlert.okTag {
                alert.okButton = button
            }
    
            button.rx.tap.subscribe(onNext: { (_) in
                   buttonClicked(button)
            }).disposed(by: alert.disposeBag)
            
            button.heightAnchor.constraint(equalToConstant: alert.buttonHeight).isActive = true
            alert.buttonContainer.addArrangedSubview(button)
        }
        alert.titleLabel.text = title.string
        alert.contentLabel.text = message.string
        alert.setFontTextStyle()
        alert.parentView = view
        alert.initValues()
        
        let totalPadding = CGFloat( 40 + 80 )
        let titleLabelWidth = alert.titleLabel.textHeight(withWidth: alert.titleLabel.frame.size.width) + 10
        let contentLabelWidth = alert.contentLabel.textHeight(withWidth: alert.contentLabel.frame.size.width) + 10
        let height = buttonsHeight + titleLabelWidth + contentLabelWidth + totalPadding
        let finalHeight = view.frame.height * 0.8 > height ? height : view.frame.height * 0.8
        
        let newFrame = CGRect(x: view.frame.origin.x,
                              y: view.frame.origin.y,
                              width: view.frame.width * 92 / 100,
                              height: finalHeight )
        alert.frame = newFrame
        alert.center = view.center
        alert.accessibilityViewIsModal = true
        view.addSubview(alert)
        view.bringSubviewToFront(alert)
        
        
        UIAccessibility.post(notification: .screenChanged, argument: nil)
        UIAccessibility.post(notification: .layoutChanged, argument: alert.titleLabel)
        
        return alert
    }
    
    private func setupAccesibility() {
        closeButton.isUserInteractionEnabled = true
        closeButton.isAccessibilityElement = true
        closeButton.accessibilityHint = "ACC_HINT".localized
        closeButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
    }
    
    @IBAction func onClose(_ sender: Any) {
        if let cancelButton = cancelButton {
            cancelButton.sendActions(for: .touchUpInside)
        } else {
            okButton?.sendActions(for: .touchUpInside)
        }
    }

    private func initValues() {
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 8
    }
    
    func removePopUpView() {
        self.fadeOut { (_) in
            self.removeFromSuperview()

        }
    }
}
