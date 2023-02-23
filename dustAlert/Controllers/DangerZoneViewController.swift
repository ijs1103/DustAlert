//
//  DangerZoneViewController.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/15.
//

import UIKit
import SnapKit

class DangerZoneViewController: UIViewController {

    let networkManager = NetworkManager.shared
    var fetchedDust: [DangerZoneDust] = []
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func handleRefresh() {
        fetchData()
    }
    
    private lazy var explainLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .right
        textLabel.text = Const.Label.dangerZoneExplainLabel
        textLabel.textColor = .yellow
        textLabel.font = UIFont.systemFont(ofSize: 13.0)
        return textLabel
    }()
    
    private let emptyLabelView = EmptyLabelView(text: Const.Label.dangerZoneEmptyLabel)
    
    private lazy var dustTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .clear
        tableview.showsVerticalScrollIndicator = false
        tableview.refreshControl = refreshControl
        // separator 설정
        tableview.separatorStyle = .singleLine
        tableview.separatorColor = .systemYellow
        
        return tableview
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5, width: 0, height: 0)
        activityIndicator.style = .large
        activityIndicator.color = .systemRed
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private func hideActivityIndicator() {
        activityIndicator.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        fetchData()
    }
    private func fetchData(){
        networkManager.fetchDangerZoneDust { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(result):
                self.hideActivityIndicator()
                self.refreshControl.endRefreshing()
                self.fetchedDust = result.response.body.items
                self.dustTableView.reloadData()
                self.updateEmptyLabel()
            case let .failure(error):
                debugPrint("fetch failed. error: \(error)")
            }
            
        }
    }
    private func initUI() {
        self.view.backgroundColor = .black
        [ activityIndicator, explainLabel, emptyLabelView, dustTableView ].forEach {
            view.addSubview($0)
        }
        emptyLabelView.isHidden = true
        initNavigation()
        initTableView()
        setConstraints()
    }
    private func initNavigation() {
        self.navigationItem.title = Const.Title.dangerZone
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func initTableView(){
        dustTableView.dataSource = self
        dustTableView.delegate = self
        dustTableView.register(UINib(nibName: Const.Id.dangerZoneDustCell, bundle: nil), forCellReuseIdentifier: Const.Id.dangerZoneDustCell)
    }
    private func setConstraints() {
        explainLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        emptyLabelView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        dustTableView.snp.makeConstraints {
            $0.top.equalTo(explainLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    private func updateEmptyLabel() {
        if (fetchedDust.count > 0) {
            emptyLabelView.isHidden = true
        } else {
            emptyLabelView.isHidden = false
        }
    }
}

extension DangerZoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedDust.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dangerZoneDustCell = dustTableView.dequeueReusableCell(withIdentifier: Const.Id.dangerZoneDustCell, for: indexPath) as! DangerZoneDustCell
        
        dangerZoneDustCell.dangerZoneDust = fetchedDust[indexPath.row]
        dangerZoneDustCell.selectionStyle = .none
        
        return dangerZoneDustCell
    }
}

extension DangerZoneViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
