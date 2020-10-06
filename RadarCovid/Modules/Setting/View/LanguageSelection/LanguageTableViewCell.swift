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

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var keyModel: String = ""
    
    func setupModel(title: String, key: String) {
        titleLabel.text = title
        keyModel = key
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isAccessibilityElement = true
        self.accessibilityHint = "ACC_HINT".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        logicToSelected(selected)
    }
    
    private func logicToSelected(_ selected: Bool) {
        if UIAccessibility.isVoiceOverRunning {
            if selected {
                titleLabel.font = UIFont.mainFont(size: .twentytwo, fontType: .bold)
                titleLabel.textColor = UIColor.white
                self.backgroundColor = UIColor.gray
            } else {
                titleLabel.font = UIFont.mainFont(size: .twenty, fontType: .regular)
                titleLabel.textColor = UIColor.black
                self.backgroundColor = UIColor.white
            }
        } else {
            if selected {
                titleLabel.font = UIFont.mainFont(size: .twentytwo, fontType: .bold)
                titleLabel.textColor = UIColor.black
            } else {
                titleLabel.font = UIFont.mainFont(size: .twenty, fontType: .regular)
                titleLabel.textColor = UIColor.purpleApp
            }
        }
    }
    
}
