import Foundation

final class CovidService: NetworkService<CovidEndpoint> {
    func registerUserProfile(profileRequestData: RegisterProfileRequestData, completion: @escaping (Result<RegisterProfileResponseData, Error>) -> Void) {
        request(.profile(profileRequestData: profileRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                do {
                    let response = try JSONDecoder().decode(RegisterProfileResponseData.self, from: data)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadConnections(uploadConnectionsRequestData: UploadConnectionsRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.contacts(uploadConnectionsRequestData: uploadConnectionsRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))  
            }
        }
    }
    
    func requestMFAToken(mfaTokenRequestData: BasicRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.mfaToken(mfaTokenRequestData: mfaTokenRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestQuarantine(quarantineRequestData: QuarantineRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.quarantine(quarantineRequestData: quarantineRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func requestQuarantineStatus(quarantineRequestData: BasicRequestData, completion: @escaping (Result<QuarantineStatusResponseData, Error>) -> Void) {
        request(.quarantineStatus(quarantineRequestData: quarantineRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                do {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let response = try decoder.decode(QuarantineStatusResponseData.self, from: data)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestAreaExit(areaExitRequestData: AreaExitRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.areaExit(areaExitRequestData: areaExitRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestLocations(locationsRequestData: LocationsRequestData, completion: @escaping (Result<Data, Error>) -> Void) {
        request(.locations(locationsRequestData: locationsRequestData)) { (response) in
            switch response {
            case .success(let data, _):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum CovidEndpoint: NetworkServiceEndpoint {
    
    case profile(profileRequestData: RegisterProfileRequestData)
    case contacts(uploadConnectionsRequestData: UploadConnectionsRequestData)
    case mfaToken(mfaTokenRequestData: BasicRequestData)
    case quarantine(quarantineRequestData: QuarantineRequestData)
    case quarantineStatus(quarantineRequestData: BasicRequestData)
    case areaExit(areaExitRequestData: AreaExitRequestData)
    case locations(locationsRequestData: LocationsRequestData)
    
    static let serverDomain = "https://coronagateway.azurewebsites.net"
    var serverScript: String { return "/api" }
    var contentTypeHeader: HTTPRequest.MIMEType { return .json }
    var method: HTTPRequest.Method {
        switch self {
        case .profile:
            return .PUT
        case .contacts, .mfaToken, .quarantine, .areaExit, .locations:
            return .POST
        case .quarantineStatus:
            return .GET
        }
    }
    
    var headers: [String: String] {
        return [
            "Content-Type": contentTypeHeader.rawValue
        ]
    }
    
    var path: String {
        switch self {
        case .profile:
            return "profile"
        case .contacts:
            return "profile/contacts"
        case .mfaToken:
            return "profile/mfatoken"
        case .quarantineStatus, .quarantine:
            return "profile/quarantine"
        case .areaExit:
            return "profile/areaexit"
        case .locations:
            return "profile/location"
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .profile(let profileRequestData):
            return profileRequestData.dictionary
        case .contacts(let uploadConnectionsRequestData):
            return uploadConnectionsRequestData.dictionary
        case .mfaToken(let mfaTokenRequestData):
            return mfaTokenRequestData.dictionary
        case .quarantine(let quarantineRequestData):
            return quarantineRequestData.dictionary
        case .quarantineStatus(let quarantineRequestData):
            return quarantineRequestData.dictionary
        case .areaExit(let areaExitRequestData):
            return areaExitRequestData.dictionary
        case .locations(let locationsRequestData):
            return locationsRequestData.dictionary
        }
    }
}
