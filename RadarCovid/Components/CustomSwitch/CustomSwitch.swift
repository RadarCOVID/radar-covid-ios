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
protocol SwitchStateListener {
    func stateChanged(active: Bool, switcher: CustomSwitch)
}
class CustomSwitch: UIView, XibInstantiatable {
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var regularSwitch: UISwitch!
    @IBOutlet weak var container: UIView!
    @IBInspectable var swicherType: String?
    var isTermSwitcher: Bool {
        return swicherType == "terms"
    }
    var isPolicySwitcher: Bool {
        return swicherType == "policy"
    }
    
    var delegate: SwitchStateListener?
    var active = false
    var switchStateImage: UIImage? {
        return self.active ?
            UIImage(named: "CheckboxSelected")
            : UIImage(named: "CheckboxUnselected")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
        self.setupAccessibility()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
        self.setupAccessibility()
    }
    
    
    func updateViews(){
        if !UIAccessibility.isVoiceOverRunning {
            self.stateImage.image = self.switchStateImage
        }
    }
    
    func setupAccessibility(){
        container.isUserInteractionEnabled = true
        if UIAccessibility.isVoiceOverRunning {
            self.stateImage.isHidden = true
            self.regularSwitch.isHidden = false
           
        }else{
            container.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(toggleState))
            )
            self.stateImage.isHidden = false
            self.regularSwitch.isHidden = true
        }
    }
    
    @objc func toggleState(){
        self.active = !active
        delegate?.stateChanged(active: self.active, switcher: self)
        updateViews()
    }
    
    
    @IBAction func onSwithChange(_ sender: Any) {
        toggleState()
    }
    
}
