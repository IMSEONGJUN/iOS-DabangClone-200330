//
//  FavoriteListViewController.swift
//  DabangClone
//
//  Created by SEONGJUN on 2020/03/23.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class FavoriteListViewController: UIViewController {
    
    // MARK: - Properties

    let scrollView = UIScrollView()
    let tableView = UITableView()
    lazy var selectButtons = [recentlyCheckedRoom, recentlyCheckedDanzi, markedRoom, markedDanzi,contactedBudongsan]
    
    var stackView: UIStackView!
    let recentlyCheckedRoom = FavoSelectButton(title: "최근 본 방", tag: 0)
    let recentlyCheckedDanzi = FavoSelectButton(title: "최근 본 단지", tag: 1)
    let markedRoom = FavoSelectButton(title: "찜한 방", tag: 2)
    let markedDanzi = FavoSelectButton(title: "찜한 단지", tag: 3)
    let contactedBudongsan = FavoSelectButton(title: "연락한 부동산", tag: 4)
    
    let separatorViewUpperScrollView = UIView()
    let separatorViewUnderScrollView = UIView()
    var compareView: CompareView!
    let moveToCompareVCButton = UIButton()
    
    var isInitial = true
    var viewModel = FavoriteViewModel()
    var underSeparatorHeightConst: NSLayoutConstraint!
    
    var currentTag = 0 {
        didSet {
            if currentTag != 2 {
                resetCompareMode()
                showCompareViewButton(isCompareMode: false)
            }
            
            if currentTag == 0 || currentTag == 2 {
                tableView.separatorStyle = .singleLine
            } else {
                tableView.separatorStyle = .none
            }
            
            if currentTag == 4 {
                tableView.rowHeight = 250
            } else {
                tableView.rowHeight = UITableView.automaticDimension
            }
        }
    }
    
    
    var roomsToCompare = [Int : DabangElement]() {
        didSet{
            if roomsToCompare.count > 1 {
                moveToCompareVCButton.backgroundColor = #colorLiteral(red: 0.2596234679, green: 0.5155771971, blue: 0.9926976562, alpha: 1)
            } else {
                moveToCompareVCButton.backgroundColor = #colorLiteral(red: 0.6666144729, green: 0.6666962504, blue: 0.6665866375, alpha: 1)
            }
            FavoriteListViewController.compareCount = roomsToCompare.count
        }
    }
    
    var isCompareMode = false {
        didSet {
            if isCompareMode && currentTag == 2 {
                NotificationCenter.default.post(name: FavoriteListViewController.compareModeOn, object: nil)
            } else {
                NotificationCenter.default.post(name: FavoriteListViewController.compareModeOff, object: nil)
            }
        }
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setNavigationBar()
        setupUI()
        configureUpsideUI()
        configureTableView()
        setConstraints()
        configureSwipeGesture()
        configureRefreshControl()
        configureShowCompareViewButton()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isInitial {
           setInitialCondition()
           isInitial = false
        }
    }
    
    // MARK: - Initial Setup
    
    private func setNavigationBar() {
        title = "관심 목록"
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = .white
        navigationAppearance.shadowColor = nil
        self.navigationController?.navigationBar.standardAppearance = navigationAppearance
    }
    
    private func setupUI() {
        view.addSubviews([scrollView,separatorViewUnderScrollView,separatorViewUpperScrollView,tableView])
        selectButtons.forEach({
            $0.delegate = self
        })
    }
    
    private func configureUpsideUI(){
        configureSeparatorView()
        
        scrollView.alwaysBounceHorizontal = true
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        stackView = UIStackView(arrangedSubviews: selectButtons)
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 30
        scrollView.addSubview(stackView)
    }
    
    private func configureSeparatorView() {
        separatorViewUpperScrollView.backgroundColor = .white
        separatorViewUnderScrollView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        separatorViewUnderScrollView.clipsToBounds = true
        configureCompareRoomView(on: separatorViewUnderScrollView)
    }
    
    private func configureCompareRoomView(on view: UIView) {
        compareView = CompareView()
        compareView.delegate = self
        view.addSubview(compareView)
        compareView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(RoomInfoCell.self, forCellReuseIdentifier: RoomInfoCell.identifier)
        tableView.register(DanziInfoCell.self, forCellReuseIdentifier: DanziInfoCell.identifier)
        tableView.register(BudongsanInfoCell.self, forCellReuseIdentifier: BudongsanInfoCell.identifier)
    }
    
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func configureSwipeGesture() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeAction(_:)))
        rightSwipe.direction = .right
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeAction(_:)))
        leftSwipe.direction = .left
        [rightSwipe, leftSwipe].forEach({tableView.addGestureRecognizer($0)})
    }
    
    private func configureShowCompareViewButton() {
        view.addSubview(moveToCompareVCButton)
        moveToCompareVCButton.setTitle("선택한 방 비교하기", for: .normal)
        moveToCompareVCButton.backgroundColor = #colorLiteral(red: 0.6666144729, green: 0.6666962504, blue: 0.6665866375, alpha: 1)
        moveToCompareVCButton.setTitleColor(.white, for: .normal)
        moveToCompareVCButton.addTarget(self, action: #selector(didTapMoveToCompareVCButton), for: .touchUpInside)
        moveToCompareVCButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(50)
        }
    }
    
    private func setInitialCondition() {
        didTapButton(tag: 0)
    }
    
    private func setConstraints() {
        selectButtons.forEach({
            $0.snp.makeConstraints {
                $0.height.equalTo(scrollView.snp.height)
            }
        })
        
        separatorViewUpperScrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(separatorViewUpperScrollView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        separatorViewUnderScrollView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        underSeparatorHeightConst = separatorViewUnderScrollView.heightAnchor.constraint(equalToConstant: 0.5)
        underSeparatorHeightConst.isActive = true
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(separatorViewUnderScrollView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Action Handler
    
    private func resetCompareMode() {
        isCompareMode = false
        compareView.compareButton.isSelected = false
        compareView.compareButton.backgroundColor = .gray
        compareView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        compareView.noticeLabel.text = "찜한 방의 매물을 비교해보세요."
    }
    
    @objc private func rightSwipeAction(_ gesture: UISwipeGestureRecognizer) {
        didTapButton(tag: max(currentTag - 1, 0))
    }
    
    @objc private func leftSwipeAction(_ gesture: UISwipeGestureRecognizer) {
        didTapButton(tag: min(currentTag + 1, selectButtons.count - 1))
    }
    
    @objc private func didTapMoveToCompareVCButton() {
        guard self.roomsToCompare.count > 1 else { return }
        let compareVC = CompareViewController()
        compareVC.roomsToCompare = self.roomsToCompare
        let navi = UINavigationController(rootViewController: compareVC)
        navi.modalPresentationStyle = .overFullScreen
        present(navi, animated: true)
    }
    
    @objc private func showCompareViewButton(isCompareMode: Bool) {
        UIView.animate(withDuration: 0.5) {
            if isCompareMode && self.currentTag == 2 {
                self.moveToCompareVCButton.transform = CGAffineTransform(translationX: 0,
                                                                         y: -self.moveToCompareVCButton.frame.height)
            } else {
                self.moveToCompareVCButton.transform = .identity
                self.roomsToCompare.removeAll()
            }
        }
    }
    
    @objc private func reloadData(){
        tableView.refreshControl?.endRefreshing()
        didTapButton(tag: currentTag)
//        tableView.reloadData()
    }
    
    private func checkActiveDataIfEmpty(_ tag: Int) {
        if viewModel.itemCount == 0 {
            switch tag {
            case 0:
                showEmptyStateView(message: Messages.noRecentlyCheckRoom, detail: Details.noRecentlyCheckRoom)
            case 1:
                showEmptyStateView(message: Messages.noRecentlyCheckDanzi, detail: Details.noRecentlyCheckDanzi)
            case 2:
                showEmptyStateView(message: Messages.noMarkedRoom, detail: Details.noMarkedRoom)
            case 3:
                showEmptyStateView(message: Messages.noMarkedDanzi, detail: Details.noMarkedDanzi)
            default:
                showEmptyStateView(message: Messages.noContactedBudongsan, detail: Details.noContactedBudongsan)
            }
        } else {
            if let emptyView = tableView.subviews.last as? EmptyStateView {
                emptyView.removeFromSuperview()
                tableView.reloadData()
            }
        }
    }
    
    private func showEmptyStateView(message: String, detail: String) {
        if let emptyView = tableView.subviews.last as? EmptyStateView{
            emptyView.removeFromSuperview()
        }
        let emptyView = EmptyStateView(message: message, detail: detail)
        tableView.addSubview(emptyView)
        emptyView.frame = tableView.bounds
    }
}


    // MARK: - UITableViewDataSource

extension FavoriteListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.checkActiveDataAndSetCell(tableView, cellForRowAt: indexPath, on: self)
    }
}

    // MARK: - UITableViewDelegate

extension FavoriteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let roomCell = tableView.cellForRow(at: indexPath) as? RoomInfoCell {
            if isCompareMode {
                if roomsToCompare.count < 3 {
                    roomCell.isCheckButtonSelected.toggle()
                } else if roomsToCompare.count == 3 && roomCell.isCheckButtonSelected {
                    roomCell.isCheckButtonSelected.toggle()
                } else if roomsToCompare.count == 3 && !roomCell.isCheckButtonSelected {
                    print("비교는 3개까지만 가능합니다.")
                    return
                }
            } else {
                // Present Room Detail VC
                let vc = NewMainRoomViewController()
                vc.isFromFavoriteTab = true
                vc.roomData = roomCell.data
                vc.pk = roomCell.data.pk
                vc.setTableViewReload()
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

    // MARK: - Custom Delegates

extension FavoriteListViewController: FavoSelectButtonDelegate {
    private func controlAtrributes(_ tag: Int) {
        self.underSeparatorHeightConst.constant = 0.5
        self.compareView.isHidden = true
        self.view.layoutIfNeeded()
        switch tag {
        case 0,1:
            self.scrollView.contentOffset.x = 0
        case 2:
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset.x = 20
                self.underSeparatorHeightConst.constant = 40
                self.compareView.isHidden = false
                self.view.layoutIfNeeded()
            }
        case 3:
            self.scrollView.contentOffset.x = 20
        default:
            self.scrollView.contentOffset.x = 45
        }
    }
    
    func didTapButton(tag: Int) {
        selectButtons.filter{$0.tag == tag}
                     .forEach({
                        $0.setTitleColor(.black, for: .normal)
                        $0.underLineView.isHidden = false
                     })
        
        selectButtons.filter{ $0.tag != tag }
                     .forEach({
                        $0.setTitleColor(.lightGray, for: .normal)
                        $0.underLineView.isHidden = true
                     })
        currentTag = tag
        viewModel.selectedIndex.accept(tag)
        controlAtrributes(tag)
        checkActiveDataIfEmpty(tag)
    }
}

extension FavoriteListViewController: CompareViewDelegate {
    func didTapCompareButton(isCompareMode: Bool) {
        guard viewModel.itemCount > 1 else { print("비교할 방이 부족합니다.Alert띄우기"); return }
        self.isCompareMode = isCompareMode
        showCompareViewButton(isCompareMode: isCompareMode)
    }
}

extension FavoriteListViewController: RoomInfoCellDelegate {
    func didTapCheckButton(cell: RoomInfoCell, isChecked: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let room = cell.data else { return }
        if isChecked{
            if roomsToCompare.count == 3 { print("3개 이상 비교 불가 Alert띄우기"); return }
            roomsToCompare.updateValue(room, forKey: indexPath.row)
        } else {
            roomsToCompare.removeValue(forKey: indexPath.row)
        }
    }
}

extension FavoriteListViewController: FavoriteViewModelDelegate {
    func reloadTableView() {
        tableView.reloadData()
        checkActiveDataIfEmpty(currentTag)
    }
}

extension FavoriteListViewController: DanziInfoCellDelegate {
    func didTapAvailableRoomsButtons(roomsPk: [Int]) {
        let vc = RoomsInComplexController()
        vc.roomsPK = roomsPk
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapAvailableRoomsButtons() {
        print("delegate response")
        let vc = RoomsInComplexController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapComplexInfoButton(data: Complex) {
        let vc = ComplexViewController()
        vc.setupData(complex: data)
        navigationController?.pushViewController(vc, animated: true)
    }
}

    // MARK: - Static Properties

extension FavoriteListViewController {
    static let compareModeOn = Notification.Name(rawValue: "On")
    static let compareModeOff = Notification.Name(rawValue: "Off")
    static var compareCount = 0
}
