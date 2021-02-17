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
import LinkPresentation

protocol ShareAppControllerOutput {
    func finishFetchingMetadata()
    func finishShared()
}

class ShareAppOldController: NSObject {
    
    var delegateOutput: ShareAppControllerOutput?
    
    func shareApp(urlShare: URL, titleShare: String, bodyShare: String) {
        
        DispatchQueue.main.async {
            self.delegateOutput?.finishFetchingMetadata()

            UIApplication.share([urlShare, bodyShare.localizedAttributed.string]) { activityViewController in
                
                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    if completed {
                        self.delegateOutput?.finishShared()
                    }
                }
            }
        }
    }
}

@available(iOS 13.0, *)
class ShareAppController: NSObject {
    
    var metadata: LPLinkMetadata?
    var title: String?
    var body: String?
    var delegateOutput: ShareAppControllerOutput?
    
    func shareApp(urlShare: URL, titleShare: String, bodyShare: String) {
        title = titleShare
        body = bodyShare
        
        LPMetadataProvider().startFetchingMetadata(for: urlShare) { [weak self] linkMetadata, _ in
            linkMetadata?.iconProvider = linkMetadata?.imageProvider
            self?.metadata = linkMetadata
            self?.metadata?.title = titleShare
            self?.metadata?.url = URL(string: "")
            self?.metadata?.originalURL = URL(string: "")
            
            DispatchQueue.main.async {
                self?.delegateOutput?.finishFetchingMetadata()

                UIApplication.share([self!]) { activityViewController in
                    
                    activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                        if completed {
                            self?.delegateOutput?.finishShared()
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 13.0, *)
extension ShareAppController: UIActivityItemSource {
    
    // The placeholder the share sheet will use while metadata loads
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return title ?? ""
    }
    
    // The metadata we want the system to represent as a rich link
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return self.metadata
    }
    
    // The item we want the user to act on.
    // In this case, it's the URL to the Wikipedia page
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let descriptionShare:String = body ?? ""
        
        return descriptionShare.localizedAttributed.string
    }
}
