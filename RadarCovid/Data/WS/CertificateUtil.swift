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
struct CertificateUtil {

    static func certificate(filename: String) -> SecCertificate {
        let filePath = Bundle.main.path(forResource: filename, ofType: "cer")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data as CFData)!
        return certificate
    }
    
    static func publicKey(filename: String) throws -> SecKey {
        let cert = certificate(filename: filename)
        var trust: SecTrust?

        let policy = SecPolicyCreateBasicX509()
        let status = SecTrustCreateWithCertificates(cert, policy, &trust)

        if status == errSecSuccess {
            return SecTrustCopyPublicKey(trust!)!
        } else {
            throw CertError.error("Failed to get public key from cert: \(filename)")
        }
    }
}

enum CertError: Error {
    case error(String)
}
