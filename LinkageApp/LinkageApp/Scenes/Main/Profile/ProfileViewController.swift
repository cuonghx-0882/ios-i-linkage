//
//  ProfileViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/19/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import Kingfisher
import ImagePicker

final class ProfileViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genderImageView: UIImageView!
    @IBOutlet private weak var ageTextfield: UITextField!
    @IBOutlet private weak var jobLabel: UILabel!
    @IBOutlet private weak var hobbiesLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var nameView: UIView!
    
    // MARK: - Properties
    private lazy var popupEditTextView: EditProfileViewController = {
        let popup = EditProfileViewController.instantiate().then({
            $0.delegate = self
        })
        return popup
    }()
    private lazy var popupEditName: EditNameViewController = {
        let popup = EditNameViewController.instantiate()
        return popup
    }()
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker().then({
            $0.datePickerMode = .date
        })
        return picker
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        settingContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = TitleScreen.profile
    }
    
    // MARK: - Method
    
    private func configView() {
        let toolbar = UIToolbar().then {
            $0.sizeToFit()
            $0.setItems([UIBarButtonItem(title: "Done",
                                         style: .plain,
                                         target: nil,
                                         action: #selector(donedatePicker)),
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                         target: nil,
                                         action: nil),
                         UIBarButtonItem(title: "Cancel",
                                         style: .plain,
                                         target: nil,
                                         action: #selector(canceldatePicker))],
                        animated: false)
        }
        ageTextfield.do {
            $0.inputAccessoryView = toolbar
            $0.inputView = datePicker
        }
        nameView.do {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(handlerTapNameView)))
        }
    }
    
    @objc
    func handlerTapNameView() {
        popupEditName.do {
            guard let nab = navigationController?.navigationBar else {
                return
            }
            $0.delegate = self
            $0.preferredContentSize = CGSize(width: view.frame.width,
                                             height: view.frame.height / 3)
            $0.showPopoverWithNavigationController(sourceView: nab)
        }
    }
    
    @objc
    private func donedatePicker() {
        guard var auth = AuthManagerLocalDataSource.shared.getUser() else {
            return
        }
        view.endEditing(true)
        auth.dob = datePicker.date.toString(dateFormat: "dd/MM/yyyy")
        if let age = auth.dob.getAgeFromDateString(), age < 14 {
            showErrorAlert(errMessage: Message.limitedAge)
        } else if Connectivity.isConnectedToInternet {
            navigationController?.progessAnimation(true)
            FirebaseService.share
                .updateProfileforKey(userID: auth.uid,
                                     key: "dob",
                                     value: auth.dob) {[weak self] (err) in
                                        self?.navigationController?.progessAnimation(false)
                                        if let err = err {
                                            self?.showErrorAlert(errMessage: err.localizedDescription)
                                        } else {
                                            AuthManagerLocalDataSource.shared.saveUser(user: auth)
                                            self?.settingContent()
                                        }
                }
        }
    }
    
    @objc
    func canceldatePicker() {
        view.endEditing(true)
    }
    
    private func settingContent() {
        guard let auth = AuthManagerLocalDataSource.shared.getUser() else {
            return
        }
        avatarImageView.kf.setImage(with: URL(string: auth.urlImage))
        genderImageView.image = auth.isMale ? UIImage(named: "male") : UIImage(named: "female")
        nameLabel.text = auth.name
        jobLabel.text = auth.job.isEmpty ? Title.addnewData : auth.job
        descriptionLabel.text = auth.description.isEmpty ? Title.addnewData : auth.description
        hobbiesLabel.text = auth.hobbies.isEmpty ? Title.addnewData : auth.hobbies
        ageTextfield.text = Message.editDOB
        if let age = auth.dob.getAgeFromDateString() {
            ageTextfield.text = "\(age) years old"
        }
    }
    
    @IBAction func handleEditButton(_ sender: UIButton) {
        popupEditTextView.do {
            guard let nab = navigationController?.navigationBar else {
                return
            }
            $0.preferredContentSize = CGSize(width: view.frame.width,
                                             height: view.frame.height / 3)
            $0.idEdit = sender.tag
            $0.showPopoverWithNavigationController(sourceView: nab)
        }
    }
    
    @IBAction func HandlerLogoutButton(_ sender: UIButton) {
        guard let nav = navigationController as? NavigationController else {
            return
        }
        AuthManagerLocalDataSource.shared.removeUser()
        nav.config()
    }
    
    @IBAction func handlerChangePhotoButton(_ sender: UIButton) {
        let imagePickerController = ImagePickerController().then {
            $0.imageLimit = 1
            $0.delegate = self
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
}

// MARK: - StoryboardSceneBased
extension ProfileViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

// MARK: - EditProfileViewControllerDelegate
extension ProfileViewController: EditProfileViewControllerDelegate {
    func onCompletion(error: Error?) {
        if let err = error {
            showErrorAlert(errMessage: err.localizedDescription)
        } else {
            settingContent()
        }
    }
}

// MARK: - ImagePickerDelegate
extension ProfileViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {}
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first,
            var auth = AuthManagerLocalDataSource.shared.getUser() else {
                return
        }
        if Connectivity.isConnectedToInternet {
            navigationController?.progessAnimation(true)
            FirebaseStoreageService.shared
                .uploadImage(image: image, path: "\(auth.uid)/avatarImage.jpeg") {[weak self] (url, err) in
                    if let url = url {
                        auth.urlImage = url.absoluteString
                        FirebaseService.share
                            .updateProfileforKey(userID: auth.uid,
                                                 key: "urlImage",
                                                 value: auth.urlImage,
                                                 completion: { (err) in
                                                    self?.navigationController?.progessAnimation(false)
                                                    if let err = err?.localizedDescription {
                                                        self?.showErrorAlert(errMessage: err)
                                                    } else {
                                                        self?.avatarImageView.image = images.first
                                                        AuthManagerLocalDataSource.shared
                                                            .saveUser(user: auth)
                                                    }
                        })
                        
                    } else if let err = err {
                        self?.navigationController?.progessAnimation(false)
                        self?.showAlertView(title: Message.slOtherImageMS ,
                                            message: err.localizedDescription,
                                            cancelButton: "OK")
                    } else {
                        self?.navigationController?.progessAnimation(false)
                        self?.showErrorAlert(errMessage: Message.slOtherImageMS)
                    }
                }
        } else {
            showErrorAlert(errMessage: Message.checkNetworkingMS)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
