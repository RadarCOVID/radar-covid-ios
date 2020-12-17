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
    
    static func getScreenFor(url: URL, window: UIWindow?, router: Router?) {
        let component = url.absoluteString.components(separatedBy: "?")
        
        if component.count > 1 {
            let urlSchemeRedirect = DeepLinkUseCase.urlSchemeToSection(urlScheme: component.first ?? "")
            var params: [Any?] = []
            
            if let lastRouteId = urlSchemeRedirect.last,
               let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = urlComponents.queryItems {

                params = DeepLinkUseCase.paramsUrlSchemeToSectionParameters(route: lastRouteId, params: queryItems)
            }
            router?.route(to: .root, from: (window?.rootViewController)!, parameters: urlSchemeRedirect, params)
        } else {
            router?.route(to: .root, from: (window?.rootViewController)!, parameters: nil)
        }
    }
    
    static func urlSchemeToSection(urlScheme: String) -> [Routes] {
        if urlScheme == "radarcovid://report" {
            return [.home,.myHealthStep0,.myHealthStep1]
        }
        return [.root]
    }
    
    static func paramsUrlSchemeToSectionParameters(route: Routes, params: [URLQueryItem]) -> [Any?] {
        switch route {
        case .myHealthStep1:
            let code = params.filter({ $0.name == "code" }).first?.value
            return [code]
            
        default:
            return []
        }
    }

}
