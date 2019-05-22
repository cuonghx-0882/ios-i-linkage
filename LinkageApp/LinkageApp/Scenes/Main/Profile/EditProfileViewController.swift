//
//  EditProfileViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/20/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import KUIPopOver
import Toaster

protocol EditProfileViewControllerDelegate: class {
    func onCompletion(error: Error?)
}

final class EditProfileViewController: BaseViewController {

    // MARK: - Outlet
    @IBOutlet private weak var contentTextView: UITextView!
    
    // MARK: - Properties
    var idEdit: Int?
    weak var delegate: EditProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configView()
    }
    
    private func configView() {
        contentTextView.becomeFirstResponder()
        hideKeyboardWhenTappedAround()
        if let auth = AuthManagerLocalDataSource.shared.getUser(),
            let idEdit = idEdit {
            switch idEdit {
            case 1:
                title = "Edit Job"
                contentTextView.text = auth.job
            case 2:
                title = "Edit Hobbies"
                contentTextView.text = auth.hobbies
            case 3:
                contentTextView.text = auth.description
                title = "Edit Descrpiption"
            default:
                title = ""
                contentTextView.text = ""
            }
        }
    }
    
    @IBAction func handlerSaveButton(_ sender: UIButton) {
        guard var auth = AuthManagerLocalDataSource.shared.getUser(),
            let idEdit = idEdit else {
                return
        }
        var key = ""
        switch idEdit {
        case 1:
            key = "job"
            auth.job = contentTextView.text
        case 2:
            key = "hobbies"
            auth.hobbies = contentTextView.text
        case 3:
            key = "description"
            auth.description = contentTextView.text
        default:
            return
        }
        
        if Connectivity.isConnectedToInternet {
            FirebaseService.share
                .updateProfileforKey(userID: auth.uid,
                                     key: key,
                                     value: contentTextView.text) {[weak self] (err) in
                                        if let err = err {
                                            self?.delegate?.onCompletion(error: err)
                                        } else {
                                            AuthManagerLocalDataSource.shared.saveUser(user: auth)
                                            self?.dismissPopover(animated: true,
                                                                 completion: {
                                                self?.delegate?.onCompletion(error: nil)
                                            })
                                        }
                }
        } else {
            dismissPopover(animated: true) {
                Toast(text: Message.checkNetworkingMS).show()
            }
        }
    }
    @IBAction func handlerCancelButton(_ sender: UIButton) {
        dismissPopover(animated: true)
    }
}

extension EditProfileViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

extension EditProfileViewController: KUIPopOverUsable {
    var contentSize: CGSize {
        return preferredContentSize
    }
}
