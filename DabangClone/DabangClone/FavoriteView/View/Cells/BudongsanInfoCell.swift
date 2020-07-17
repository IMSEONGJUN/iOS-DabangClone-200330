//
//  BudongsanInfoCell.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/04/03.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class BudongsanInfoCell: UITableViewCell {

    static let identifier = "BudongsanInfoCell"
   
    var data: Broker! {
        didSet{
            nameLabel.text = (data.companyName ?? "N/A")
            let url = URL(string: "https://dabang.s3.amazonaws.com/" + (data.image ?? ""))
            profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "MartIcon"), options: .continueInBackground)
            self.roomCountButton.setTitle("\(data.pkList?.count ?? 0)개의 방", for: .normal)
        }
    }
    
    private var roomInfoCell = RoomInfoCell()
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    private let roomCountButton: UIButton = {
       let btn = UIButton()
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.backgroundColor = .white
        btn.setTitleColor(.gray, for: .normal)
        btn.setTitle("0개의 방", for: .normal)
        return btn
    }()
    
    private let profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "MartIcon")
        iv.clipsToBounds = true
        iv.layer.cornerRadius = iv.frame.width / 2
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let separatorLine: UIView = {
       let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(info: Broker, roomPK: Int?) {
        self.data = info
        guard let roomPK = roomPK else { return }
        APIManager.shared.getCertainRoomData(pk: roomPK) { (result) in
            switch result {
            case .success(let room):
                self.roomInfoCell.data = room
                self.roomInfoCell.heartButton.isSelected = UserActionTracker.shared.markedRoomList.contains(roomPK)
            case .failure(let error):
                print("failed to fetch room data from broker: ", error)
            }
        }
    }
    
    private func configure() {
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.backgroundColor = .white
        let roomInfoView = roomInfoCell.overralContainerView
        
        contentView.addSubviews([nameLabel, roomCountButton, profileImageView, separatorLine, roomInfoView])
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(15)
        }
        roomCountButton.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.bottom.equalTo(profileImageView.snp.bottom)
            $0.width.equalTo(100)
        }
        profileImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(70)
        }
        separatorLine.snp.makeConstraints {
            $0.top.equalTo(roomCountButton.snp.bottom).offset(10)
            $0.leading.equalTo(roomCountButton)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        roomInfoView.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }

}
