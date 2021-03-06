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

protocol PickerDelegate: class {
    var containerView: UIView { get }
    func onDone()
    func onCancel()
}

class PickerPresenter {

    private var toolBar: UIToolbar?
    private let picker: UIView
    private var pickerOpened = false
    private let showCancel: Bool
    
    weak var delegate: PickerDelegate?

    init( picker: UIView, showCancel: Bool = false) {
        self.picker = picker
        self.showCancel = showCancel
    }
    
    func openPicker(title: String? = nil) {
        if !pickerOpened {
            pickerOpened = true
            picker.backgroundColor = UIColor.white
            picker.setValue(UIColor.black, forKey: "textColor")
            picker.autoresizingMask = .flexibleWidth
            picker.contentMode = .center
            picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300,
                                       width: UIScreen.main.bounds.size.width, height: 300)
            picker.setFontTextStyle();
            delegate?.containerView.addSubview(picker)

            toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300,
                                                        width: UIScreen.main.bounds.size.width, height: 50))
            toolBar!.barStyle = .default
            toolBar!.items = []
           
            if showCancel {
                let itemCancelButton = UIBarButtonItem.init(title: "ALERT_CANCEL_BUTTON".localized, style: .done,
                                                target: self, action: #selector(onCancelButtonTapped))
                itemCancelButton.isAccessibilityElement = true
                itemCancelButton.accessibilityLabel = "ALERT_CANCEL_BUTTON".localized
                itemCancelButton.accessibilityHint = "ACC_HINT".localized
                toolBar!.items?.append(itemCancelButton)
            }
            let itemFlexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            toolBar!.items?.append(itemFlexibleButton)
            
            let itemDoneButton = UIBarButtonItem.init(title: "SELECTOR_DONE".localized, style: .done, target: self, action: #selector(onDoneButtonTapped))
            itemDoneButton.isAccessibilityElement = true
            itemDoneButton.accessibilityLabel = "ACC_BUTTON_SELECTOR_DONE".localized
            itemDoneButton.accessibilityHint = "ACC_HINT".localized
            toolBar!.items?.append(itemDoneButton)
            
            UIAccessibility.post(notification: .screenChanged, argument: title)
            delegate?.containerView.addSubview(toolBar!)

        }
    }

    func hidePickerView() {
        toolBar?.removeFromSuperview()
        picker.removeFromSuperview()
        pickerOpened = false
    }
    
    @objc func onDoneButtonTapped() {
        hidePickerView()
        delegate?.onDone()
    }
    
    @objc func onCancelButtonTapped() {
        hidePickerView()
        delegate?.onCancel()
    }
}
