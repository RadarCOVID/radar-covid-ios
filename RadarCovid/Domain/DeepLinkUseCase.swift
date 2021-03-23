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

class DeepLinkUseCase {
    
    private let expositionInfoRepository: ExpositionInfoRepository
    private let router: AppRouter
    private let qrBase: String
    
    init (expositionInfoRepository: ExpositionInfoRepository,
          router: AppRouter,
          qrBase: String) {
        self.expositionInfoRepository = expositionInfoRepository
        self.router = router
        self.qrBase = qrBase
    }
    
    func routeTo(url: URL, from: UIViewController ) {

        router.route(to: .root, from: from, parameters: routes(for: url))

    }
    
    private func routes(for url: URL) -> RouteStack? {
        
        let urlString = url.absoluteString
        
        if urlString.hasPrefix("radarcovid://report") &&
            expositionInfoRepository.getExpositionInfo()?.level != .infected {
            return reportUrlStack(url: url)
        }
        
        if urlString.hasPrefix(qrBase) {
            return qrUrlStack(url: url)
        }
        
        return nil
    }

    private func qrUrlStack(url: URL) -> RouteStack {
        return RouteStack(routes: [.home, .qrScanner, .qrResult], params: [nil,nil, url.absoluteString])
    }
    
    private func reportUrlStack(url: URL) -> RouteStack {
        

        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let param = urlComponents?.queryItems?.filter({ $0.name == "code" }).first
        
        return RouteStack(routes:  [.home,.myHealthStep0,.myHealthStep1], params: [nil, nil, param])
    }
    

}


