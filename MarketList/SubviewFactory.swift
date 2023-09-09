//
//  SubviewFactory.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import UIKit
import RxSwift

enum MarketType {
    case spot
    case futures
}

struct SubviewFactory {
    static func viewController(for type: MarketType, combinedData: BehaviorSubject<CombinedDataResult>) -> UIViewController {
        switch type {
        case .spot:
            // 返回Spot的视图控制器
            let spotVC: SpotViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpotViewControllerID") as! SpotViewController
            let viewModel = SpotViewModel.init(combinedData: combinedData)
            spotVC.viewModel = viewModel
            return spotVC
        case .futures:
            // 返回Futures的视图控制器
            let futuresVC: FuturesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FuturesViewControllerID") as! FuturesViewController
            let viewModel = FuturesViewModel.init(combinedData: combinedData)
            futuresVC.viewModel = viewModel
            return futuresVC
        }
    }
}
