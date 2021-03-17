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
                    hiddenImageView.image = hiddenImage
                } else {
                    hiddenImageView.image = notHiddenImage
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
        if let checkIn = venue.checkInDate, let checkOut = venue.checkOutDate {
            let minutesBetween = String(format: "%.0f", checkOut.timeIntervalSince(checkIn) / secondsAnHour)
            return df.string(from: checkIn) + " (\(minutesBetween)h)"
        }
        return "00:00 (--)"
    }

}

protocol VenueHideDelegate: class {
    func hide(venue: VenueRecord)
}
