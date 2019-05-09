//
//  RegisterViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/7/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

final class RegisterViewController: BaseViewController {
    
    // MARK: - IBOutLets
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var dobTextField: UITextField!
    @IBOutlet private weak var genderSegment: UISegmentedControl!
    
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    // MARK: - Method
    private func configView() {
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func handlerRegisterButton(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text,
            let name = nameTextField.text,
            let dob = dobTextField.text else {
            return
        }
        if !checkValidate(email: email,
                          password: password,
                          confirmPassword: confirmPassword,
                          name: name,
                          dob: dob) {
            return
        }
        let gender = self.genderSegment.selectedSegmentIndex == 1 ? true : false
        progessAnimation(true)
        UserRepository.shared.signUp(email: email,
                                     password: password,
                                     name: name,
                                     dob: dob,
                                     gender: gender) { (user, err) in
                                        self.progessAnimation(false)
                                        if let err = err {
                                            self.showErrorAlert(errMessage: err.localizedDescription)
                                        } else if let user = user {
                                            AuthManagerLocalDataSource.shared.saveUser(user: user)
                                            let nName = Notification.Name(NavigationController.KeyNotificationMain)
                                            NotificationCenter.default.post(name: nName, object: nil)
                                        } else {
                                            self.showErrorAlert(errMessage: Message.contactToOurMS)
                                        }
        }
    }
        
    private func checkValidate(email: String,
                               password: String,
                               confirmPassword: String,
                               name: String,
                               dob: String) -> Bool {
        if email.isEmpty {
            showErrorAlert(errMessage: Message.emailFieldNullMS)
            return false
        }
        if !Validation.isValidateEmail(email: email) {
            showErrorAlert(errMessage: Message.emailNotValidMS)
            return false
        }
        if password.isEmpty {
            showErrorAlert(errMessage: Message.passwordEmptyMS)
            return false
        }
        if confirmPassword != password {
            showErrorAlert(errMessage: Message.confirmPasswordNotMatchMS)
            return false
        }
        if name.isEmpty {
            showErrorAlert(errMessage: Message.nameFieldNullMS)
            return false
        }
        if dob.isEmpty {
            showErrorAlert(errMessage: Message.dobFieldNullMS)
            return false
        }
        if !Validation.isValidateDate(date: dob) {
            showErrorAlert(errMessage: Message.dobFieldNotValid)
            return false
        }
        
        return true
    }
    
    @IBAction func handlerSignInButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
}

// MARK: - StoryboardSceneBased
extension RegisterViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.login
}

// MARK: - TextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
