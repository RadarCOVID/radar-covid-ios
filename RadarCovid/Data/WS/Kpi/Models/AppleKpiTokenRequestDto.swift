//
// AppleKpiTokenRequestDto.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** Token to be evaluated */

public struct AppleKpiTokenRequestDto: Codable {

    /** Device token to be authorized */
    public var deviceToken: String

    public init(deviceToken: String) {
        self.deviceToken = deviceToken
    }


}
