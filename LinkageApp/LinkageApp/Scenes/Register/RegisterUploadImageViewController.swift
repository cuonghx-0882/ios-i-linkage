//
//  RegisterUploadImageViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/7/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ImagePicker

final class RegisterUploadImageViewController: BaseViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var hobbiesTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    // MARK: - Method
    private func configView() {
        hideKeyboardWhenTappedAround()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handlerTapImage))
        avatarImageView.do {
            $0.addGestureRecognizer(gesture)
            $0.isUserInteractionEnabled = true
        }
    }
    
    @objc
    private func handlerTapImage() {
        let imagePickerController = ImagePickerController().then {
            $0.imageLimit = 1
            $0.delegate = self
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func handlerContinueButton(_ sender: UIButton) {
        if var user = AuthManagerLocalDataSource.shared.getUser(),
            !user.urlImage.isEmpty {
            user.description = descriptionTextField.text ?? ""
            user.job = jobTextField.text ?? ""
            user.hobbies = hobbiesTextField.text ?? ""
            progessAnimation(true)
            FirebaseService.share.saveUser(user: user) { (err) in
                self.progessAnimation(false)
                if let err = err {
                    self.showErrorAlert(errMessage: err.localizedDescription)
                } else {
                    AuthManagerLocalDataSource.shared.saveUser(user: user)
                    let notificationName = Notification.Name(NavigationController.KeyNotificationMain)
                    NotificationCenter.default.post(name: notificationName, object: nil)
                }
            }
        } else {
            showErrorAlert(errMessage: Message.slAnImageMS)
        }
    }
    
    private func handlerUploadImage(_ url: URL?, _ err: Error?) {
        if let url = url,
            var user = AuthManagerLocalDataSource.shared.getUser() {
            user.urlImage = url.absoluteString
            FirebaseService.share.saveUser(user: user, completion: { (err) in
                self.progessAnimation(false)
                if let err = err {
                    self.showAlertView(title: Message.slOtherImageMS ,
                                       message: err.localizedDescription,
                                       cancelButton: "OK")
                } else {
                    AuthManagerLocalDataSource.shared.saveUser(user: user)
                }
            })
            
        } else if let err = err {
            self.progessAnimation(false)
            self.showAlertView(title: Message.slOtherImageMS ,
                               message: err.localizedDescription,
                               cancelButton: "OK")
        } else {
            self.progessAnimation(false)
            self.showErrorAlert(errMessage: Message.slOtherImageMS)
        }
    }
}

// MARK: - StoryboardSceneBased
extension RegisterUploadImageViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.login
}

// MARK: - ImagePickerDelegate
extension RegisterUploadImageViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {}
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first,
            let uid = AuthManagerLocalDataSource.shared.getUser()?.uid else {
            return
        }
        progessAnimation(true)
        FirebaseStoreageService.shared.uploadImage(image: image,
                                                   path: "\(uid)/avatarImage.jpeg",
                                                   completion: self.handlerUploadImage(_:_:))
        avatarImageView.image = images.first
        avatarImageView.clipsToBounds = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
