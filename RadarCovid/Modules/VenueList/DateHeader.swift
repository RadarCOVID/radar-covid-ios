//
//  DateHeader.swift
//  sentinel
//
//  Created by alopezh on 10/01/2020.
//  Copyright © 2020 alopezh. All rights reserved.
//

import UIKit

class DateHeader: UICollectionReusableView {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var date : String? {
        didSet {
            dateLabel.text = date
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
