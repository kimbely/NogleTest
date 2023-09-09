//
//  APIRouter.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import Foundation
import Alamofire


protocol ApiResponse: CodeAndMessage, Decodable {}

protocol ApiRequestParameter {
    func parameters() -> Parameters
}

protocol APIRouter: URLRequestConvertible {
    var controllerName: String { get }
    var path: String { get }
    func currentAsURLRequest() throws -> URLRequest
}
protocol ApiDefaultParameter {
    func mergeDefaultParameters(_ parameters: Parameters?) -> Parameters
}

protocol APIRouter_JsonEncoding: APIRouter, ApiDefaultParameter {
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
}

protocol DataService {
    var dataResponseCompletion: DataResponseCompletion { get }
}
protocol DataResponseCompletion {
    func request(url: URLRequestConvertible, completion: @escaping (AFDataResponse<Data>) -> ())
}

extension APIRouter_JsonEncoding {
    
    public func asURLRequest() throws -> URLRequest {
        let request = try currentAsURLRequest()
        return request
    }
    
    func currentAsURLRequest() throws -> URLRequest {
        let baseURL = URL(string: "https://api.btse.com/futures/api/")!
        let fullURL = baseURL.appendingPathComponent(controllerName).appendingPathComponent(path)
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = method.rawValue
        let para = mergeDefaultParameters(parameters)
        
        // 根据 HTTP 方法来决定是否为请求添加请求体
        switch method {
        case .get:
            return try URLEncoding.default.encode(request, with: para)
        default:
            return try JSONEncoding.default.encode(request, with: para)
        }
    }
    
}
extension ApiDefaultParameter {
    
    func mergeDefaultParameters(_ parameters: Parameters?) -> Parameters {
        var updatedParameter: Parameters = [:]
        parameters?.forEach { (key, value) in
            updatedParameter[key] = value
        }
        return updatedParameter
    }
}

class Communicator : DataResponseCompletion {
    static let shared = Communicator()
    
    func request(url:URLRequestConvertible) -> DataRequest{
        return Session.default.request(url);
    }
    
    func request(url: URLRequestConvertible, completion: @escaping (AFDataResponse<Data>) -> Void) {
        request(url: url).responseData(completionHandler: completion)
    }
    
}
extension DataService {
    
    func request<T: ApiResponse>(url: (URLRequestConvertible & CustomStringConvertible), returningClass: T.Type, completion: @escaping(T?, _ err: String?) -> ()) {
        request(url: url) { response, err in
            if let data = response {
                do {
                    let cm = try JSONDecoder().decode(ResultCodeAndMessage.self, from: data)
                    if cm.code == 1 {
                        let instance = try JSONDecoder().decode(T.self, from: data)
                        completion(instance, nil)
                    } else {
                        completion(nil, cm.message)
                    }
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("keyNotFound", key, context)
                    completion(nil, "keyNotFound:\(key)")
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("typeMismatch", type, context)
                    completion(nil, "typeMismatch:\(type)")
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("valueNotFound", value, context)
                    completion(nil, "valueNotFound:\(value)")
                } catch DecodingError.dataCorrupted(let context) {
                    print("dataCorrupted", context)
                    completion(nil, "dataCorrupted")
                } catch let error {
                    completion(nil, error.localizedDescription)
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    /// 分出Networking Error
    private func request(url: (URLRequestConvertible & CustomStringConvertible), completion: @escaping(Data?, Error?) -> ()) {
        dataResponseCompletion.request(url: url) { response in
            print("\(response.response?.statusCode ?? 0) URL:  \(url.urlRequest?.url?.absoluteString ?? "Unknown URL")")
            switch response.result {
            case .success(let json):
                if let status = response.response?.statusCode {
                    switch status {
                    case 200 ... 299:
                        completion(json, nil)
                        return
                    default:
                        let error = NSError(domain: "Error Message is \(status)", code: status, userInfo: nil)
                        completion(nil,error)
                        return
                    }
                }
                
                
            case .failure(let error):
                var error = error as NSError
                switch error.code {
                case -1009 :
                    error = NSError.init(domain: "網路連線異常", code: -1009, userInfo: nil)
                    completion(nil, error)
                    return
                case -1004 :
                    error = NSError.init(domain: "伺服器連線異常", code: -1004, userInfo: nil)
                    completion(nil, error)
                    return
                default:
                    
                    print("Server respond error: \(error)")
                    completion(nil, error)
                    return
                }
            }
        }
    }
}
protocol CodeAndMessage {
    var code: Int { get set }
    var message: String? { get set }
}
struct ResultCodeAndMessage: CodeAndMessage, Codable {
    var code: Int
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "msg"
    }
}
enum CustomError: Error {
    case message(String)
}
enum CombinedDataResult {
    case success(futuresData: FuturesData, marketResponse: GetMarketListResponse)
    case failure(Error)
}
