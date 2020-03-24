//
//  APIResponses.swift
//  Covid
//
//  Created by Boris Kolozsi on 12/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation

struct RegisterProfileResponseData: Codable {
    let profileId: Int
    let deviceId: String
}

struct QuarantineStatusResponseData: Codable {
    let isInQuarantine: Bool
    let quarantineBeginning: Date?
    let quarantineEnd: Date?
}

struct StatsResponseData: Codable {
    let totalCases: Double
    let totalDeaths: Double
    let totalRecovered: Double
}
