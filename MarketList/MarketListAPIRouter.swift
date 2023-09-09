//
//  MarketListAPIRouter.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import Foundation
import Alamofire

enum MarketListAPIRouter: APIRouter_JsonEncoding, CustomStringConvertible {
    var method: HTTPMethod {
        return .get
    }
    case market

    var controllerName: String {
        switch self {
            case .market:
                return "inquire"
        }
    }
    
    var path: String {
        switch self {
        case .market:
            return "initial/market"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .market:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .market:
            return "Fetch market"
        }
    }
}
