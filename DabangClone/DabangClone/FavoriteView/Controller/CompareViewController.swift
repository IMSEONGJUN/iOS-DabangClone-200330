//
//  CompareViewController.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/04/10.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import SnapKit

class CompareViewController: UIViewController {

    // MARK: - Peroperties
    
    private let noticeView = UIView()
    private let noticeLabel = UILabel()
    
    var roomsToCompare: [Int : DabangElement]! {
        didSet{
            makeCompareValuesArrayUsingDictValues()
            noticeLabel.text = "\(self.roomsToCompare.count)개의 방을 비교한 후, 원하는 방을 문의하세요."
        }
    }
    
    private var compareValues = [DabangElement]()
    private lazy var compareValuesCount = self.compareValues.count
    
    private let overralScrollView = UIScrollView()
    private let detailScrollView = UIScrollView()
    
    private var askButton1 = CompareViewAskButton()
    private var askButton2 = CompareViewAskButton()
    private var askButton3 = CompareViewAskButton()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configureNoticePart()
        configureScrollView()
        configureHeaders()
        configureDetails()
        configureAskButtons()
    }
    
    
    // MARK: - Initial Setup
    
    private func setNavigationBar() {
        title = "비교하기"
        view.backgroundColor = .white
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(didTapCloseButton))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func configureNoticePart() {
        view.addSubview(noticeView)
        noticeView.addSubview(noticeLabel)
        noticeView.backgroundColor = #colorLiteral(red: 0.9646322131, green: 0.9647476077, blue: 0.9645928741, alpha: 1)
        noticeLabel.textColor = .lightGray
        noticeLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        noticeView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        noticeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func makeCompareValuesArrayUsingDictValues() {
        for dict in roomsToCompare.sorted(by: {$0.0 < $1.0}) {
            compareValues.append(dict.value)
        }
    }
    
    private func configureScrollView() {
        view.addSubview(overralScrollView)
        overralScrollView.showsVerticalScrollIndicator = false
        overralScrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(noticeView.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        overralScrollView.addSubview(detailScrollView)
        detailScrollView.snp.makeConstraints {
            $0.top.equalTo(overralScrollView.snp.top).offset(190)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func configureHeaders() {
        var counter = 0
        let headers = compareValues.map{CompareHeaderView(data: $0)}
        headers.forEach({
                        overralScrollView.addSubview($0)
                        $0.snp.makeConstraints {
                            $0.top.equalTo(overralScrollView)
                            $0.height.equalTo(190)
                            $0.width.equalTo(view.frame.width / 2)
                            if counter == 0 {
                                $0.leading.equalTo(overralScrollView)
                            } else {
                                $0.leading.equalTo(headers[counter - 1].snp.trailing)
                            }
                        }
                        counter += 1
                        if counter == compareValuesCount {
                            $0.snp.makeConstraints { $0.trailing.equalTo(overralScrollView.snp.trailing)}
                        }
                       })
    }
    
    private func configureDetails() {
        var counter = 0
        let details = compareValues.map({CompareDetailView(data: $0)})
        details.forEach({
                        detailScrollView.addSubview($0)
                        $0.snp.makeConstraints {
                            $0.top.equalToSuperview()
                            $0.bottom.equalToSuperview().inset(250)
                            $0.width.equalTo(view.frame.width / 2)
                            $0.height.equalTo(detailScrollView)
                            if counter == 0 {
                                $0.leading.equalToSuperview()
                            } else {
                                $0.leading.equalTo(details[counter - 1].snp.trailing)
                            }
                        }
                        counter += 1
                        if counter == compareValuesCount {
                            $0.snp.makeConstraints({ $0.trailing.equalToSuperview() })
                        }
                      })
    }
    
    private func configureAskButtons() {
        var counter = 0
        let askButtons = (0..<compareValuesCount).map({ (num) -> CompareViewAskButton in
            let askBtn = CompareViewAskButton()
            askBtn.tag = num
            return askBtn
        })
        askButtons.forEach({
            detailScrollView.addSubview($0)
            $0.addTarget(self, action: #selector(didTapAskButton(_:)), for: .touchUpInside)
            $0.snp.makeConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                $0.width.equalTo(view.frame.width / 2)
                $0.height.equalTo(50)
                if counter == 0 {
                    $0.leading.equalToSuperview()
                } else {
                    $0.leading.equalTo(askButtons[counter - 1].snp.trailing)
                }
                counter += 1
            }
        })
        
    }
        
    // MARK: - Action Handler
    
    @objc private func didTapAskButton(_ sender: UIButton) {
        let roomID = self.compareValues[sender.tag].pk
        let brokerData = self.compareValues[sender.tag].broker
        let brokerInfoVC = BrokerInfoPopUpVC()
        brokerInfoVC.set(brokerData: brokerData, roomPK: roomID)
        brokerInfoVC.modalPresentationStyle = .overFullScreen
        brokerInfoVC.modalTransitionStyle = .crossDissolve
        present(brokerInfoVC, animated: true)
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
}
