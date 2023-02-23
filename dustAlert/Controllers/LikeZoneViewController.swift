//
//  LikeViewController.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/17.
//

import UIKit
import SnapKit

class LikeZoneViewController: UIViewController {
    
    let dbManager = DBManager.shared
    let dustMangager = DustManager.shared
    var likedDust: [Dust] = []
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func handleRefresh() {
        fetchData()
    }
    
    private lazy var dustTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .clear
        tableview.showsVerticalScrollIndicator = false
        tableview.refreshControl = refreshControl
        return tableview
    }()

    private let emptyLabelView = EmptyLabelView(text: Const.Label.likeZoneEmptyLabel)
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5, width: 0, height: 0)
        activityIndicator.style = .large
        activityIndicator.color = .systemRed
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        showActivityIndicator()
        fetchData()
    }

    private func initNavigation() {
        self.navigationItem.title = Const.Title.favorite
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func initTableView(){
        dustTableView.dataSource = self
        dustTableView.delegate = self
        dustTableView.register(UINib(nibName: Const.Id.dustCell, bundle: nil), forCellReuseIdentifier: Const.Id.dustCell)
    }
    private func setConstraints() {
        emptyLabelView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        dustTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }
    private func initUI() {
        [ emptyLabelView, dustTableView, activityIndicator ].forEach {
            view.addSubview($0)
        }
        emptyLabelView.isHidden = true
        initNavigation()
        initTableView()
        setConstraints()
    }
    private func fetchData() {
        dustMangager.fetchLikeDust() {
            self.likedDust = self.dustMangager.getLikeDust()
            self.hideActivityIndicator()
            self.refreshControl.endRefreshing()
            self.dustTableView.reloadData()
            self.updateEmptyLabel()
        }
    }
    private func updateEmptyLabel() {
        if (likedDust.count > 0) {
            emptyLabelView.isHidden = true
        } else {
            emptyLabelView.isHidden = false
        }
    }
}

extension LikeZoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedDust.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dustCell = dustTableView.dequeueReusableCell(withIdentifier: Const.Id.dustCell, for: indexPath) as! DustCell
        dustCell.selectionStyle = .none
        let dust = likedDust[indexPath.row]
        dust.isLiked = true
        dustCell.dust = dust
        dustCell.handleLikeButtonTapped = { [weak self] (senderCell, isLiked) in
            guard let self = self else { return }
            self.messageAlert(message: Const.Message.likeRemoveMessage) { okButtonTapped in
                if okButtonTapped {
                    // 즐겨찾기 해제
                    self.dbManager.deleteLikeLocationFromDB(location: dust.location!)
                    // 좋아요 해제를 화면에 즉시 반영
                    senderCell.dust?.isLiked = false
                    senderCell.setLikeButtonUI()
                }
            }
        }
        return dustCell
    }
}

extension LikeZoneViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
