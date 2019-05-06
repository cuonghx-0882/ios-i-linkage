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
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    
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
    @IBAction func handlerLoginButton(_ sender: UIButton) {
        guard let email = emailTF.text, let password = passwordTF.text else {
            return
        }
        if !email.isValidateEmail() {
            self.showAlertView(title: "This email address is not valid. ",
                               message: "Please enter a valid address.",
                               cancelButton: "Ok")
            return
        }
        progessAnimation(true)
        Auth.auth().signIn(withEmail: email, password: password) {[unowned self] (result, err) in
            self.progessAnimation(false)
            if let err = err {
                if let errCode = AuthErrorCode(rawValue: err._code) {
                    switch errCode {
                    case AuthErrorCode.networkError :
                        self.showErrorAlert(message: "Please check your internet connection")
                    case AuthErrorCode.wrongPassword :
                        print("wrong:")
                    default :
                        print("other")
                    }
                }
            } else {
//                print(result?.user.uid)
            }
        }
    }
    @IBAction func handlerForgotButton(_ sender: UIButton) {
    }
    @IBAction func handlerSignUpButton(_ sender: UIButton) {
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
