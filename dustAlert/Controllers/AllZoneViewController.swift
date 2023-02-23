//
//  AllZoneViewController.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/01.
//

import UIKit
import SnapKit

class AllZoneViewController: UIViewController {
    
    let networkManager = NetworkManager.shared
    let dustManager = DustManager.shared
    let dbManager = DBManager.shared
    var fetchedDust: [Dust] = []
    
    private lazy var dustTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .clear
        tableview.showsVerticalScrollIndicator = false
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
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    private func initUI() {
        [ dustTableView, activityIndicator ].forEach {
            view.addSubview($0)
        }
        initNavigation()
        initTableView()
        setConstraints()
    }
    
    private func fetchData() {
        dustManager.fetchAllZoneDust() {
            self.fetchedDust = self.dustManager.getAllZoneDust()
            self.hideActivityIndicator()
            self.dustTableView.reloadData()
        }
    }
    
    private func initNavigation() {
        self.navigationItem.title = Const.Title.allZone
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func initTableView(){
        dustTableView.dataSource = self
        dustTableView.delegate = self
        dustTableView.register(UINib(nibName: Const.Id.dustCell, bundle: nil), forCellReuseIdentifier: Const.Id.dustCell)
    }
    
    private func setConstraints() {
        dustTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

}

extension AllZoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedDust.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dustCell = dustTableView.dequeueReusableCell(withIdentifier: Const.Id.dustCell, for: indexPath) as! DustCell
        dustCell.selectionStyle = .none
        let dust = fetchedDust[indexPath.row]
        dustCell.dust = dust
        dustCell.handleLikeButtonTapped = { [weak self] (senderCell, isLiked) in
            guard let self = self else { return }
            if (!isLiked) {
                self.messageAlert(message: Const.Message.likeAddMessage) { okButtonTapped in
                    if okButtonTapped {
                        // 즐겨찾기 추가
                        self.dbManager.setLikeLocationToDB(location: dust.location!)
                        // 즐겨찾기 추가를 화면에 즉시 반영
                        senderCell.dust?.isLiked = true
                        senderCell.setLikeButtonUI()
                    }
                }
            } else {
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
        }
        return dustCell
    }
}

extension AllZoneViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
