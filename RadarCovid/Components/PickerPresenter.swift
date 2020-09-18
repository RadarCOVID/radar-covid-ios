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
}

class PickerPresenter {

    private var toolBar: UIToolbar?
    private let picker: UIView
    private var pickerOpened = false

    weak var delegate: PickerDelegate?

    init( picker: UIView ) {
        self.picker = picker
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
            delegate?.containerView.addSubview(picker)

            toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300,
                                                        width: UIScreen.main.bounds.size.width, height: 50))
            toolBar!.barStyle = .default
            let item = UIBarButtonItem.init(title: "SELECTOR_DONE".localized, style: .done,
                                            target: self, action: #selector(onDoneButtonTapped))
            item.isAccessibilityElement = true
            item.accessibilityLabel = "ACC_BUTTON_SELECTOR_DONE".localized
            item.accessibilityHint = "ACC_HINT".localized
            toolBar!.items = [item]
            UIAccessibility.post(notification: .screenChanged, argument: title)
            delegate?.containerView.addSubview(toolBar!)

        }
    }

    @objc func onDoneButtonTapped() {
        toolBar!.removeFromSuperview()
        picker.removeFromSuperview()
        pickerOpened = false
        delegate?.onDone()
    }
}
