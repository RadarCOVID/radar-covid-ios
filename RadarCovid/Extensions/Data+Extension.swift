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

public extension Data {
  /// Generate a Data instance with a random amount of bytes
  ///
  ///  - parameter length: the amount of bytes to generate
  static func randomData(with length: Int) -> Data {
    var bytes = [Int8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    assert(status == errSecSuccess)

    return Data(bytes: &bytes, count: length)
  }
}

/// Slightly broader extension to allow it to apply also for `SHA256.Digest`
public extension Sequence where Element == UInt8 {
  /// The String representation, as hexadecimal digits, of this byte sequence.
  var hexString: String {
    return self
      .map { byte in String(format: "%02hhx", byte) }
      .joined()
  }
}
