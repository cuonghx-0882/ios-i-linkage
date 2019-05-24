//
//  DetailScreenViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/15/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import Kingfisher
import Toaster

final class DetailScreenViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var jobLabel: UILabel!
    @IBOutlet private weak var hobbiesLabel: UILabel!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var genderImageView: UIImageView!
    @IBOutlet private weak var detailView: UIView!
    
    // MARK: - Properties
    var model: User?
    private var startPosition: CGPoint!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    // MARK: - Method
    private func configView() {
        navigationController?.navigationBar.topItem?.title = ButtonTitle.back
        if let model = model {
            title = model.name
            jobLabel.text = model.job.isEmpty ? ""
                : Title.jobTT + "\(model.job)"
            descriptionLabel.text = model.description.isEmpty ? ""
                : Title.descriptionTT + "\(model.description)"
            hobbiesLabel.text = model.hobbies.isEmpty ? ""
                : Title.hobbiesTT + "\(model.hobbies)"
            genderImageView.image = model.isMale ? UIImage(named: "male") :
                UIImage(named: "female")
            let url = URL(string: model.urlImage)
            avatarImageView.kf.setImage(with: url)
            if let age = model.dob.getAgeFromDateString() {
                displayNameLabel.text = String(describing: model.name.byWords.last ?? "" ) + ", \(age)"
            } else {
                displayNameLabel.text = String(describing: model.name.byWords.last ?? "")
            }
            
        }
        if !descriptionLabel.isTruncated,
            !jobLabel.isTruncated ,
            !hobbiesLabel.isTruncated {
            moreButton.isHidden = true
        } else {
            moreButton.isHidden = false
            let panGesture = UIPanGestureRecognizer(target: self,
                                                    action: #selector(handerPanGesture(_:)))
            detailView.addGestureRecognizer(panGesture)
            detailView.isUserInteractionEnabled = true
        }
    }
    
    @objc
    private func handerPanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            startPosition = sender.location(in: detailView)
        }
        if sender.state == .ended || sender.state == .cancelled {
            sender.setTranslation(CGPoint(x: 0.0, y: 0.0), in: self.view)
            let endPosition = sender.location(in: detailView)
            let difference = endPosition.y - startPosition.y
            if difference < -20 {
                changeMaxLineLabel(isShowMore: true)
            } else if difference > 40 {
                changeMaxLineLabel(isShowMore: false)
            }
        }
    }
    
    @IBAction private func handlerClickShowMore(_ sender: UIButton) {
        changeMaxLineLabel(isShowMore: jobLabel.numberOfLines != 0)
    }
       
    @IBAction private func handlerSendMSButton(_ sender: UIButton) {
        showInputDialog(title: Message.sendGRMSTitle,
                        subtitle: Message.sendGreetingMS,
                        actionTitle: ButtonTitle.send,
                        inputPlaceholder: "Aaa") { [weak self](title) in
                            guard let title = title,
                                let strongSelf = self,
                                let auth = AuthManagerLocalDataSource.shared.getUser(),
                                let model = strongSelf.model else {
                                return
                            }
                            if title.isEmpty {
                                strongSelf.showErrorAlert(errMessage: Message.messageEmpty)
                            } else if Connectivity.isConnectedToInternet {
                                FirebaseService.share
                                    .sendMessageRequest(content: title,
                                                        fromID: auth.uid,
                                                        toID: model.uid,
                                                        completion: { err in
                                                            if let err = err {
                                                                Toast(text: err.localizedDescription)
                                                                    .show()
                                                            } else {
                                                                Toast(text: Message.successMS).show()
                                                            }
                                                            strongSelf.navigationController?
                                                                .popViewController(animated: true)
                                })
                            } else {
                               strongSelf.showErrorAlert(errMessage: Message.checkNetworkingMS)
                            }
        }
    }
    
    private func changeMaxLineLabel (isShowMore: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.jobLabel.numberOfLines = isShowMore ? 0 : 1
            self.hobbiesLabel.numberOfLines = isShowMore ? 0 : 1
            self.descriptionLabel.numberOfLines = isShowMore ? 0 : 1
        }
    }
}

// MARK: - StoryboardSceneBased
extension DetailScreenViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.detail
}
