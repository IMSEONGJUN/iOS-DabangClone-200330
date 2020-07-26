//
//  FavoriteViewModel.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/04/03.
//  Copyright © 2020 pandaman. All rights reserved.
//

//import Foundation
//import UIKit
//import RxSwift
//import RxCocoa
//
//protocol FavoriteViewModelDelegate: class {
//    func reloadTableView()
//}
//
//final class FavoriteViewModel {
//
//    weak var delegate: FavoriteViewModelDelegate?
//
//    private var checkedRoomData = [DabangElement]()
//    private var checkedDanziData = [Complex]()
//    private var markedRoomData = [DabangElement]()
//    private var markedDanziData = [Complex]()
//    private var contactBudongsanData = [Broker]()
//
//    var dataIndex = 0 {
//        didSet {
//            setActiveData(dataIndex)
//        }
//    }
//
//    lazy var activeData = FavoriteData.checkedRoomInfo(checkedRoomData)
//
//    init() {
//        print("FavoViewModel init")
//        fetchRecentlyCheckedRooms()
//        fetchCheckedComplex()
//        fetchMarkedRooms()
//        fetchMarkedComplex()
//        fetchContactedBrokersData()
//    }
//
//    func tempLocalCreateUser() {
//        APIManager.shared.postCreteUser(username: "testname123", password: "123123", email: "testEmail@gmail.com") { (message, isSuccess) in
//            if isSuccess {
//                print(message)
////                self.tempLocalLogin()
//            } else {
//                print("실패")
//            }
//        }
//    }
//
//    private func fetchMarkedComplex() {
//        APIManager.shared.getMarkedComplexList { (result) in
//            switch result {
//            case .success(let complexs):
//                self.markedDanziData = complexs
//                self.activeData = FavoriteData.markedDanziInfo(self.markedDanziData)
//                self.delegate?.reloadTableView()
//                print("fetchMarkedComplex")
//            case .failure(let error):
//                print("failed to fetch marked complex: ", error)
//            }
//        }
//    }
//
//    private func fetchCheckedComplex() {
//        APIManager.shared.getRecentlyCheckedComplexList { (result) in
//            switch result {
//            case .success(let complexs):
//                self.checkedDanziData = complexs
//                self.activeData = FavoriteData.checkedDanziInfo(self.checkedDanziData)
//                self.delegate?.reloadTableView()
//                print("fetchCheckedComplex")
//            case .failure(let error):
//                print("failed to fetch checked complex: ", error)
//            }
//        }
//    }
//
//    private func fetchMarkedRooms() {
//        APIManager.shared.getMarkedRooms { (result) in
//            switch result {
//            case .success(let rooms):
//                self.markedRoomData = rooms
//                self.activeData = FavoriteData.markedRoomInfo(self.markedRoomData)
//                self.delegate?.reloadTableView()
//                UserActionTracker.shared.markedRoomList = rooms.map{$0.pk}
//                print("fetchMarkedRooms")
//            case .failure(let error):
//                print("failed to fetch marked rooms: ", error)
//            }
//        }
//    }
//
//    private func fetchRecentlyCheckedRooms() {
//        APIManager.shared.getRecentlyCheckedRooms { (result) in
//            switch result {
//            case .success(let rooms):
//                self.checkedRoomData = rooms
//                self.activeData = FavoriteData.checkedRoomInfo(self.checkedRoomData)
//                self.delegate?.reloadTableView()
//                print("fetchRecentlyCheckedRooms")
//            case .failure(let error):
//                print("failed to fetch recently checked rooms: ", error)
//            }
//        }
//    }
//
//    private func fetchContactedBrokersData() {
//        APIManager.shared.getContactedBrokerList { (result) in
//            switch result {
//            case .success(let brokers):
//                self.contactBudongsanData = brokers
//                self.activeData = FavoriteData.budongsanInfo(self.contactBudongsanData)
//                self.delegate?.reloadTableView()
//                print("fetchContactedBrokersData")
//            case .failure(let error):
//                print("failed to fetch broker list: ", error)
//            }
//        }
//    }
//
//    private func setActiveData(_ dataIndex: Int) {
//        APIManager.shared.cancelAllRequest()
//        switch dataIndex {
//        case 0:
//            self.activeData = FavoriteData.checkedRoomInfo(self.checkedRoomData)
//            fetchRecentlyCheckedRooms()
//        case 1:
//            self.activeData = FavoriteData.checkedDanziInfo(self.checkedDanziData)
//            fetchCheckedComplex()
//        case 2:
//            self.activeData = FavoriteData.markedRoomInfo(self.markedRoomData)
//            fetchMarkedRooms()
//        case 3:
//            self.activeData = FavoriteData.markedDanziInfo(self.markedDanziData)
//            fetchMarkedComplex()
//        case 4:
//            self.activeData = FavoriteData.budongsanInfo(self.contactBudongsanData)
//            fetchContactedBrokersData()
//        default:
//            break
//        }
//    }
//
//    func checkActiveDataCount() -> Int {
//        switch activeData {
//        case .checkedRoomInfo(let rooms):
//            return rooms.count
//        case .checkedDanziInfo(let danzis):
//            return danzis.count
//        case .markedRoomInfo(let rooms):
//            return rooms.count
//        case .markedDanziInfo(let danzis):
//            return danzis.count
//        case .budongsanInfo(let budongsans):
//            return budongsans.count
//        }
//    }
//
//    func checkActiveDataAndSetCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, on viewController: FavoriteListViewController) -> UITableViewCell {
//        switch activeData {
//        case .checkedRoomInfo(let rooms):
//            let cell = tableView.dequeueReusableCell(withIdentifier: RoomInfoCell.identifier, for: indexPath) as! RoomInfoCell
//            cell.set(roomInfo: rooms[indexPath.row])
//            return cell
//        case .checkedDanziInfo(let danzis):
//            let cell = tableView.dequeueReusableCell(withIdentifier: DanziInfoCell.identifier, for: indexPath) as! DanziInfoCell
//            cell.delegate = viewController
//            cell.set(danziInfo: danzis[indexPath.row])
//            return cell
//        case .markedRoomInfo(let rooms):
//            let cell = tableView.dequeueReusableCell(withIdentifier: RoomInfoCell.identifier, for: indexPath) as! RoomInfoCell
//            cell.delegate = viewController
//            cell.set(roomInfo: rooms[indexPath.row])
//            return cell
//        case .markedDanziInfo(let danzis):
//            let cell = tableView.dequeueReusableCell(withIdentifier: DanziInfoCell.identifier, for: indexPath) as! DanziInfoCell
//            cell.delegate = viewController
//            cell.set(danziInfo: danzis[indexPath.row])
//            return cell
//        case .budongsanInfo(let budongsan):
//            let cell = tableView.dequeueReusableCell(withIdentifier: BudongsanInfoCell.identifier, for: indexPath) as! BudongsanInfoCell
//            cell.set(info: budongsan[indexPath.row], roomPK: budongsan[indexPath.row].pkList?.first ?? nil)
//            return cell
//        }
//
//    }
//}
