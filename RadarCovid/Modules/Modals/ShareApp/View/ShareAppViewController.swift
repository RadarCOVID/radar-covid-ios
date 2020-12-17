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
import LinkPresentation

class ShareAppViewController: BaseViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var description1Label: UILabel!
    @IBOutlet weak var description2Label: UILabel!
    @IBOutlet weak var description3Label: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var router: AppRouter?
    var viewModel: ShareAppViewModel?
    
    var metadata: LPLinkMetadata?
    
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
        
        self.shareButton.isUserInteractionEnabled = false
        LPMetadataProvider().startFetchingMetadata(for: urlShare) { linkMetadata, _ in
            linkMetadata?.iconProvider = linkMetadata?.imageProvider
            self.metadata = linkMetadata
            self.metadata?.title = titleShare
            self.metadata?.url = URL(string: "")
            self.metadata?.originalURL = URL(string: "")
            
            DispatchQueue.main.async {
                self.shareButton.isUserInteractionEnabled = true
                UIApplication.share([self]) { activityViewController in
                    
                    activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                        if completed {
                            self.router?.dissmiss(view: self, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension ShareAppViewController: UIActivityItemSource {
    
    // The placeholder the share sheet will use while metadata loads
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return viewModel?.getTitle() ?? ""
    }
    
    // The metadata we want the system to represent as a rich link
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return self.metadata
    }
    
    // The item we want the user to act on.
    // In this case, it's the URL to the Wikipedia page
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let descriptionShare:String = viewModel?.getBody() ?? ""
        
        return descriptionShare.localizedAttributed.string
    }
}
