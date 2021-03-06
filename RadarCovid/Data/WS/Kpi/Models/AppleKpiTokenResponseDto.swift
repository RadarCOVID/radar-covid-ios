//
// AppleKpiTokenResponseDto.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct AppleKpiTokenResponseDto: Codable {

    /** Token JWT to be used by application once device token has been validated */
    public var token: String

    public init(token: String) {
        self.token = token
    }


}
