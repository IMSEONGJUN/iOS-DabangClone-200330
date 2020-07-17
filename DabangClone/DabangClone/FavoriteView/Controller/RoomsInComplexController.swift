//
//  RoomsInComplexController.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/05/17.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class RoomsInComplexController: UIViewController {

    private let tableView = UITableView()
    private var disposeBag = DisposeBag()
    var roomsPK = [Int]() {
        didSet{
            subscribeDataSource()
        }
    }
    
    var rooms: [DabangElement]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        tableView.reloadData()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(RoomInfoCell.self, forCellReuseIdentifier: RoomInfoCell.identifier)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func subscribeDataSource() {
        roomsPK.forEach({
            APIManager.shared.rxGetCertainRoomData(pk: $0)
            .retry()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.rooms == nil {
                    self.rooms = [DabangElement]()
                }
                self.rooms?.append($0)
            })
            .disposed(by: disposeBag)
        })
    }
}

extension RoomsInComplexController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomInfoCell.identifier, for: indexPath) as! RoomInfoCell
        guard let rooms = self.rooms else { return UITableViewCell() }
        cell.set(roomInfo: rooms[indexPath.row])
        return cell
    }
}

extension RoomsInComplexController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? RoomInfoCell else { return }
        let vc = NewMainRoomViewController()
        vc.isFromFavoriteTab = true
        vc.roomData = selectedCell.data
        vc.pk = selectedCell.data.pk
        vc.setTableViewReload()
        navigationController?.pushViewController(vc, animated: true)
    }
}
