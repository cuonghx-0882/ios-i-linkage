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
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var logoImageView: UIImageView!
    
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    // MARK: - Method
    private func configView() {
        hideKeyboardWhenTappedAround()
        animationLogo()
    }
    private func animationLogo() {
        logoImageView.alpha = 0
        let lgImageTmp = UIImageView().then {
            $0.frame.size = CGSize(width: 100, height: 100)
            $0.center = view.center
            $0.image = UIImage(named: "logo")
        }
        view.addSubview(lgImageTmp)
        UIView.animate(withDuration: 0.5,
                       animations: {
                        lgImageTmp.center = CGPoint(x: self.view.center.x,
                                                    y: self.logoImageView.center.y + 20)
        }, completion: { _ in
            self.logoImageView.alpha = 1
            lgImageTmp.removeFromSuperview()
        })
    }
    
    @IBAction private func handlerLoginButton(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        if !Validation.isValidateEmail(email: email) {
            showAlertView(title: Message.emailNotValidMS,
                          message: Message.enterValidEmailMS,
                          cancelButton: "Ok")
            return
        }
        progessAnimation(true)
        UserRepository.shared.signIn(email: email, password: password) { (user, err) in
            self.progessAnimation(false )
            if let err = err {
                if let errCode = AuthErrorCode(rawValue: err._code) {
                    switch errCode {
                    case AuthErrorCode.networkError :
                        self.showErrorAlert(errMessage: Message.checkNetworkingMS)
                    case AuthErrorCode.wrongPassword :
                        self.showErrorAlert(errMessage: Message.invalidEmailOrPasswordMS)
                    case AuthErrorCode.userNotFound :
                        self.showErrorAlert(errMessage: Message.userNotFoundMS)
                    default :
                        self.showErrorAlert(errMessage: err.localizedDescription)
                    }
                }
            } else {
                if let user = user {
                    AuthManagerLocalDataSource.shared.saveUser(user: user)
                } else {
                    self.showAlertView(title: Message.errorWithAccountMS,
                                       message: Message.contactToOurMS,
                                       cancelButton: "Yes")
                }
            }
        }
    }
    
    @IBAction private func handlerForgotButton(_ sender: UIButton) {
        showInputDialog(title: Message.enterEmailMS,
                        actionTitle: "Send",
                        inputKeyboardType: .emailAddress) { [unowned self] (email) in
                            guard let email = email, Validation.isValidateEmail(email: email) else {
                                self.showErrorAlert(errMessage: Message.emailNotValidMS)
                                return
                            }
                            UserRepository.shared.forgot(email: email, completion: { (err) in
                                if let err = err {
                                    self.navigationController?.showErrorAlert(errMessage: err.localizedDescription)
                                    return
                                }
                                self.navigationController?.showAlertView(title: Message.successMS,
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
}
