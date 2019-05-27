//
//  ChatViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/18/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import MessengerKit
import FirebaseDatabase

final class ChatViewController: MSGMessengerViewController {
    
    // MARK: - Properties
    private lazy var messages = [[MSGMessage]]()
    var model: MessageItemListModel?
    private var messageID = 0
    private var endOfListMessage = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    deinit {
        logDeinit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let button = UIButton(type: .system).then {
            $0.setTitle(model?.user.name, for: .normal)
            $0.addTarget(self,
                         action: #selector(handlerProfileButton),
                         for: .touchUpInside)
            $0.tintColor = UIColor.black
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17,
                                                    weight: .bold)
        }
        navigationItem.titleView = button
    }
    
    // MARK: - Method
    private func configView() {
        delegate = self
        dataSource = self
        loadData(scrollBottom: true,
                 fromDate: Date().timeIntervalSince1970.convertToTimeIntervalFirebase)
        guard let model = model else {
            return
        }
        FirebaseService.share
            .listenMessage(messageID: model.messageModel.id) {[weak self] (err, mess) in
                guard let auth = AuthManagerLocalDataSource.shared.getUser() else {
                        return
                }
                self?.messageID += 1
                if let mess = mess,
                    let messageID = self?.messageID {
                    let isSender = auth.uid == mess.fromID
                    let sentAt = Date(timeIntervalSince1970: mess.date.convertTimeIntervalFromFirebase)
                    self?.insert(MSGMessage(id: messageID,
                                            body: mess.content.convertMSBody,
                                            user: UserChat(displayName: mess.fromID,
                                                           isSender: isSender),
                                                 sentAt: sentAt))
                } else if let err = err {
                    self?.showErrorAlert(errMessage: err.localizedDescription)
                }
            }
    }
    
    @objc
    private func handlerProfileButton() {
        let detailVC = DetailScreenViewController.instantiate().then {
            $0.model = model?.user
        }
        navigationController?.pushViewController(detailVC,
                                                 animated: true)
    }
    
    private func loadData(scrollBottom: Bool, fromDate: Double, numberLimited: UInt = 8) {
        guard let messageID = model?.messageModel.id else {
            return
        }
        FirebaseService.share
            .getMessagePaging(messageID: messageID,
                              fromDate: fromDate,
                              numberLimited: numberLimited) { [weak self] (listMessage, err) in
                                guard let strongSelf = self,
                                    let auth = AuthManagerLocalDataSource.shared.getUser() else {
                                        return
                                }
                                if let err = err {
                                    strongSelf.showErrorAlert(errMessage: err.localizedDescription)
                                } else {
                                    strongSelf.insert(listMessage.map({ (item) -> MSGMessage in
                                        let isSender = auth.uid == item.fromID
                                        let sentAt = Date(timeIntervalSince1970: item.date
                                            .convertTimeIntervalFromFirebase)
                                        strongSelf.messageID += 1
                                        return MSGMessage(id: strongSelf.messageID,
                                                          body: item.content.convertMSBody,
                                                          user: UserChat(displayName: item.fromID,
                                                                         isSender: isSender),
                                                          sentAt: sentAt)
                                    }), scrollbottom: scrollBottom)
                                }
            }
    }
}

// MARK: - MSGMessengerViewController
extension ChatViewController {
    override func inputViewPrimaryActionTriggered(inputView: MSGInputView) {
        guard let auth = AuthManagerLocalDataSource.shared.getUser(),
            let model = model else {
            return
        }
        FirebaseService.share.sendMessage(content: inputView.message,
                                          messeageID: model.messageModel.id,
                                          fromID: auth.uid) {[weak self] (err) in
                                            if let err = err {
                                                self?.showErrorAlert(errMessage: err.localizedDescription)
                                            }
        }
    }
    
    override func insert(_ message: MSGMessage) {
        collectionView.performBatchUpdates({
            if let lastSection = self.messages.last,
                let lastMessage = lastSection.last,
                lastMessage.user.displayName == message.user.displayName {
                self.messages[self.messages.count - 1].append(message)
                let sectionIndex = self.messages.count - 1
                let itemIndex = self.messages[sectionIndex].count - 1
                self.collectionView.insertItems(at: [IndexPath(item: itemIndex,
                                                               section: sectionIndex)])
            } else {
                self.messages.append([message])
                let sectionIndex = self.messages.count - 1
                self.collectionView.insertSections([sectionIndex])
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: true)
            self.collectionView.layoutTypingLabelIfNeeded()
        })
    }
    
    func insert(_ messages: [MSGMessage], scrollbottom: Bool) {
        let initialOffset = collectionView.contentOffset.y
        var section = 0
        var item = 0
        for message in messages.reversed() {
            if let firstSection = self.messages.first,
                let firstMessage = firstSection.first,
                firstMessage.user.displayName == message.user.displayName {
                self.messages[0].insert(message, at: 0)
                item += section == 0 ? 1 : 0
            } else {
                section += 1
                self.messages.insert([message], at: 0)
            }
        }
        self.collectionView.reloadData()
        if scrollbottom {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.collectionView.scrollToBottom()
            }
            collectionView.layoutTypingLabelIfNeeded()
        } else if !messages.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: item,
                                                      section: section),
                                             at: .top,
                                             animated: false)
            collectionView.contentOffset.y += initialOffset
        } else {
            endOfListMessage = !endOfListMessage
        }
    }
}

// MARK: - MSGDelegate
extension ChatViewController: MSGDelegate {
    
}

// MARK: - CollectionViewDelegate
extension ChatViewController {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.section == 0,
            indexPath.item == 0,
            !endOfListMessage {
            loadData(scrollBottom: false,
                     fromDate: messages[0][0].sentAt.timeIntervalSince1970
                        .convertToTimeIntervalFirebase - 1,
                     numberLimited: 10)
        }
    }
}

// MARK: - MSGDataSource
extension ChatViewController: MSGDataSource {
    func numberOfSections() -> Int {
        return messages.count
    }
    
    func numberOfMessages(in section: Int) -> Int {
        return messages[section].count
    }
    
    func message(for indexPath: IndexPath) -> MSGMessage {
        return messages[indexPath.section][indexPath.item]
    }
    
    func footerTitle(for section: Int) -> String? {
        guard let lastMessage = messages[section].last else {
            return nil
        }
        
        let calendar = Calendar.current
        if calendar.compare(lastMessage.sentAt,
                            to: Date(),
                            toGranularity: .minute) == .orderedSame {
            return Title.justNow
        } else if calendar.compare(lastMessage.sentAt,
                                   to: Date(),
                                   toGranularity: .year) == .orderedSame {
             return lastMessage.sentAt.toString(dateFormat: "HH:mm, MMM dd")
        } else {
             return lastMessage.sentAt.toString(dateFormat: "HH:mm, dd/MM/yyyy")
        }
    }
    
    func headerTitle(for section: Int) -> String? {
        return nil
    }
    
}

