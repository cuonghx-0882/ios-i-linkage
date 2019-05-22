//
//  RequestScreenViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/19/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import MessengerKit

final class RequestScreenViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyView: UIView!
    
    // MARK: - Propeties
    private var data = [MessageItemListModel]()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = TitleScreen.requestScren
        tabBarController?.delegate = self
    }
    
    // MARK: - Method
    private func configView() {
        tableView.do {
            $0.register(cellType: MessageItemListCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.estimatedRowHeight = 77
            $0.refreshControl = UIRefreshControl()
            $0.refreshControl?.addTarget(self,
                                         action: #selector(reloadData),
                                         for: .valueChanged)
        }
    }
    
    @objc
    private func reloadData() {
        tableView.refreshControl?.endRefreshing()
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.contentOffset = CGPoint.zero
        })
        loadData()
    }
    
    private func loadData() {
        guard let auth = AuthManagerLocalDataSource.shared.getUser() else {
            return
        }
        if Connectivity.isConnectedToInternet {
            self.navigationController?.progessAnimation(true)
            FirebaseService.share
                .getListMessage(uid: auth.uid,
                                connected: false) {[weak self] (results, err) in
                                    self?.navigationController?.progessAnimation(false)
                                    if let err = err {
                                        self?.showErrorAlert(errMessage: err.localizedDescription)
                                    } else {
                                        self?.data = results
                                        self?.tableView.reloadData()
                                    }
                }
        } else {
            navigationController?.showErrorAlert(errMessage: Message.checkNetworkingMS)
        }
    }
}

// MARK: - UITableViewDelegate
extension RequestScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = data[indexPath.row]
        showAlertView(title: model.user.name + Message.mesageRequest,
                      message: model.messagelast.content,
                      cancelButton: "Cancel",
                      otherButtons: ["Yes", ButtonTitle.goProfile]) {[weak self] (index) in
                        switch index {
                        case 0:
                            FirebaseService.share
                                .connectMessage(messageID: model.messageModel.id,
                                                completion: { (err) in
                                                    if let err = err {
                                                        self?.showErrorAlert(errMessage: err.localizedDescription)
                                                    } else {
                                                        self?.data.remove(at: indexPath.row)
                                                        self?.tableView.reloadData()
                                                    }
                            })
                        case 1:
                            let detailScreen = DetailScreenViewController.instantiate().then {
                                $0.model = model.user
                            }
                            self?.navigationController?.pushViewController(detailScreen,
                                                                           animated: true)
                        default:
                            break
                        }
        }
    }
}

// MARK: - UITableViewDataSource
extension RequestScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageItemListCell = tableView.dequeueReusableCell(for: indexPath)
        let model = data[indexPath.row]
        cell.setContent(model: model)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !data.isEmpty {
            tableView.do {
                $0.backgroundView = nil
            }
            return 1
        }
        tableView.do {
            $0.backgroundView = emptyView
        }
        return 0
    }
}

// MARK: - UITabBarControllerDelegate
extension RequestScreenViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard tabBarController.selectedViewController == viewController,
            viewController == self else {
                return tabBarController.selectedViewController != viewController
        }
        if let navbar = navigationController?.navigationBar,
            -tableView.contentOffset.y != navbar.frame.height + navbar.frame.origin.y {
            tableView.scrollToRow(at: IndexPath(row: 0,
                                                section: 0),
                                  at: .top,
                                  animated: true)
        } else {
            loadData()
        }
        return tabBarController.selectedViewController != viewController
    }
}
