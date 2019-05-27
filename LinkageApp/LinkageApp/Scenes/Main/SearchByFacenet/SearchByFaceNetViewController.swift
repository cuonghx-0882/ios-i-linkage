//
//  SearchByFaceNetViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/24/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ImagePicker
import Toaster

final class SearchByFaceNetViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var  emptyView: UIView!
    
    // MARK: - Properties
    private var data = [ModelFaceNet]()
    private var currentFacenet: ModelFaceNet!
    private let fnet = FaceNet()
    private let fDetector = FaceDetector()
    private var filteredData = [ModelFaceNet]()
    private lazy var filterPopup: FilterFaceNetPopup = {
        let popup = FilterFaceNetPopup(frame: CGRect(x: 0,
                                                     y: 0,
                                                     width: 290,
                                                     height: 200)).then({
                                                        $0.delegate = self
                                                     })
        
       return popup
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        loadDataFacenet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = TitleScreen.searchByFacenet
        tabBarController?.delegate = self
        navigationController?.navigationBar.topItem?
            .rightBarButtonItem = UIBarButtonItem(title: "Filter",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(handerFilter(sender:)))
    }
    
    // MARK: - Methods
    private func configView() {
        tableView.do({
            $0.delegate = self
            $0.dataSource = self
            $0.register(cellType: ResultSearchTableViewCell.self )
            $0.estimatedRowHeight = 75
            $0.refreshControl = UIRefreshControl()
            $0.refreshControl?.addTarget(self,
                                         action: #selector(loadDataFacenet),
                                         for: .valueChanged)
        })
    }
    
    @objc
    private func handerFilter(sender: UIBarButtonItem) {
        filterPopup.showPopover(barButtonItem: sender,
                                shouldDismissOnTap: false)
    }
    
    @objc
    private func loadDataFacenet() {
        tableView.refreshControl?.endRefreshing()
        guard let auth = AuthManagerLocalDataSource.shared.getUser() else {
            return
        }
        if Connectivity.isConnectedToInternet {
            navigationController?.progessAnimation(true)
            FirebaseService.share
                .getVectorFromServer(userID: auth.uid) {[weak self] (model, err) in
                    self?.navigationController?.progessAnimation(false)
                    if var model = model {
                        model.user = auth
                        self?.currentFacenet = model
                        self?.dataAvailable()
                    } else if let err = err {
                        self?.showErrorAlert(errMessage: err.localizedDescription)
                    } else {
                        self?.showAlertView(title: Title.selectImage,
                                            message: Message.selectImageMS,
                                            cancelButton: "Cancel",
                                            otherButtons: ["Yes"],
                                            cancelAction: {
                                                
                        }, otherAction: { (_) in
                            let imagePickerController = ImagePickerController().then {
                                $0.imageLimit = 3
                                $0.delegate = self
                            }
                            self?.present(imagePickerController, animated: true, completion: nil)
                        })
                    }
                }
        } else {
            showErrorAlert(errMessage: Message.checkNetworkingMS)
        }
    }
    
    private func dataAvailable() {
        showAlertView(title: Message.dataAvailable,
                      message: Message.reuseMS,
                      cancelButton: "Cancel",
                      otherButtons: ["Yes", Message.slOtherImageMS],
                      otherAction: { (id) in
            if id == 0 {
                self.getData()
            } else {
                let imagePickerController = ImagePickerController().then {
                    $0.imageLimit = 3
                    $0.delegate = self
                }
                self.present(imagePickerController, animated: true, completion: nil)
            }
        })
    }
    
    private func getData() {
        if Connectivity.isConnectedToInternet {
            navigationController?.progessAnimation(true)
            FirebaseService.share
                .getAllFacenet(currentFacenet: currentFacenet) { [weak self] (results, err) in
                    self?.navigationController?.progessAnimation(false)
                    if let err = err {
                        self?.showErrorAlert(errMessage: err.localizedDescription)
                    } else {
                        let sortedData = results.sorted(by: {
                            $0.distance < $1.distance
                        })
                        self?.data = sortedData
                        self?.filteredData = sortedData
                        self?.filterPopup.clearFilter()
                        self?.tableView.reloadData()
                    }
                }
        } else {
            showErrorAlert(errMessage: Message.checkNetworkingMS)
        }
    }
    
    private func loadFacenet(completion: (() -> Void)?) {
        if !fnet.loadedModel() {
            navigationController?.progessAnimation(true)
            DispatchQueue.global().async { [weak self] in
                self?.fnet.load()
                DispatchQueue.main.async {
                    completion?()
                    self?.navigationController?.progessAnimation(false)
                }
            }
        } else {
            completion?()
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchByFaceNetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailScreen = DetailScreenViewController.instantiate().then {
            $0.model = filteredData[indexPath.row].user
        }
        navigationController?.pushViewController(detailScreen, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SearchByFaceNetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResultSearchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setContent(model: filteredData[indexPath.row])
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
            $0.backgroundView = emptyView
        }
        return 0
    }
}

// MARK: - StoryboardSceneBased
extension SearchByFaceNetViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

// MARK: - ImagePickerDelegate
extension SearchByFaceNetViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {}
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true) {
            guard let auth = AuthManagerLocalDataSource.shared.getUser() else {
                return
            }
            self.loadFacenet {
                var vector = [[Double]]()
                for image in images {
                    if let image = CIImage(image: image),
                        let face = self.fDetector.extractFaces(frame: image).first {
                        vector.append(self.fnet.run(image: face))
                    }
                }
                self.currentFacenet = ModelFaceNet(vector: vector,
                                                   distance: 0,
                                                   user: auth)
                if !vector.isEmpty {
                    self.getData()
                    if Connectivity.isConnectedToInternet {
                        FirebaseService.share
                            .pushVectorFacenet(userID: auth.uid,
                                               model: self.currentFacenet,
                                               completion: { (err) in
                                                if let err = err {
                                                    self.showErrorAlert(errMessage: err.localizedDescription)
                                                }
                            })
                    } else {
                        Toast(text: Message.checkNetworkingMS).show()
                    }
                } else {
                    self.showAlertView(title: Message.cantdetectMS,
                                       message: Message.selectOtherIMGMS,
                                       cancelButton: "OK")
                }
                self.fnet.clean()
            }
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
}

// MARK: - TabBarControllerDelegate
extension SearchByFaceNetViewController: UITabBarControllerDelegate {
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
            loadDataFacenet()
        }
        return tabBarController.selectedViewController != viewController
    }
}

// MARK: - FilterFacenetDelegate
extension SearchByFaceNetViewController: FilterFacenetDelegate {
    func handlerFilterButton(filterPopup: FilterFaceNetPopup?, filter: Filter) {
        filterPopup?.dismissPopover(animated: true)
        if !Validation.checkValidateFilter(filter: filter) {
            showAlertView(title: Message.filterNotValidate,
                          message: Message.filterNotValidateMS,
                          cancelButton: "cancel")
            return
        }
        var filtered = [ModelFaceNet]()
        for item in data {
            if Validation.modelValidateWithFilter(model: item,
                                                  filter: filter) {
                filtered.append(item)
            }
        }
        filteredData = filtered
        tableView.reloadData()
    }
    
    func handlerClearButton(filterPopup: FilterFaceNetPopup) {
        filterPopup.dismissPopover(animated: true)
        filteredData = data
        tableView.reloadData()
    }
}
