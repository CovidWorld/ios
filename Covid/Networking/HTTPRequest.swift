import Foundation

protocol NetworkSession {
    @discardableResult
    func loadData(for urlRequest: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

/// Handy extension - URLSession is usually used as NetworkSession.
extension URLSession: NetworkSession {
    @discardableResult
    func loadData(for urlRequest: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: urlRequest, completionHandler: completion)
        task.resume()
        return task
    }
}

/// Class used to perform HTTP requests.
class HTTPRequest {
    
    /// Error returned from HTTP request
    enum Error: Swift.Error {
        /// Indicate url error with underlying URLError
        case urlError(URLError?)
        /// Indicate http status code error
        case httpError(Int)
        /// Indicate no response
        case noResponse
        // TODO: pridat mozno nejake specifickejsie errors podla NSURLErrorDomain
    }
    
    /// Response returned from HTTP request
    enum Response {
        case success(Data?)
        case failure(Error)
    }
    
    /// HTTP method
    enum Method: String {
        case GET, POST, PUT, PATCH, DELETE
    }
    
    /// MIME type used for headers like `Content-Type` or `Accept`.
    enum MIMEType: String {
        case json = "application/json"
        case wwwForm = "application/x-www-form-urlencoded"
    }
    
    /**
     Starts a HTTP request.
     
     - parameter urlRequest: URLRequest to perform.
     - parameter networkSession: NetworkSession from which starts a request.
     - parameter completion: contains HTTPResponse which is either `Data?` or `HTTPError`
     */
    @discardableResult
    class func start(with urlRequest: URLRequest, networkSession: NetworkSession, completion: @escaping (Response) -> Void) -> URLSessionDataTask {
        return networkSession.loadData(for: urlRequest) { (data, urlResponse, error) in
            if let error = error {
                // TODO: mozno spracovat error a vratit rozne stavy podla NSURLErrorDomain
                completion(.failure(.urlError(error as? URLError)))
                return
            }
            
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                print("---- NO HTTPURLResponse")
                completion(.failure(.noResponse))
                return
            }
            
            switch urlResponse.statusCode {
            case 200...299:
                completion(.success(data))
            default:
                print("---- UNHANDLED STATUS CODE: \(urlResponse.statusCode)")
                completion(.failure(.httpError(urlResponse.statusCode)))
            }
        }
    }
}
