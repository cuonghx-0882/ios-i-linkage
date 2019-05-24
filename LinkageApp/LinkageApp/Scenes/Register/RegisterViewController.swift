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
    }
    
    // MARK: - Method
    private func configView() {
        hideKeyboardWhenTappedAround()
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
        dobTextField.do {
            $0.inputAccessoryView = toolbar
            $0.inputView = datePicker
        }
    }
    
    @objc
    private func donedatePicker() {
        dobTextField.text = datePicker.date.toString(dateFormat: "dd/MM/yyyy")
        view.endEditing(true)
    }
    
    @objc
    func canceldatePicker() {
        view.endEditing(true)
    }
    
    @IBAction func handlerRegisterButton(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text,
            let name = nameTextField.text,
            let dob = dobTextField.text else {
            return
        }
        if !Validation.checkValidateSignIn(email: email,
                                           password: password,
                                           confirmPassword: confirmPassword,
                                           name: name,
                                           dob: dob) {
            return
        }
        let isMale = self.genderSegment.selectedSegmentIndex == 0 
        progessAnimation(true)
        UserRepository.shared.signUp(email: email,
                                     password: password,
                                     name: name,
                                     dob: dob,
                                     isMale: isMale) {[weak self] (user, err) in
                                        self?.progessAnimation(false)
                                        if let err = err {
                                            self?.showErrorAlert(errMessage: err.localizedDescription)
                                        } else if let user = user,
                                            let nav = self?.navigationController as? NavigationController {
                                            AuthManagerLocalDataSource.shared.saveUser(user: user)
                                            nav.handlerGotoMainScreen()
                                        } else {
                                            self?.showErrorAlert(errMessage: Message.contactToOurMS)
                                        }
        }
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
