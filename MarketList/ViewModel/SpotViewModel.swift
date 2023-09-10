//
//  SpotViewModel.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import Foundation
import RxSwift

class SpotViewModel {
    let spotMarketData: BehaviorSubject<[Datum]> = BehaviorSubject(value: [])
    
    private let disposeBag = DisposeBag()
    
    init(combinedData: BehaviorSubject<CombinedDataResult>) {
        combinedData
            .map { result -> [Datum] in
                switch result {
                case .success(let futuresData, let marketResponse):
                    var spotMarkets = marketResponse.data.filter { !$0.future }
                    
                    for (index, market) in spotMarkets.enumerated() {
                        if let updatedData = futuresData.data["\(market.symbol)_1"] {
                            spotMarkets[index].price = updatedData.price
                        }
                    }
                    spotMarkets = spotMarkets.sorted { $0.symbol < $1.symbol }
                    return spotMarkets
                case .failure(_):
                    return []
                }
            }
            .subscribe(onNext: { [weak self] data in
                self?.spotMarketData.onNext(data)
            }, onError: { error in
                // Handle any errors if necessary
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func refresh(with markets: [Datum]) {
        spotMarketData.onNext(markets)
    }
}
