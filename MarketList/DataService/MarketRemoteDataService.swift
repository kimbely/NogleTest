//
//  MarketRemoteDataService.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import Foundation
import Alamofire
import RxSwift

class MarketRemoteDataService: DataService {
    
    var dataResponseCompletion: DataResponseCompletion
    
    init(dataResponseCompletion: DataResponseCompletion = Communicator.shared) {
        self.dataResponseCompletion = dataResponseCompletion
    }
    
    func getMarket() -> Observable<GetMarketListResponse> {
        return Observable.create { observer in
            let convertableUrl = MarketListAPIRouter.market
            self.request(url: convertableUrl, returningClass: GetMarketListResponse.self) { (instance, err) in
                if let error = err {
                    let error: Error = NSError(domain: convertableUrl.urlRequest?.url?.absoluteString ?? "", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
                    observer.onError(error)
                } else if let instance = instance {
                    observer.onNext(instance)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "Unknown error", code: -1, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
}
