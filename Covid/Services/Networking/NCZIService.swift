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

import UIKit

enum NCZIError: String, Error {
    case generalResponseError = "Some error occured"
}

final class NCZIService: NetworkService<NCZIEndpoint> {
    func requestOTPSend(data: OTPSendRequestData, completion: @escaping (Result<OTPResponseData, Error>) -> Void) {
        request(.sendOTP(data: data)) { (response) in
            switch response {
            case .success(let data, _):
                if let response = try? JSONDecoder().decode(OTPResponseSuccessData.self, from: data) {
                    let otpData = OTPResponseData(errors: nil, payload: response.payload)
                    completion(.success(otpData))

                    return
                }

                if let response = try? JSONDecoder().decode(OTPResponseErrorData.self, from: data) {
                    let otpData = OTPResponseData(errors: response.errors, payload: nil)
                    completion(.success(otpData))

                    return
                }
                completion(.failure(NCZIError.generalResponseError))
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }

    func requestOTPValidate(data: OTPValidateRequestData, completion: @escaping (Result<OTPResponseData, Error>) -> Void) {
        request(.validateOTP(data: data)) { (response) in
            switch response {
            case .success(let data, _):
                if let response = try? JSONDecoder().decode(OTPResponseSuccessData.self, from: data) {
                    let otpData = OTPResponseData(errors: nil, payload: response.payload)
                    completion(.success(otpData))

                    return
                }

                if let response = try? JSONDecoder().decode(OTPResponseErrorData.self, from: data) {
                    let otpData = OTPResponseData(errors: response.errors, payload: nil)
                    completion(.success(otpData))

                    return
                }
                completion(.failure(NCZIError.generalResponseError))
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }
}

enum NCZIEndpoint: NetworkServiceEndpoint {

    case sendOTP(data: OTPSendRequestData)
    case validateOTP(data: OTPValidateRequestData)

    static var serverDomain: String = { Firebase.remoteStringValue(for: .ncziApiHost) }()
    var serverScript: String { "/api/v1/sygic" }
    var contentTypeHeader: HTTPRequest.MIMEType { .json }
    var method: HTTPRequest.Method { .POST }

    var headers: [String: String] {
        [
            "Content-Type": contentTypeHeader.rawValue
        ]
    }

    var path: String {
        switch self {
        case .sendOTP: return "send-otp"
        case .validateOTP: return "validate-otp"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .sendOTP(let data):
            return data.dictionary
        case .validateOTP(let data):
            return data.dictionary
        }
    }
}
