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

class ShareAppViewModel {
    
    let shareUseCase: ShareUseCase!
    
    init(shareUseCase: ShareUseCase) {
        self.shareUseCase = shareUseCase
    }
    
    func getUrl() -> String {
        return shareUseCase.getUrl()
    }
    
    func getTitle() -> String {
        return shareUseCase.getTitle()
    }
    
    func getBody() -> String {
        return shareUseCase.getBody()
    }
}
