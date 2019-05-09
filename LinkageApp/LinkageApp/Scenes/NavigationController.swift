//
//  NavigationController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/6/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

final class NavigationController: UINavigationController {
    
    // MARK: - Properties
    static let KeyNotificationMain = "GotoMainScreen"
    
    // MARK: - Life Cycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    deinit {
        logDeinit()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Method
    private func config() {
        let notificationName = NSNotification.Name(NavigationController.KeyNotificationMain)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlerGotoMainScreen),
                                               name: notificationName,
                                               object: nil)
        if AuthManagerLocalDataSource.shared.getUser() != nil {
            handlerGotoMainScreen()
        } else {
            let loginScreen = LoginViewController.instantiate()
            viewControllers = [loginScreen]
        }
    }
    
    @objc
    func handlerGotoMainScreen() {
        guard let user = AuthManagerLocalDataSource.shared.getUser() else {
            showAlertView(title: Message.errorWithAccountMS,
                          message: Message.contactToOurMS,
                          cancelButton: "OK")
            return
        }
        if user.urlImage.isEmpty {
            viewControllers = [RegisterUploadImageViewController.instantiate()]
        } else {
            viewControllers = []
        }
    }
}
