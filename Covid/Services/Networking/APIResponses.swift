/*-
* Copyright (c) 2020 Sygic
*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
 * The above copyright notice and this permission notice shall be included in
* copies or substantial portions of the Software.
*
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*/

//
//  APIResponses.swift
//  Covid
//
//  Created by Boris Kolozsi on 12/03/2020.
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

// MARK: - NCZI Services -
struct OTPResponseData: Codable {
    let errors: [OTPResponseError]?
    let payload: OTPResponsePayload?
}

struct OTPResponseErrorData: Codable {
    let errors: [OTPResponseError]
}

struct OTPResponseSuccessData: Codable {
    let payload: OTPResponsePayload
}

struct OTPResponsePayload: Codable {
    let vAccessToken: String
}

struct OTPResponseError: Codable {
    let title: String
    let description: String
}
