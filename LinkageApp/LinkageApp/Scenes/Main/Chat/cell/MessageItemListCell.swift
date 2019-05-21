//
//  RequestTableViewCell.swift
//  LinkageApp
//
//  Created by cuonghx on 5/19/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import Kingfisher

final class MessageItemListCell: UITableViewCell, NibReusable {
    
    // MARK: - Properties
    private var model: MessageItemListModel?
    
    // MARK: - Outlets
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var requestMessageLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    // MARK: - Method
    func setContent(model: MessageItemListModel) {
        self.model = model
        requestMessageLabel.text = model.messagelast.content
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: model.messagelast.date.convertTimeIntervalFromFirebase)
        if calendar.compare(date,
                            to: Date(),
                            toGranularity: .minute) == .orderedSame {
            timeLabel.text = "・\(Title.justNow)"
        } else if calendar.compare(date,
                                   to: Date(),
                                   toGranularity: .day) == .orderedSame {
            timeLabel.text = "・\(date.toString(dateFormat: "HH:mm"))"
        } else {
            timeLabel.text = "・\(date.toString(dateFormat: "MMM dd"))"
        }
        let url = URL(string: model.user.urlImage)
        avatarImageView.kf.setImage(with: url)
        nameLabel.text = model.user.name
    }
}
