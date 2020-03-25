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

import Foundation
import Reachability

typealias JSON = [String: Any]

// MARK: - NetworkServiceResponse

/// Response returned from Service
enum NetworkServiceResponse {
    /// Indicates successful response with optional JSON data returned from service and transmissionTime in seconds.
    case success(Data, TimeInterval)
    /// Indicates failed response with unbderlying `ServiceError`.
    case failure(NetworkServiceError)
}

// MARK: - NetworkServiceError

/// Represents error returned from Service.
enum NetworkServiceError: Error {
    /// Not connected to the internet
    case notConnected
    /// Requested object not found
    case notFound
    /// Invalid response
    case invalidResponse
    /// No data returned from server
    case noData
    /// Indicate HTTP request failed
    case badRequest
    /// Object parsing failed
    case parsingFailed
}

// MARK: - NetworkServiceEndpoint

/// Type representing service endpoint. Used to model service API endpoint.
protocol NetworkServiceEndpoint {
    static var serverDomain: String { get }
    var urlRequest: URLRequest { get }
    var fullURL: URL { get }
    var contentTypeHeader: HTTPRequest.MIMEType { get }
    var parameters: [String: Any] { get }
    var method: HTTPRequest.Method { get }
    var headers: [String: String] { get }
    var serverScript: String { get }
    var path: String { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

extension NetworkServiceEndpoint {
    
    var urlRequest: URLRequest {
        var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false)
        if method == .GET && !parameters.isEmpty {
            components?.query = parameters.encodedQuery
        }
        
        guard let url = components?.url else { fatalError("Invalid URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.cachePolicy = cachePolicy
        
        let methodsWithHttpBody: [HTTPRequest.Method] = [.POST, .PUT, .PATCH]
        if methodsWithHttpBody.contains(method) {
            request.httpBody = httpBody
        }
        
        return request
    }
    
    public var fullURL: URL {
        guard var url = URL(string: Self.serverDomain) else { fatalError("Can't create base URL") }
        url.appendPathComponent(serverScript)
        url.appendPathComponent(path)
        
        return url
    }
    
    public var httpBody: Data? {
        switch contentTypeHeader {
        case .json:
            return try? JSONSerialization.data(withJSONObject: parameters)
        case .wwwForm:
            return parameters.encodedQuery.data(using: .utf8, allowLossyConversion: false)
        }
    }
    
    public var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
}

// MARK: - NetworkService

/// Class used for modeling network service. Uses Endpoint type for modeling service API endpoints.
class NetworkService<Endpoint: NetworkServiceEndpoint> {
    /// Requests an API call to web service. Response is passed in completion closure.
    var runningTasks = [URLSessionDataTask]()
    let reachability = try! Reachability()
    
    func request(_ endpoint: Endpoint, using request: HTTPRequest.Type = HTTPRequest.self, completion: @escaping (NetworkServiceResponse) -> Void) {
        guard reachability.connection != .unavailable else {
            completion(.failure(.notConnected))
            return
        }
        runningTasks.removeAll(where: { $0.state == .completed })
        let startDate = Date()
        let task = request.start(with: endpoint.urlRequest, networkSession: URLSession.shared) { [weak self] (response) in
            switch response {
            case .failure:
                completion(.failure(.badRequest))
            case .success(let data) where data == nil:
                completion(.failure(.noData))
            case .success(let data):
                let transmissionTime = Date().timeIntervalSince(startDate)
                let response = self?.response(from: data, transmissionTime: transmissionTime)
                completion(response!)
            }
        }
        runningTasks.append(task)
    }
    
    /// Process `Data` and returns `NetworkServiceResponse`.
    func response(from data: Data?, transmissionTime: TimeInterval) -> NetworkServiceResponse {
        guard let data = data else { return .failure(.noData) }        
        return .success(data, transmissionTime)
    }
    
    deinit {
        cancelRunningTasks()
    }
    
    private func cancelRunningTasks() {
        runningTasks.filter { $0.state == .running}.forEach { $0.cancel() }
    }
}


private extension Dictionary {
    
    /// Encodes parameters as query string.
    var encodedQuery: String {
        if count == 0 { return "" }
        
        var queryComponents = [String]()
        for (key, value) in self {
            let keyValuePair = "\(key)=\(value)"
            queryComponents.append(keyValuePair)
        }
        
        return queryComponents.joined(separator: "&")
    }
}

struct JSONEnc {
    static let encoder = JSONEncoder()
}

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEnc.encoder.encode(self))) as? [String: Any] ?? [:]
    }
}
