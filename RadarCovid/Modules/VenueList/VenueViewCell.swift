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

class VenueViewCell: UICollectionViewCell {
    
    private let secondsAnHour = 60.0 * 60.0
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hiddenImageView: UIImageView!
    
    private let bgImage = UIImage(named: "WhiteCard")
    private let notHiddenImage = UIImage(named: "Archive")
    private let hiddenImage = UIImage(named: "Archived")
    
    weak var venueHideDelegate: VenueHideDelegate?
    
    var venue: VenueRecord? {
        didSet {
            if let venue = venue {
                nameLabel.text = venue.name
                timeLabel.text = getTimeText(venue)
                if venue.hidden {
                    hideVenue()
                } else {
                    showVenue()
                }
            } else {
                nameLabel.text = "--"
                timeLabel.text = "00:00(--)"
                hiddenImageView.image = notHiddenImage
            }
            
        }
    }
    
    @IBOutlet weak var bgView: BackgroundView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.image = bgImage
        hiddenImageView.isUserInteractionEnabled = true
        hiddenImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                             action: #selector(userDidTapHide(tapGestureRecognizer:))))
        setupAccesibility()
    }
    
    private func hideVenue() {
        hiddenImageView.accessibilityLabel = "ACC_VENUE_HIDDEN".localized
        hiddenImageView.accessibilityHint = "ACC_VENUE_HIDDEN_HINT".localized
        hiddenImageView.image = hiddenImage
    }
    
    private func showVenue() {
        hiddenImageView.accessibilityLabel = "ACC_VENUE_SHOWN".localized
        hiddenImageView.accessibilityHint = "ACC_VENUE_SHOWN_HINT".localized
        hiddenImageView.image = notHiddenImage
    }
    
    private func setupAccesibility() {
        hiddenImageView.isAccessibilityElement = true
        hiddenImageView.accessibilityTraits.insert(.button)
        hiddenImageView.accessibilityTraits.remove(.image)
    }
    
    @objc func userDidTapHide(tapGestureRecognizer: UITapGestureRecognizer) {
        if let venue = venue {
            venueHideDelegate?.hide(venue: venue)
        }
    }
    
    private func getTimeText(_ venue: VenueRecord) -> String {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        if  let checkOut = venue.checkOutDate {
            let secondsBetween = checkOut.timeIntervalSince(venue.checkInDate)
            var timeString: String = venue.isPlusSelected ? "+" : ""
            if secondsBetween < secondsAnHour {
                timeString +=  String(format: "%.0f", secondsBetween / 60) + "'"
            } else {
                timeString +=  String(format: "%.0f", secondsBetween / secondsAnHour) + "h"
            }
            return df.string(from: venue.checkInDate) + " (\(timeString))"
        }
        return "00:00 (--)"
    }

}

protocol VenueHideDelegate: class {
    func hide(venue: VenueRecord)
}
