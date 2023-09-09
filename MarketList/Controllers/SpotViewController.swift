//
//  SpotViewController.swift
//  NogleTest
//
//  Created by 金梅劉 on 2023/9/9.
//

import UIKit
import RxSwift

class SpotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    var viewModel: SpotViewModel!
    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func bindViewModel() {
        viewModel.spotMarketData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = try? viewModel.spotMarketData.value() else {
            return 0
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketCell", for: indexPath)
        if let data = try? viewModel.spotMarketData.value() {
            let market = data[indexPath.row]
            cell.textLabel?.text = market.symbol
            cell.detailTextLabel?.text = "\(market.price ?? 0.0)"
        }
        return cell
    }
    
}
