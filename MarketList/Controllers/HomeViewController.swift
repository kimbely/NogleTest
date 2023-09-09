//
//  HomeViewController.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private var viewModel: HomeViewModel!
    private var pageViewController: UIPageViewController!
    private var viewControllers: [UIViewController] = []
    
    private let disposeBag = DisposeBag()

    @IBOutlet weak var spotButton: UIButton!
    @IBOutlet weak var futuresButton: UIButton!
    @IBOutlet weak var pageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HomeViewModel.init()
        bindViewModel()
        viewModel.fetchData()
        setupPageViewController()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketManager.shared.disconnect()
    }
    
    private func bindViewModel() {
        viewModel.combinedData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let futuresData, let marketResponse):
                    
                    var spotMarkets = marketResponse.data.filter { !$0.future }
                    var futuresMarkets = marketResponse.data.filter { $0.future }
                    
                    for (index, market) in futuresMarkets.enumerated() {
                        if let updatedData = futuresData.data["\(market.symbol)_1"] {
                            futuresMarkets[index].price = updatedData.price
                        }
                    }
                    for (index, market) in spotMarkets.enumerated() {
                        if let updatedData = futuresData.data["\(market.symbol)_1"] {
                            spotMarkets[index].price = updatedData.price
                        }
                    }
                    
                    if let spotVC = self?.viewControllers[0] as? SpotViewController {
                        spotVC.viewModel.refresh(with: spotMarkets)
                    }
                    
                    if let futuresVC = self?.viewControllers[1] as? FuturesViewController {
                        futuresVC.viewModel.refresh(with: futuresMarkets)
                    }
                                    
                    break
                case .failure(_):
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        let spotVC = SubviewFactory.viewController(for: .spot, combinedData: viewModel.combinedData)
        let futuresVC = SubviewFactory.viewController(for: .futures, combinedData: viewModel.combinedData)
        
        viewControllers = [spotVC, futuresVC]
        
        pageViewController.setViewControllers([spotVC], direction: .forward, animated: true, completion: nil)
        changeBtn(index: 0)
        pageViewController?.willMove(toParent: nil)
        pageViewController?.removeFromParent()
        pageViewController?.view.removeFromSuperview()
        addChild(pageViewController)
        pageView.addSubviewWithConstraintToSuperView(pageViewController!.view)
        pageViewController.didMove(toParent: self)
    }
    
    @IBAction func spotButtonTapped(_ sender: UIButton) {
        let spotVC = viewControllers[0]
        pageViewController.setViewControllers([spotVC], direction: .reverse, animated: true, completion: nil)
        changeBtn(index: 0)
    }
    
    @IBAction func futuresButtonTapped(_ sender: UIButton) {
        let futuresVC = viewControllers[1]
        pageViewController.setViewControllers([futuresVC], direction: .forward, animated: true, completion: nil)
        changeBtn(index: 1)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = index - 1
        guard previousIndex >= 0 && previousIndex < viewControllers.count else {
            return nil
        }
        changeBtn(index: previousIndex)
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = index + 1
        guard previousIndex >= 0 && previousIndex < viewControllers.count else {
            return nil
        }
        changeBtn(index: previousIndex)
        return viewControllers[previousIndex]
    }
    
    func changeBtn(index: Int){
        futuresButton.setTitleColor(index == 1 ? .red : .black, for: .normal)
        spotButton.setTitleColor(index == 0 ? .red : .black, for: .normal)
    }
}
