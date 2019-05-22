//
//  NavigationController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/6/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

final class NavigationController: UINavigationController {
    
    // MARK: - Properties
    
    // MARK: - Life Cycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    // MARK: - Method
    private func config() {
        if AuthManagerLocalDataSource.shared.getUser() != nil {
            handlerGotoMainScreen()
        } else {
            let loginScreen = LoginViewController.instantiate()
            viewControllers = [loginScreen]
        }
    }
    
    func handlerGotoMainScreen() {
        guard let user = AuthManagerLocalDataSource.shared.getUser() else {
            showAlertView(title: Message.errorWithAccountMS,
                          message: Message.contactToOurMS,
                          cancelButton: "OK")
            return
        }
        if user.urlImage.isEmpty {
            pushViewController(RegisterUploadImageViewController.instantiate(), animated: false)
        } else {
            viewControllers = [MainTabBarViewController.instantiate()]
        }
    }
}
