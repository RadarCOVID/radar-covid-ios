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
import DP3TSDK

struct Config {

    static let platform = "iOS"
    static let version:String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") as! String
    
    #if DEBUG_PRE
    static let debug = true
    static let environment = "PRE"
    static let endpoints: Endpoints = .pre
    static let dp3tMode: ApplicationDescriptor.Mode = .test
    static let errorVerbose = true
    static let dp3tValidationKey = Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFdmx1bzYyTFVVcFllcVVGM3haWVhYSG03cjBGWApScENFbVBqTUlxUHVERjcvYmRua1FIbndxbVNoVzIvOU9BcllEd09FUUZmdEE4ZDV6T3NEZmh0T2NRPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
    static let verificationKey =  Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlHYk1CQUdCeXFHU000OUFnRUdCU3VCQkFBakE0R0dBQVFCbUlXU0ptdGVGNkh2VnI0M1V5SzliZStlNkpPQgpDRjlVaXpMeis4a3padkVEc25nMGl3VEF3UVB0QzdBMDlzQjVMM3EwSUl1N250Yzd4U1VqSUdTakZvd0JXL0xPCnFtMTBYQ1NkUWNZT3BMTi85dUI1emZKVUZOY3B6Ynk4dDAzSlg3TUZiYi9vQm1pcFNNNHptSm1UajR3Qm9XZ2sKRlF6ZEJHcnAwR2laUU9WVXRtUT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==")!
    #elseif DEBUG_PRO
    static let debug = true
    static let environment = "PRO"
    static let endpoints: Endpoints = .pro
    static let dp3tMode: ApplicationDescriptor.Mode = .test
    static let errorVerbose = true
    static let dp3tValidationKey = Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFdmx1bzYyTFVVcFllcVVGM3haWVhYSG03cjBGWApScENFbVBqTUlxUHVERjcvYmRua1FIbndxbVNoVzIvOU9BcllEd09FUUZmdEE4ZDV6T3NEZmh0T2NRPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
    static let verificationKey =  Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlHYk1CQUdCeXFHU000OUFnRUdCU3VCQkFBakE0R0dBQVFBWjM1ZzlhN1M2MjdXMVlpOEVsVmdNS012dkdUUAo5R0hiUHZHTzhLekNLQk84WTZOc0JSTHlJeWUwZmdxR0ZXM2Z5dHVxcnFSNi9wSllDUWFXN1IyUnY3OEF4OXJhCmlYbmRVSmVyVk9KSHJRaFgxbnMrTjZxaVUxT0I4a3dUaWVuaCtuZDVVbXZUN24vK3hod3djK1RYa1lnNDBxOVcKUTRiVjBMbHRWbGRUSUlTK1QxOD0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg====")!
    #elseif RELEASE_PRE
    static let debug = false
    static let environment = "PRE"
    static let endpoints: Endpoints = .pre
    static let dp3tMode: ApplicationDescriptor.Mode = .production
    static let errorVerbose = false
    static let dp3tValidationKey = Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFdmx1bzYyTFVVcFllcVVGM3haWVhYSG03cjBGWApScENFbVBqTUlxUHVERjcvYmRua1FIbndxbVNoVzIvOU9BcllEd09FUUZmdEE4ZDV6T3NEZmh0T2NRPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
    static let verificationKey =  Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlHYk1CQUdCeXFHU000OUFnRUdCU3VCQkFBakE0R0dBQVFCbUlXU0ptdGVGNkh2VnI0M1V5SzliZStlNkpPQgpDRjlVaXpMeis4a3padkVEc25nMGl3VEF3UVB0QzdBMDlzQjVMM3EwSUl1N250Yzd4U1VqSUdTakZvd0JXL0xPCnFtMTBYQ1NkUWNZT3BMTi85dUI1emZKVUZOY3B6Ynk4dDAzSlg3TUZiYi9vQm1pcFNNNHptSm1UajR3Qm9XZ2sKRlF6ZEJHcnAwR2laUU9WVXRtUT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==")!
    #elseif RELEASE_PRO
    static let debug = false
    static let environment = "PRO"
    static let endpoints: Endpoints = .pro
    static let dp3tMode: ApplicationDescriptor.Mode = .production
    static let errorVerbose = false
    static let dp3tValidationKey = Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFdmx1bzYyTFVVcFllcVVGM3haWVhYSG03cjBGWApScENFbVBqTUlxUHVERjcvYmRua1FIbndxbVNoVzIvOU9BcllEd09FUUZmdEE4ZDV6T3NEZmh0T2NRPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
    static let verificationKey =  Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlHYk1CQUdCeXFHU000OUFnRUdCU3VCQkFBakE0R0dBQVFBWjM1ZzlhN1M2MjdXMVlpOEVsVmdNS012dkdUUAo5R0hiUHZHTzhLekNLQk84WTZOc0JSTHlJeWUwZmdxR0ZXM2Z5dHVxcnFSNi9wSllDUWFXN1IyUnY3OEF4OXJhCmlYbmRVSmVyVk9KSHJRaFgxbnMrTjZxaVUxT0I4a3dUaWVuaCtuZDVVbXZUN24vK3hod3djK1RYa1lnNDBxOVcKUTRiVjBMbHRWbGRUSUlTK1QxOD0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg====")!
    #endif
}
