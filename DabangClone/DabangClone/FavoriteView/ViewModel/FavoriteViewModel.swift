//
//  FavoriteViewModel.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/04/03.
//  Copyright © 2020 pandaman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol FavoriteViewModelDelegate: class {
    func reloadTableView()
}

final class FavoriteViewModel {
    
    // MARK: - Properties
    weak var delegate: FavoriteViewModelDelegate?

    var selectedIndex = BehaviorRelay<Int>(value: 0)
    var activeData = PublishSubject<FavoriteData>()
    var noneObservableActiveData = FavoriteData.checkedRoomInfo([])
    var itemCount = 0
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - Initialize
    init() {
        dataBind()
//        fetchRecentlyCheckedRooms()
    }
    
    
    // MARK: - Binding
    func dataBind() {
        selectedIndex
            .subscribe(onNext: { [unowned self] in
                self.itemCount = 0
                self.setActiveData($0)
            })
            .disposed(by: disposeBag)
        
        activeData
            .subscribe(onNext:{ [unowned self] in
                self.noneObservableActiveData = $0
                switch $0 {
                case .checkedRoomInfo(let rooms):
                    self.itemCount = rooms.count
                case .checkedDanziInfo(let danzis):
                    self.itemCount = danzis.count
                case .markedRoomInfo(let rooms):
                    self.itemCount = rooms.count
                case .markedDanziInfo(let danzis):
                    self.itemCount = danzis.count
                case .budongsanInfo(let budongsans):
                    self.itemCount = budongsans.count
                }
                self.delegate?.reloadTableView()
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - API Network
    private func fetchMarkedComplex() {
        APIManager.shared.getMarkedComplexList { (result) in
            switch result {
            case .success(let complexs):
                self.activeData.onNext(.markedDanziInfo(complexs))
            case .failure(let error):
                print("failed to fetch marked complex: ", error)
            }
        }
    }
    
    private func fetchCheckedComplex() {
        APIManager.shared.getRecentlyCheckedComplexList { (result) in
            switch result {
            case .success(let complexs):
                self.activeData.onNext(.checkedDanziInfo(complexs))
            case .failure(let error):
                print("failed to fetch checked complex: ", error)
            }
        }
    }
    
    private func fetchMarkedRooms() {
        APIManager.shared.getMarkedRooms { (result) in
            switch result {
            case .success(let rooms):
                self.activeData.onNext(.markedRoomInfo(rooms))
                UserActionTracker.shared.markedRoomList = rooms.map{$0.pk}
            case .failure(let error):
                print("failed to fetch marked rooms: ", error)
            }
        }
    }
    
    private func fetchRecentlyCheckedRooms() {
        APIManager.shared.getRecentlyCheckedRooms { (result) in
            switch result {
            case .success(let rooms):
                self.activeData.onNext(.checkedRoomInfo(rooms))
            case .failure(let error):
                print("failed to fetch recently checked rooms: ", error)
            }
        }
    }
    
    private func fetchContactedBrokersData() {
        APIManager.shared.getContactedBrokerList { (result) in
            switch result {
            case .success(let brokers):
                self.activeData.onNext(.budongsanInfo(brokers))
            case .failure(let error):
                print("failed to fetch broker list: ", error)
            }
        }
    }
    
    
    // MARK: - Action Handler
    private func setActiveData(_ dataIndex: Int) {
        switch dataIndex {
        case 0:
            fetchRecentlyCheckedRooms()
        case 1:
            fetchCheckedComplex()
        case 2:
            fetchMarkedRooms()
        case 3:
            fetchMarkedComplex()
        case 4:
            fetchContactedBrokersData()
        default:
            break
        }
    }
    
    func checkActiveDataAndSetCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, on viewController: FavoriteListViewController) -> UITableViewCell {
        switch noneObservableActiveData {
        case .checkedRoomInfo(let rooms):
            let cell = tableView.dequeueReusableCell(withIdentifier: RoomInfoCell.identifier, for: indexPath) as! RoomInfoCell
            cell.set(roomInfo: rooms[indexPath.row])
            return cell
        case .checkedDanziInfo(let danzis):
            let cell = tableView.dequeueReusableCell(withIdentifier: DanziInfoCell.identifier, for: indexPath) as! DanziInfoCell
            cell.delegate = viewController
            cell.set(danziInfo: danzis[indexPath.row])
            return cell
        case .markedRoomInfo(let rooms):
            let cell = tableView.dequeueReusableCell(withIdentifier: RoomInfoCell.identifier, for: indexPath) as! RoomInfoCell
            cell.delegate = viewController
            cell.set(roomInfo: rooms[indexPath.row])
            return cell
        case .markedDanziInfo(let danzis):
            let cell = tableView.dequeueReusableCell(withIdentifier: DanziInfoCell.identifier, for: indexPath) as! DanziInfoCell
            cell.delegate = viewController
            cell.set(danziInfo: danzis[indexPath.row])
            return cell
        case .budongsanInfo(let budongsan):
            let cell = tableView.dequeueReusableCell(withIdentifier: BudongsanInfoCell.identifier, for: indexPath) as! BudongsanInfoCell
            cell.set(info: budongsan[indexPath.row], roomPK: budongsan[indexPath.row].pkList?.first ?? nil)
            return cell
        }
    }
}
