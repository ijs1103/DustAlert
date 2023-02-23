//
//  MyZoneViewController.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/01.
//

import UIKit
import SnapKit

final class MyZoneViewController: UIViewController {
    
    let dustManager = DustManager.shared
    let networkManager = NetworkManager.shared
    let dbManager = DBManager.shared
    var selectedDust: Dust?
    var fetchedDust: [Dust] = []

    private let emptyLabelView = EmptyLabelView(text: Const.Label.myZoneEmptyLabel)

    private lazy var sidoTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .systemGreen
        textField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return textField
    }()
    
    private lazy var sidoTextView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.backgroundColor = UIColor.white.cgColor
        view.addSubview(sidoTextField)
        return view
    }()
    
    private lazy var gunguTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .systemGreen
        textField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return textField
    }()
    
    private lazy var gunguTextView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.backgroundColor = UIColor.white.cgColor
        view.addSubview(gunguTextField)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [sidoTextView, gunguTextView])
        stview.spacing = 10
        stview.axis = .horizontal
        stview.distribution = .fillEqually
        stview.alignment = .fill
        return stview
    }()
    
    private lazy var siPickerView = UIPickerView()
    private lazy var gunguPickerView = UIPickerView()
    
    private lazy var dustTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .clear
        tableview.isHidden = (selectedDust == nil) ? true : false
        return tableview
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.isHidden = true
        return activityIndicator
    }()
    
    private func showActivityIndicator() {
        gunguTextField.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideActivityIndicator() {
        gunguTextField.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    private func initUI() {
        self.view.backgroundColor = .black
        [  emptyLabelView, stackView, dustTableView, activityIndicator ].forEach {
            view.addSubview($0)
        }
        initNavigation()
        initPickerView()
        initTableView()
        setConstraints()
    }
    private func initData() {
        selectedDust = dustManager.getMyZoneDust()
        if selectedDust != nil {
            emptyLabelView.isHidden = true
        }
    }
    private func initNavigation() {
        self.navigationItem.title = Const.Title.myZone
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func initPickerView() {
        sidoTextField.inputView = siPickerView
        gunguTextField.inputView = gunguPickerView
        
        // placeholder에 text 및 color 적용
        sidoTextField.attributedPlaceholder = NSAttributedString(string: "시/도", attributes: [.foregroundColor: UIColor.systemGreen])
        gunguTextField.attributedPlaceholder = NSAttributedString(string: "군/구", attributes: [.foregroundColor: UIColor.systemGreen])
        
        [ sidoTextField, gunguTextField ].forEach {
            $0.textAlignment = .center
            // UITextField 커서 투명하게
            $0.tintColor = .clear
        }
        
        siPickerView.delegate = self
        siPickerView.dataSource = self
        gunguPickerView.delegate = self
        gunguPickerView.dataSource = self
        
        siPickerView.tag = 1
        gunguPickerView.tag = 2
    }
    private func initTableView(){
        dustTableView.dataSource = self
        dustTableView.delegate = self
        dustTableView.register(UINib(nibName: Const.Id.dustCell, bundle: nil), forCellReuseIdentifier: Const.Id.dustCell)
    }
    private func setConstraints() {
        emptyLabelView.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
        sidoTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        gunguTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        dustTableView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        activityIndicator.snp.makeConstraints {
            $0.center.equalTo(gunguTextView.snp.center)
        }
    }
    
}

extension MyZoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedDust != nil) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let selectedDust = selectedDust else { return DustCell() }
        let dustCell = dustTableView.dequeueReusableCell(withIdentifier: Const.Id.dustCell, for: indexPath) as! DustCell
        dustCell.dust = selectedDust
        dustCell.selectionStyle = .none
        dustCell.handleLikeButtonTapped = { [weak self] (senderCell, isLiked) in
            guard let self = self else { return }
            if (!isLiked) {
                self.messageAlert(message: Const.Message.likeAddMessage) { okButtonTapped in
                    if okButtonTapped {
                        // 즐겨찾기 추가
                        self.dbManager.setLikeLocationToDB(location: selectedDust.location!)
                        // 즐겨찾기 추가를 화면에 즉시 반영
                        senderCell.dust?.isLiked = true
                        senderCell.setLikeButtonUI()
                    }
                }
            } else {
                self.messageAlert(message: Const.Message.likeRemoveMessage) { okButtonTapped in
                    if okButtonTapped {
                        // 즐겨찾기 해제
                        self.dbManager.deleteLikeLocationFromDB(location: selectedDust.location!)
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

extension MyZoneViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}

extension MyZoneViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return Const.SidoArr.count
        case 2:
            return fetchedDust.count
        default:
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return Const.SidoArr[row]
        case 2:
            return fetchedDust[row].gunguName ?? ""
        default:
            return "empty data"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            // sidoTextField에 선택한 시/도 로 업데이트
            sidoTextField.text = Const.SidoArr[row]
            // indicator 활성화, 군/구 선택창 disable
            showActivityIndicator()
            gunguTextView.isUserInteractionEnabled = false
            // 시/도에 따른 군/구 데이터 Fetch
            networkManager.fetchDust(Const.SidoArr[row]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(result):
                    self.fetchedDust = result.response.body.items
                    // gunguPickerView 리로드 및 text 초기화
                    self.gunguPickerView.reloadAllComponents()
                    // indicator 비활성화, 군/구 선택창 enable
                    self.hideActivityIndicator()
                    self.gunguTextView.isUserInteractionEnabled = true
                    self.gunguTextField.text = "군/구"
                    self.sidoTextField.resignFirstResponder()
                case let .failure(error):
                    debugPrint("fetch failed. error: \(error)")
                }
            }
            
        case 2:
            // gunguTextField의 text를 선택한 군/구 로 업데이트
            gunguTextField.text = fetchedDust[row].gunguName
            // selectedDust를 선택한 Dust로 업데이트
            selectedDust = fetchedDust[row]
            // db에 선택한 Dust 저장
            dbManager.setMyZoneToDB(dust: selectedDust!)
            // emptyLabel 숨기고, tableView 리로드
            emptyLabelView.isHidden = true
            dustTableView.isHidden = false
            dustTableView.reloadData()
            gunguTextField.resignFirstResponder()
        default:
            return
        }
    }
}

