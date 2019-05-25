//
//  SearchByDistanceViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/10/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import CoreLocation
import KUIPopOver

final class SearchByDistanceViewController: BaseViewController {

    // MARK: IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyDataView: UIView!
    
    // MARK: Properties
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager().then {
            $0.requestAlwaysAuthorization()
            $0.requestWhenInUseAuthorization()
        }
        return locationManager
    }()
    private var data = [ModelCellResult]()
    private var currentLocation: Location!
    private var filteredData = [ModelCellResult]()
    private lazy var filterPopup: FilterPopup = {
        let popup = FilterPopup(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 290,
                                              height: 252)).then {
                                                $0.delegate = self
        }
        return popup
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        configLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?
            .rightBarButtonItem = UIBarButtonItem(title: "Filter",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(handerFilter(sender:)))
        tabBarController?.title = TitleScreen.searchByDistanceScreen
        tabBarController?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.topItem?
            .rightBarButtonItem = nil
    }
    
    // MARK: Method
    private func configView() {
        tableView.do {
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: ResultSearchTableViewCell.self)
            $0.estimatedRowHeight = 75
            $0.refreshControl = UIRefreshControl()
            $0.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        }
    }
    
    @objc
    func reloadData() {
        tableView.refreshControl?.endRefreshing()
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.contentOffset = CGPoint.zero
        })
        loadData()
    }
    
    @objc
    private func handerFilter(sender: UIBarButtonItem) {
        filterPopup.showPopover(barButtonItem: sender,
                                shouldDismissOnTap: false)
    }
    
    private func configLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.do {
                $0.delegate = self
                $0.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                $0.startUpdatingLocation()
            }
        } else {
            showAlertView(title: Message.gpsAccessTitle,
                          message: Message.gpsAccessMS,
                          cancelButton: "OK")
        }
    }
    
    private func loadData() {
        if Connectivity.isConnectedToInternet {
            navigationController?.progessAnimation(true)
            let share = FirebaseService.share
            share.getAllLocation(currentLocation: currentLocation) { [weak self] (locations, err) in
                self?.navigationController?.progessAnimation(false)
                if let err = err {
                    self?.showErrorAlert(errMessage: err.localizedDescription)
                } else if !locations.isEmpty {
                    var dataSorted = locations.sorted(by: { $0.location.distance < $1.location.distance })
                    dataSorted.removeFirst()
                    self?.data = dataSorted
                    self?.filterPopup.clearFilter()
                    self?.handlerFilterButton(filterPopup: nil,
                                              filter: Filter(ageFrom: "",
                                                             ageTo: "",
                                                             distanceFrom: "",
                                                             distanceTo: "",
                                                             gender: 0,
                                                             enable100km: false))
                    self?.tableView.reloadData()
                }
            }
        } else {
            showErrorAlert(errMessage: Message.checkNetworkingMS)
        }
    }
}

// MARK: - StoryboardSceneBased
extension SearchByDistanceViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

// MARK: - UITableViewDataSource
extension SearchByDistanceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResultSearchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let model = filteredData[indexPath.row]
        cell.setContent(model: model)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !filteredData.isEmpty {
            tableView.do {
                $0.backgroundView = nil
            }
            return 1
        }
        tableView.do {
            $0.backgroundView = emptyDataView
        }
        return 0
    }
}

// MARK: - TableViewDelegate
extension SearchByDistanceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailScreen = DetailScreenViewController.instantiate().then {
            $0.model = filteredData[indexPath.row].user
        }
        navigationController?.pushViewController(detailScreen, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension SearchByDistanceViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate,
            let auth = AuthManagerLocalDataSource.shared.getUser() else { return }
        let shared = FirebaseService.share
        currentLocation = Location(lat: locValue.latitude,
                                   long: locValue.longitude)
        loadData()
        locationManager.stopUpdatingLocation()
        shared.pushLocation(uid: auth.uid,
                            location: currentLocation) {[weak self] (err) in
                                if let err = err {
                                    self?.showAlertView(title: "Error",
                                                        message: err.localizedDescription,
                                                        cancelButton: "Cancel",
                                                        cancelAction: {
                                                            self?.locationManager
                                                                .startUpdatingLocation()
                                    })
                                }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            showAlertView(title: Message.gpsAccessDeniedTitle,
                          message: Message.gpsAccessDeniedMS,
                          cancelButton: "Cancel",
                          otherButtons: [ButtonTitle.gpsGotoSettingLC],
                          cancelAction: nil) { (_) in
                            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
            }
        }
    }
}

// MARK: - FilterPopUpDelegate
extension SearchByDistanceViewController: FilterPopupDelegate {
    func handlerClearButton(filterPopup: FilterPopup) {
        filterPopup.dismissPopover(animated: true)
        filteredData = data
        tableView.reloadData()
    }
    
    func handlerFilterButton(filterPopup: FilterPopup?, filter: Filter) {
        filterPopup?.dismissPopover(animated: true)
        if !Validation.checkValidateFilter(filter: filter) {
            showAlertView(title: Message.filterNotValidate,
                          message: Message.filterNotValidateMS,
                          cancelButton: "cancel")
            return
        }
        var filtered = [ModelCellResult]()
        for item in data {
            if Validation.modelValidateWithFilter(model: item,
                                                  filter: filter) {
                filtered.append(item)
            }
        }
        filteredData = filtered
        tableView.reloadData()
    }
}

// MARK: - TabBarControllerDelegate
extension SearchByDistanceViewController: UITabBarControllerDelegate {
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
