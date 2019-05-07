//
//  LoginViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/5/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import FirebaseAuth

final class LoginViewController: BaseViewController {
    
    // MARK: - IBOutLets
    @IBOutlet private weak var emailTF: UITextField!
    @IBOutlet private weak var passwordTF: UITextField!
    @IBOutlet private weak var logoImage: UIImageView!
    
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    // MARK: - Method
    private func configView() {
        hideKeyboardWhenTappedAround()
        emailTF.delegate = self
        passwordTF.delegate = self
        //Animation Logo
        logoImage.alpha = 0
        let lgImageTmp = UIImageView().then {
            $0.frame.size = CGSize(width: 100, height: 100)
            $0.center = view.center
            $0.image = UIImage(named: "logo")
        }
        view.addSubview(lgImageTmp)
        UIView.animate(withDuration: 0.5,
                       animations: {
            lgImageTmp.center = CGPoint(x: self.view.center.x,
                                        y: self.logoImage.center.y + 20)
        }, completion: { _ in
            self.logoImage.alpha = 1
            lgImageTmp.removeFromSuperview()
        })
    }
    
    @IBAction private func handlerLoginButton(_ sender: UIButton) {
        guard let email = emailTF.text,
            let password = passwordTF.text else { return }
        
        if !email.isValidateEmail() {
            self.showAlertView(title: Message.emailNotValidMS,
                               message: Message.enterValidEmailMS,
                               cancelButton: "Ok")
            return
        }
        progessAnimation(true)
        Auth.auth().signIn(withEmail: email, password: password) {(result, err) in
            self.progessAnimation(false)
            guard let nav = self.navigationController as? BaseNavigationController else {
                return
            }
            if let err = err {
                if let errCode = AuthErrorCode(rawValue: err._code) {
                    switch errCode {
                    case AuthErrorCode.networkError :
                        nav.showErrorAlert(message: Message.checkNetworkingMS)
                    case AuthErrorCode.wrongPassword :
                        nav.showErrorAlert(message: Message.invalidEmailOrPasswordMS)
                    default :
                        nav.showErrorAlert(message: err.localizedDescription)
                    }
                }
            } else {
                if let uid = result?.user.uid {
                    FirebaseService.share.getUserFromUID(uid: uid, completion: { (user, err) in
                        if let err = err {
                            nav.showErrorAlert(message: err.localizedDescription)
                        } else {
                            if let user = user {
                                print("ok")
                                AuthenticationLocalDataSourceIml.sharedInstance.saveUser(user: user)
                            } else {
                                nav.showAlertView(title: Message.errorWithAccountMS,
                                                  message: Message.contactToOurMS,
                                                  cancelButton: "Yes")
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction private func handlerForgotButton(_ sender: UIButton) {
        showInputDialog(title: Message.enterEmailMS,
                        subtitle: "",
                        actionTitle: "OK",
                        cancelTitle: "Cancel",
                        inputPlaceholder: nil,
                        inputKeyboardType: .emailAddress,
                        cancelHandler: nil) { [unowned self] (email) in
                            guard let email = email, email.isValidateEmail() else {
                                self.showErrorAlert(message: Message.emailNotValidMS)
                                return
                            }
                            Auth.auth().sendPasswordReset(withEmail: email, completion: { (err) in
                                guard let nav = self.navigationController as? BaseNavigationController else {
                                    return
                                }
                                if let err = err {
                                    nav.showErrorAlert(message: err.localizedDescription)
                                    return
                                }
                                nav.showAlertView(title: Message.successMS,
                                                  message: Message.checkYEmailMS,
                                                  cancelButton: "OK")
                            })
        }
    }
    
    @IBAction private func handlerSignUpButton(_ sender: UIButton) {
    }
}

// MARK: - TextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - StoryboardSceneBased
extension LoginViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.login
    static var sceneIdentifier = "LoginVC"
}
