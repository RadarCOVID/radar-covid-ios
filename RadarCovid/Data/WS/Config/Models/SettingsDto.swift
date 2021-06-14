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


/** Application settings */

public struct SettingsDto: Codable {

    /** Response date */
    public var responseDate: Int64?
    public var exposureConfiguration: ExposureConfigurationDto?
    /** Minimum risk score */
    public var minRiskScore: Int64?
    /** Mininum duration for exposure */
    public var minDurationForExposure: Int64?
    /** Risk score classification */
    public var riskScoreClassification: [RiskScoreClassificationDto]?
    public var attenuationDurationThresholds: AttenuationDurationThresholdsDto?
    public var attenuationFactor: AttenuationFactorDto?
    public var applicationVersion: ApplicationVersionDto?
    public var timeBetweenStates: TimeBetweenStatesDto?
    /** Legal terms version identifier */
    public var legalTermsVersion: String?
    /** Radar COVID download link */
    public var radarCovidDownloadUrl: String?
    /** Notification reminder interval */
    public var notificationReminder: Int64?
    /** Time to elapse between KPI submission */
    public var timeBetweenKpi: Int64?
    public var venueConfiguration: VenueConfigurationDto?

    public init(responseDate: Int64? = nil, exposureConfiguration: ExposureConfigurationDto? = nil, minRiskScore: Int64? = nil, minDurationForExposure: Int64? = nil, riskScoreClassification: [RiskScoreClassificationDto]? = nil, attenuationDurationThresholds: AttenuationDurationThresholdsDto? = nil, attenuationFactor: AttenuationFactorDto? = nil, applicationVersion: ApplicationVersionDto? = nil, timeBetweenStates: TimeBetweenStatesDto? = nil, legalTermsVersion: String? = nil, radarCovidDownloadUrl: String? = nil, notificationReminder: Int64? = nil, timeBetweenKpi: Int64? = nil, venueConfiguration: VenueConfigurationDto? = nil) {
        self.responseDate = responseDate
        self.exposureConfiguration = exposureConfiguration
        self.minRiskScore = minRiskScore
        self.minDurationForExposure = minDurationForExposure
        self.riskScoreClassification = riskScoreClassification
        self.attenuationDurationThresholds = attenuationDurationThresholds
        self.attenuationFactor = attenuationFactor
        self.applicationVersion = applicationVersion
        self.timeBetweenStates = timeBetweenStates
        self.legalTermsVersion = legalTermsVersion
        self.radarCovidDownloadUrl = radarCovidDownloadUrl
        self.notificationReminder = notificationReminder
        self.timeBetweenKpi = timeBetweenKpi
        self.venueConfiguration = venueConfiguration
    }


}
