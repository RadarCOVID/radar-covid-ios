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
import Security

struct HTTPPinningCertificate {
    let certificate: SecCertificate
    let data: Data
}

extension HTTPPinningCertificate {
    static func localCertificates() -> [HTTPPinningCertificate] {
        return ["radarcovidpre.covid19.gob.es", "radarcovid.covid19.gob.es"].lazy.map({
            guard let file = Bundle.main.url(forResource: $0, withExtension: "cer"),
                let data = try? Data(contentsOf: file),
                let cert = SecCertificateCreateWithData(nil, data as CFData) else { return nil }

            return HTTPPinningCertificate(certificate: cert, data: data)
        }).compactMap { $0 }
    }

    func validate(against certData: Data, using secTrust: SecTrust) -> Bool {
        let certArray = [certificate] as CFArray
        SecTrustSetAnchorCertificates(secTrust, certArray)
        return SecTrustEvaluateWithError(secTrust, nil) && certData == data
    }
}
