//
//  FilterPopup.swift
//  LinkageApp
//
//  Created by cuonghx on 5/13/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import KUIPopOver

protocol FilterPopupDelegate: class {
    func handlerFilterButton(filterPopup: FilterPopup, filter: Filter)
    func handlerClearButton(filterPopup: FilterPopup)
}

final class FilterPopup: UIView, NibOwnerLoadable, KUIPopOverUsable {
   
    // MARK: - Properties
    weak var delegate: FilterPopupDelegate?
    
    // MARK: - Outlets
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
    
    func setupPopUp(filter: Filter?) {
        if let filter = filter {
            genderSegmentControl.selectedSegmentIndex = filter.gender
            distanceFromTextField.text = filter.distanceFrom
            distanceToTextField.text = filter.distanceTo
            ageFromTextField.text = filter.ageFrom
            ageToTextField.text = filter.ageTo
        }
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
                                gender: genderSegmentControl.selectedSegmentIndex)
            delegate?.handlerFilterButton(filterPopup: self, filter: filter)
        }
    }
    
    @IBAction private func clearFilter(_ sender: UIButton) {
        delegate?.handlerClearButton(filterPopup: self)
    }
}
