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

class SelectorTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var itemModel: SelectorItem?
    
    func setupModel(itemModel: SelectorItem, totalItems: Int, indexItem: Int) {
        titleLabel.text = itemModel.description
        titleLabel.accessibilityLabel = "\(itemModel.description) " + "MY_HEALTH_RANGER".localized
        titleLabel.accessibilityLabel = titleLabel.accessibilityLabel?.replacingOccurrences(of: "$1", with: "\(indexItem + 1)")
        titleLabel.accessibilityLabel = titleLabel.accessibilityLabel?.replacingOccurrences(of: "$2", with: "\(totalItems)")
        self.itemModel = itemModel
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
                self.backgroundColor = UIColor.deepLilac
            } else {
                self.backgroundColor = UIColor.clear
            }
        }
        
        if selected {
            titleLabel.font = UIFont.mainFont(size: .twentytwo, fontType: .bold)
            titleLabel.textColor = UIColor.black
        } else {
            titleLabel.font = UIFont.mainFont(size: .twenty, fontType: .regular)
            titleLabel.textColor = UIColor.twilight
        }
    }
    
}
