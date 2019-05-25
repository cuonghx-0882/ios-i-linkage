//
//  FilterFaceNetPopup.swift
//  LinkageApp
//
//  Created by cuonghx on 5/26/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import KUIPopOver

protocol FilterFacenetDelegate: class {
    func handlerFilterButton(filterPopup: FilterFaceNetPopup?, filter: Filter)
    func handlerClearButton(filterPopup: FilterFaceNetPopup)
}

final class FilterFaceNetPopup: UIView, NibOwnerLoadable, KUIPopOverUsable {
    // MARK: - Properties
    weak var delegate: FilterFacenetDelegate?
    
//    // MARK: - Outlets
    @IBOutlet private weak var genderSegmentControl: UISegmentedControl!
    @IBOutlet private weak var ageFromTextField: UITextField!
    @IBOutlet private weak var ageToTextField: UITextField!
    @IBOutlet private weak var distanceFromTextField: UITextField!
    @IBOutlet private weak var distanceToTextField: UITextField!
    
    // MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
    }
    
    // MARK: - Method
    @IBAction private func handlerCancelButton(_ sender: UIButton) {
        dismissPopover(animated: true)
    }
    
    func clearFilter() {
        genderSegmentControl.selectedSegmentIndex = 0
        distanceFromTextField.text = ""
        distanceToTextField.text = ""
        ageFromTextField.text = ""
        ageToTextField.text = ""
    }
    
    @IBAction private func handlerFilterButton(_ sender: UIButton) {
        if let ageFrom = ageFromTextField.text,
            let ageTo = ageToTextField.text,
            let distanceFrom = distanceFromTextField.text,
            let distanceTo = distanceToTextField.text {
            let filter = Filter(ageFrom: ageFrom,
                                ageTo: ageTo,
                                distanceFrom: distanceFrom,
                                distanceTo: distanceTo,
                                gender: genderSegmentControl.selectedSegmentIndex,
                                enable100km: true)
            delegate?.handlerFilterButton(filterPopup: self, filter: filter)
        }
    }
    
    @IBAction private func clearFilter(_ sender: UIButton) {
        clearFilter()
        delegate?.handlerClearButton(filterPopup: self)
    }
}
