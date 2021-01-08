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

class ShareAppViewController: BaseViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var description1Label: UILabel!
    @IBOutlet weak var description2Label: UILabel!
    @IBOutlet weak var description3Label: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var router: AppRouter?
    var viewModel: ShareAppViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAccessibility()
    }
    
    private func setupView() {
        shareButton.setTitle("ACC_SHARE_BUTTON".localized, for: .normal)
        shareButton.titleLabel?.lineBreakMode = .byWordWrapping
        cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        
        description1Label.setLineSpacing()
        description2Label.setLineSpacing()
        description3Label.setLineSpacing()
    }
    
    private func setupAccessibility() {
        closeButton.accessibilityLabel = "ACC_BUTTON_CLOSE".localized
        closeButton.accessibilityHint = "ACC_HINT".localized
        closeButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        shareButton.accessibilityLabel = "ACC_SHARE_BUTTON".localized
        shareButton.accessibilityHint = "ACC_HINT".localized
        shareButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
        
        cancelButton.accessibilityLabel = "ALERT_CANCEL_BUTTON".localized
        cancelButton.accessibilityHint = "ACC_HINT".localized
        cancelButton.accessibilityTraits.remove(UIAccessibilityTraits.selected)
    }
    
    @IBAction func onCloseAction(_ sender: Any) {
        router?.dissmiss(view: self, animated: true)
    }
    
    @IBAction func onShareButton(_ sender: Any) {
        
        let urlShare = URL(string: viewModel?.getUrl() ?? "")!
        let titleShare = viewModel?.getTitle() ?? ""
        let bodyShare = viewModel?.getBody() ?? ""
        
        self.shareButton.isUserInteractionEnabled = false
       
        if #available(iOS 13.0, *) {
            let shareAppController = ShareAppController()
            shareAppController.delegateOutput = self
            shareAppController.shareApp(urlShare: urlShare, titleShare: titleShare, bodyShare: bodyShare)
        } else {
            let shareAppController = ShareAppOldController()
            shareAppController.delegateOutput = self
            shareAppController.shareApp(urlShare: urlShare, titleShare: titleShare, bodyShare: bodyShare)
        }
    }
}

extension ShareAppViewController: ShareAppControllerOutput {
    func finishFetchingMetadata() {
        self.shareButton.isUserInteractionEnabled = true
    }
    
    func finishShared() {
        self.router?.dissmiss(view: self, animated: true)
    }

}
