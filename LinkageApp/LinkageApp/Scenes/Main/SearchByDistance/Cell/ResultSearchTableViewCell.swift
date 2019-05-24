//
//  SearchByDistanceTableViewCell.swift
//  LinkageApp
//
//  Created by cuonghx on 5/10/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import Kingfisher

final class ResultSearchTableViewCell: UITableViewCell, NibReusable {

    // MARK: - IBOutlets
    @IBOutlet private weak var genderImageView: UIImageView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    // MARK: - Method
    func setContent(model: ModelCellResult) {
        distanceLabel.text = String(format: "Distance: %.1fkm", model.location.distance.tokm)
        nameLabel.text = model.user.name
        genderImageView.image = model.user.isMale ? UIImage(named: "male") :
            UIImage(named: "female")
        let url = URL(string: model.user.urlImage)
        avatarImageView.kf.setImage(with: url)
        if let age = model.user.dob.getAgeFromDateString() {
            ageLabel.text = "Age: \(age)"
        } else {
            ageLabel.text = ""
        }
    }
}
