//
//  SearchByDistanceViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/10/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import CoreLocation
import KUIPopOver

final class SearchByDistanceViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
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
    private var currentFilter: Filter?
    private var filteredData = [ModelCellResult]()
    
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.topItem?
            .rightBarButtonItem = nil
        tabBarController?.title = ""
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
        loadData()
        currentFilter = nil
    }
    
    @objc
    private func handerFilter(sender: UIBarButtonItem) {
        _ = FilterPopup(frame: CGRect(x: 0,
                                      y: 0,
                                      width: 290,
                                      height: 199)).then {
                                        $0.delegate = self
                                        $0.showPopover(barButtonItem: sender,
                                                       shouldDismissOnTap: false)
                                        $0.setupPopUp(filter: currentFilter)
        }
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
        navigationController?.progessAnimation(true)
        FirebaseService.share
            .getAllLocation(currentLocation: currentLocation) { [weak self] (locations, err) in
                self?.navigationController?.progessAnimation(false)
                let dataSorted = locations.sorted(by: { $0.location.distance < $1.location.distance })
                self?.data = dataSorted
                self?.filteredData = dataSorted
                if let err = err {
                    self?.showErrorAlert(errMessage: err.localizedDescription)
                } else {
                    self?.tableView.reloadData()
                }
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
        var numOfSections: Int = 0
        if !filteredData.isEmpty {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: tableView.bounds.size.width,
                                                    height: tableView.bounds.size.height)).then {
                                                        $0.text = "No data available"
                                                        $0.textColor = UIColor.black
                                                        $0.textAlignment = .center
            }
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }
}

// MARK: - TableViewDelegate
extension SearchByDistanceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        currentFilter = nil
        tableView.reloadData()
    }
    
    func handlerFilterButton(filterPopup: FilterPopup, filter: Filter) {
        filterPopup.dismissPopover(animated: true)
        if !Validation.checkValidateFilter(filter: filter) {
            showAlertView(title: Message.filterNotValidate,
                          message: Message.filterNotValidateMS,
                          cancelButton: "cancel")
            return
        }
        currentFilter = filter
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
