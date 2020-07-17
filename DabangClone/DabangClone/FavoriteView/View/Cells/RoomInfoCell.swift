//
//  RoomInfoCell.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/04/03.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import SnapKit

protocol RoomInfoCellDelegate: class {
    func didTapCheckButton(cell: RoomInfoCell, isChecked: Bool)
}

class RoomInfoCell: UITableViewCell {
    static let identifier = "RoomInfoCell"

    
    // MARK: - Properties
    var data: DabangElement! {
        didSet{
            reConfigureCell()
        }
    }
    
    private var isMarked: Bool {
        return heartButton.isSelected
    }
    
    weak var delegate: RoomInfoCellDelegate?
    
    private let checkButtonToCompare = UIButton()
    
    let overralContainerView = UIView()
    
    private lazy var infoStackView = UIStackView(arrangedSubviews: [nameLabel, priceLabel, infoLabel, detailLabel, etceteraStackView])
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private let priceLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        return label
    }()
    
    private let infoLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let detailLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let etceteraStackView = UIStackView()
    private var etceteraArray = [String]()
    
    private let roomImageView = UIImageView()
    
    let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
    lazy var heartButton: UIButton = {
       let btn = UIButton()
        btn.setImage(UIImage(systemName: "heart", withConfiguration: smallConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: smallConfiguration)?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .selected)
        btn.addTarget(self, action: #selector(didTapHeartButton(_:)), for: .touchUpInside)
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }()
    
    var isCheckButtonSelected = false {
        didSet{
            checkButtonToCompare.isSelected = isCheckButtonSelected
            delegate?.didTapCheckButton(cell: self, isChecked: isCheckButtonSelected)
        }
    }
  
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCheckButton()
        configureOverralContainerView()
        setNotiCenter()
        configureEtcStackView()
        configureInfoStackView()
        configureRoomImageView()
        configureTotalStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Setup
    private func reConfigureCell() {
        self.nameLabel.text = data.name
        
        self.priceLabel.text = data.salesForm.type == .전세 || data.salesForm.type == .매매
            ? data.salesForm.type.rawValue + " " + data.salesForm.depositChar
            : data.salesForm.type.rawValue + " " + data.salesForm.depositChar + "/" + data.salesForm.monthlyChar

        let area = data.areaChar.components(separatedBy: " ").first
        self.infoLabel.text = data.type.rawValue + " | \(data.floor) | " + (area ?? "") + "m²"
        self.detailLabel.text = data.dabangDescription
        
        etceteraArray = data.optionSet?.map({$0.rawValue}) ?? []
        etceteraStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        putLabelInStackView()
        
        self.heartButton.isSelected = UserActionTracker.shared.markedRoomList.contains(self.data.pk)
        if !data.postimage.isEmpty {
            let url = URL(string: "https://dabang.s3.amazonaws.com/\(data.postimage[0])")
            self.roomImageView.kf.setImage(with: url)
            self.roomImageView.contentMode = .scaleAspectFill
        }
        if self.nameLabel.text == "" {
            infoStackView.removeArrangedSubview(nameLabel)
        }
    }
    
    private func configureEtcStackView() {
        etceteraStackView.axis = .horizontal
        etceteraStackView.spacing = 3
        etceteraStackView.alignment = .center
    }
    
    private func putLabelInStackView() {
        var totalWidthOfEtc:CGFloat = 0
        var shouldStop = false
        
        etceteraArray
            .map{ (word) -> UILabel in
            let label = UILabel()
            guard shouldStop == false else { label.text = ""; return label}
            label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            label.backgroundColor = #colorLiteral(red: 0.9058129191, green: 0.905921638, blue: 0.9057757854, alpha: 1)
            label.textColor = #colorLiteral(red: 0.3764393032, green: 0.3764881492, blue: 0.3764226437, alpha: 1)
            label.lineBreakMode = .byClipping
            label.text = word
            
            let labelWidth = label.intrinsicContentSize.width
            if totalWidthOfEtc + labelWidth >= 180 {
                label.text = "・・・"
                shouldStop = true
            } else {
                totalWidthOfEtc += labelWidth + 3
            }
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            return label
            }
            .forEach{ etceteraStackView.addArrangedSubview($0) }
    }
    
    private func configureInfoStackView() {
        infoStackView.autoresizingMask = [.flexibleHeight]
        infoStackView.axis = .vertical
        infoStackView.setCustomSpacing(15, after: priceLabel)
        infoStackView.spacing = 5
        infoStackView.alignment = .leading
        infoStackView.snp.makeConstraints {
            $0.width.equalTo(200)
        }
    }
    
    private func configureCheckButton() {
        contentView.backgroundColor = .white
        contentView.addSubview(checkButtonToCompare)
        checkButtonToCompare.setImage(#imageLiteral(resourceName: "unchecked").withRenderingMode(.alwaysOriginal), for: .normal)
        checkButtonToCompare.setImage(#imageLiteral(resourceName: "checked").withRenderingMode(.alwaysOriginal), for: .selected)
        checkButtonToCompare.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        checkButtonToCompare.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(15)
            $0.width.height.equalTo(25)
        }
    }
    
    private func configureOverralContainerView() {
        contentView.addSubview(overralContainerView)
        overralContainerView.backgroundColor = .white
        overralContainerView.clipsToBounds = true
        overralContainerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func configureRoomImageView() {
        roomImageView.isUserInteractionEnabled = true
        roomImageView.contentMode = .scaleAspectFill
        roomImageView.layer.cornerRadius = 8
        roomImageView.clipsToBounds = true
        roomImageView.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        roomImageView.addSubview(heartButton)
        
        configureHeartButton()
    }
    
    private func configureHeartButton() {
        heartButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(3)
            $0.width.height.equalTo(30)
        }
        heartButton.imageView?.snp.makeConstraints({
            $0.top.leading.trailing.bottom.equalToSuperview()
        })
    }
    
    private func configureTotalStackView() {
        let overralStackView = UIStackView(arrangedSubviews: [infoStackView, roomImageView])
        overralStackView.axis = .horizontal
        overralStackView.spacing = 30
        overralStackView.alignment = .top
        overralContainerView.addSubview(overralStackView)
        overralStackView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        overralStackView.isLayoutMarginsRelativeArrangement = true
        overralStackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private func setNotiCenter() {
        NotificationCenter.default.addObserver(forName: FavoriteListViewController.compareModeOn, object: nil,
                                               queue: .main) { [weak self] (noti) in
                                                guard let self = self else { return }
                                                UIView.animate(withDuration: 0.3) {
                                                    self.overralContainerView.transform = CGAffineTransform(translationX: 50, y: 0)
                                                    }
                                                }
        NotificationCenter.default.addObserver(forName: FavoriteListViewController.compareModeOff, object: nil,
                                                queue: .main) { [weak self] (noti) in
                                                 guard let self = self else { return }
                                                    UIView.animate(withDuration: 0.3) {
                                                        self.overralContainerView.transform = .identity
                                                        self.isCheckButtonSelected = false
                                                    }
                                                 }
    }
    
    func set(roomInfo: DabangElement) {
        self.data = roomInfo
    }
    
    
    // MARK: - Action Handler
    @objc private func didTapHeartButton(_ sender: UIButton) {
        heartButton.isSelected.toggle()
        if isMarked {
            print("marked")
            APIManager.shared.postMarkRoom(roomPK: self.data.pk) { (result) in
                switch result {
                case .success():
                    print("successfully post marked room")
                case .failure(let error):
                    print("failed to post marked room: ",error)
                }
            }
        } else {
            //Delete marked data stored in Server
            print("unmareked")
            APIManager.shared.deleteMarkedRoom(roomPK: self.data.pk) { (result) in
                switch result {
                case .success():
                    print("successfully delete marked room")
                case .failure(let error):
                    print("failed to delete marked room: ",error)
                }
            }
        }
    }
    
    @objc private func didTapCheckButton(_ sender: UIButton) {
        if FavoriteListViewController.compareCount < 3 {
            isCheckButtonSelected.toggle()
        } else if FavoriteListViewController.compareCount == 3 && isCheckButtonSelected {
            isCheckButtonSelected.toggle()
        } else if FavoriteListViewController.compareCount == 3 && !isCheckButtonSelected {
            return
        }
        sender.isSelected = isCheckButtonSelected
    }
}
