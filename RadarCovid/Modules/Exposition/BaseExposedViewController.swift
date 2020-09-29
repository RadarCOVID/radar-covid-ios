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

protocol ExpositionView {
    func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer)
}

class BaseExposed: UIViewController, ExpositionView {

    //MARK: - Outlet.
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var expositionBGView: BackgroundView!

    // MARK: - Properties
    var lastCheck: Date?
    var router: AppRouter?

    //MARK: - View Life Cycle Methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBaseView()
        setupBaseAccessibility()
    }

    //MARK: - Action methods.
    
    @IBAction func onBack(_ sender: Any) {
        router?.pop(from: self, animated: true)
    }

    @objc func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        //Nothing to do here
    }
}

//MARK: - Accesibility.
extension BaseExposed {
    
    func setupBaseAccessibility() {
        
        backButton.isAccessibilityElement = true
        let previous = navigationController?.previousViewController
        if let title = (previous as? AccTitleView)?.accTitle ?? previous?.title {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK_TO".localized + " " + title
        } else {
            backButton.accessibilityLabel = "ACC_BUTTON_BACK".localized
        }
    }
}

//MARK: - Private.
private extension BaseExposed {
    
    func setupBaseView() {
        moreInfoView.isUserInteractionEnabled = true
        moreInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                           action: #selector(userDidTapLabel(tapGestureRecognizer:))))
    }
}
