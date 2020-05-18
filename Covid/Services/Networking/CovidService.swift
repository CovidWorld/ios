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

final class CovidService: NetworkService<CovidEndpoint> {
    func registerUserProfile(profileRequestData: RegisterProfileRequestData, completion: @escaping (Result<RegisterProfileResponseData, Error>) -> Void) {
        request(.profileRegister(profileRequestData: profileRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                do {
                    let response = try JSONDecoder().decode(RegisterProfileResponseData.self, from: data)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }

    func updateUserProfileNonce(profileRequestData: ProfileNonceRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.profileUpdateNonce(profileRequestData: profileRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                // TODO: do we get some data here?
                completion(.success(data))
//                do {
//                    let response = try JSONDecoder().decode(RegisterProfileResponseData.self, from: data)
//                    completion(.success(response))
//                } catch let error {
//                    completion(.failure(error))
//                }
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }

    func requestNoncePush(nonceRequestData: BasicRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.noncePush(nonceRequestData: nonceRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }

    // TODO: nonce response
    func requestNonce(nonceRequestData: BasicRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.nonce(nonceRequestData: nonceRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }

    func requestQuarantine(quarantineRequestData: BasicRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.quarantine(quarantineRequestData: quarantineRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }
//
//    func requestQuarantineStatus(quarantineRequestData: BasicRequestData, completion: @escaping (Result<QuarantineStatusResponseData, Error>) -> Void) {
////        request(.quarantineStatus(quarantineRequestData: quarantineRequestData)) { (response) in
////            switch response {
////            case .success(let data, _):
////                do {
////                    let dateFormatter = DateFormatter()
////                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
////                    let decoder = JSONDecoder()
////                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
////
////                    let response = try decoder.decode(QuarantineStatusResponseData.self, from: data)
////                    completion(.success(response))
////                } catch let error {
////                    completion(.failure(error))
////                }
////            case .failure( let error, _):
////                completion(.failure(error))
////            }
////        }
//    }

    func requestAreaExit(areaExitRequestData: AreaExitRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.areaExit(areaExitRequestData: areaExitRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error, _):
                completion(.failure(error))
            }
        }
    }
}

enum CovidEndpoint: NetworkServiceEndpoint {

    case profileRegister(profileRequestData: RegisterProfileRequestData)
    case profileUpdateNonce(profileRequestData: ProfileNonceRequestData)
    case noncePush(nonceRequestData: BasicRequestData)
    case nonce(nonceRequestData: BasicRequestData)
    case quarantine(quarantineRequestData: BasicRequestData)
    case areaExit(areaExitRequestData: AreaExitRequestData)

    static var serverDomain: String = "https://corona-quarantine.azurewebsites.net" //{ Firebase.remoteStringValue(for: .apiHost) }()
    var serverScript: String { "/api" }
    var contentTypeHeader: HTTPRequest.MIMEType { .json }
    var method: HTTPRequest.Method {
        switch self {
        case .profileUpdateNonce:
            return .PUT
        case .profileRegister, .noncePush, .nonce, .areaExit:
            return .POST
        case .quarantine:
            return .GET
        }
    }

    var headers: [String: String] {
        [
            "Content-Type": contentTypeHeader.rawValue,
            "User-Agent": "\(XCConfig.appName)(\(XCConfig.bundleIdentifier))/\(XCConfig.versionWithBuildNumber)(ios)"
        ]
    }

    var path: String {
        switch self {
        case .profileRegister, .profileUpdateNonce:
            return "profile"
        case .noncePush:
            return "pushnonce"
        case .nonce:
            return "nonce"
        case .quarantine:
            return "quarantine"
        case .areaExit:
            return "areaexit"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .profileRegister(let profileRequestData):
            return profileRequestData.dictionary
        case .profileUpdateNonce(let profileRequestData):
            return profileRequestData.dictionary
        case .noncePush(let nonceRequestData):
            return nonceRequestData.dictionary
        case .nonce(let nonceRequestData):
            return nonceRequestData.dictionary
        case .quarantine(let quarantineRequestData):
            return quarantineRequestData.dictionary
        case .areaExit(let areaExitRequestData):
            return areaExitRequestData.dictionary
        }
    }
}
