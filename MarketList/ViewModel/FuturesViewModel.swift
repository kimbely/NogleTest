//
//  FuturesViewModel.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import Foundation
import RxSwift

class FuturesViewModel {
    
    let marketData: BehaviorSubject<[Datum]> = BehaviorSubject(value: [])
    private let disposeBag = DisposeBag()
    
    init(combinedData: BehaviorSubject<CombinedDataResult>) {
        combinedData
            .map { result -> [Datum] in
                switch result {
                case .success(let futuresData, let marketResponse):
                    var futuresMarkets = marketResponse.data.filter { $0.future }
                    
                    for (index, market) in futuresMarkets.enumerated() {
                        if let updatedData = futuresData.data["\(market.symbol)_1"] {
                            futuresMarkets[index].price = updatedData.price
                        }
                    }
                    futuresMarkets = futuresMarkets.sorted { $0.symbol < $1.symbol }
                    return futuresMarkets
                case .failure(_):
                    return []
                }
            }
            .subscribe(onNext: { [weak self] data in
                self?.marketData.onNext(data)
            }, onError: { error in
                // Handle any errors if necessary
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func refresh(with markets: [Datum]) {
        marketData.onNext(markets)
    }
}
