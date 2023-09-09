//
//  MarketDataModel.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import Foundation
import Alamofire

struct GetMarketListResponse: Codable,ApiResponse {
    var code: Int
    var message: String?
    let data: [Datum]
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "msg"
        case data = "data"
    }
}

// MARK: - Datum
struct Datum: Codable {
    let future: Bool
    let symbol: String
    var price: Double?
    enum CodingKeys: String, CodingKey {
        case future, symbol, price
    }
}

struct FuturesData: Codable {
    let topic: String
    let data: [String: FuturesDataDatum]
}

// MARK: - Datum
struct FuturesDataDatum: Codable {
    let id, name: String
    let type: Int
    let price: Double
    let gains, datumOpen, high: Double
    let low, volume: Double
    let amount: Int

    enum CodingKeys: String, CodingKey {
        case id, name, type, price, gains
        case datumOpen = "open"
        case high, low, volume, amount
    }
}
