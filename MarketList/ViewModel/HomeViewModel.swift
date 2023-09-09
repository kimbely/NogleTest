//
//  DispatchIssueHomeViewModel.swift
//  THL APP
//
//  Created by 金梅劉 on 2020/6/10.
//  Copyright © 2020 金梅劉. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewModel {
    
    private let dataService: MarketRemoteDataService
    private let socketObservable: Observable<FuturesData>
    private let disposeBag = DisposeBag()
    private var marketObservable: Observable<GetMarketListResponse>
    var combinedData: BehaviorSubject<CombinedDataResult> = BehaviorSubject(value: .failure(NSError(domain: "", code: -1, userInfo: nil)))

    // 使用Dependency Injection
    init(dataService: MarketRemoteDataService = MarketRemoteDataService(),
         socketObservable: Observable<FuturesData> = SocketManager.shared.dataSubject) {
        SocketManager.shared.connect()
        self.dataService = dataService
        self.socketObservable = socketObservable
        self.marketObservable = dataService.getMarket()
    }
    
    func fetchData() {
        processFetchedItem()
    }
    
    private func processFetchedItem() {
        Observable.combineLatest(socketObservable, marketObservable)
            .subscribe(onNext: { [weak self] (futuresData, marketResponse) in
                let result = CombinedDataResult.success(futuresData: futuresData, marketResponse: marketResponse)
                self?.combinedData.onNext(result)
            }, onError: { [weak self] error in
                self?.combinedData.onNext(.failure(error))
            })
            .disposed(by: disposeBag)
    }
}
