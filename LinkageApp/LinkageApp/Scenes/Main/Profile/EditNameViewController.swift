//
//  EditNameViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/23/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import KUIPopOver
import Toaster

final class EditNameViewController: BaseViewController {

    // MARK: - Outlet
    @IBOutlet private weak var genderSegment: UISegmentedControl!
    @IBOutlet private weak var nameTextView: UITextView!
    
    // MARK: - Propeties
    weak var delegate: EditProfileViewControllerDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TitleScreen.edit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingContent()
    }
    
    // MARK: - Method
    private func settingContent() {
        nameTextView.becomeFirstResponder()
        guard let auth = AuthManagerLocalDataSource.shared.getUser() else {
            return
        }
        nameTextView.text = auth.name
        genderSegment.selectedSegmentIndex = auth.isMale ? 0 : 1
    }
    
    @IBAction func handleSaveButton(_ sender: UIButton) {
        guard var auth = AuthManagerLocalDataSource.shared.getUser() else {
            return
        }
        if Connectivity.isConnectedToInternet {
            auth.name = nameTextView.text
            auth.isMale = genderSegment.selectedSegmentIndex == 0 
            FirebaseService.share.saveUser(user: auth) {[weak self] (err) in
                self?.dismissPopover(animated: true)
                if let err = err {
                    self?.delegate?.onCompletion(error: err)
                } else {
                    AuthManagerLocalDataSource.shared.saveUser(user: auth)
                    self?.delegate?.onCompletion(error: nil)
                }
            }
        } else {
            dismissPopover(animated: true) {
                Toast(text: Message.checkNetworkingMS).show()
            }
        }
    }
    
    @IBAction func handleCancelButton(_ sender: UIButton) {
        dismissPopover(animated: true)
    }
}

extension EditNameViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

extension EditNameViewController: KUIPopOverUsable {
    var contentSize: CGSize {
        return preferredContentSize
    }
}
