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

open class Configuration {

	// This value is used to configure the date formatter that is used to serialize dates into JSON format. 
	// You must set it prior to encoding any dates, and it will only be read once. 
    public static var dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

}
