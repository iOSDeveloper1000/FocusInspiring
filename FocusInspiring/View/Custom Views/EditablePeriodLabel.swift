//
//  EditablePeriodLabel.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 30.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: EditablePeriodLabel: UILabel

class EditablePeriodLabel: UILabel {

    // MARK: - Properties

    /// Used as specific input view (with a default object)
    private lazy var responsiveInputView: ResponsiveSelectorView = {
        ResponsiveSelectorView(frame: CGRect(origin: .zero, size: CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)))
    }()

    override var inputView: UIView { responsiveInputView }

    override var inputAccessoryView: UIToolbar {
        // Make toolbar for resigning from first responder
        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(inputCancelled(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(inputConfirmed(_:)))
        // @todo REDESIGN VIEW: INTEGRATE TEXTFIELD INTO ACCESSORY
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        accessory.items = [cancelButton, flexSpace, doneButton]

        return accessory
    }

    override var canBecomeFirstResponder: Bool { true }

    /// Called when user confirms his input; set by viewcontroller.
    var onValueConfirm: ((ConvertibleTimeComponent?) -> Void)?


    // MARK: - Actions

    @IBAction func inputConfirmed(_ sender: UIBarButtonItem?) {
        resignFirstResponder()

        onValueConfirm?(responsiveInputView.convertedData)

        text = responsiveInputView.printedUserInput
    }

    @IBAction func inputCancelled(_ sender: UIBarButtonItem?) {
        resignFirstResponder()
    }

    /// Clears the textfield of the input view
    public func clearInputField() {
        responsiveInputView.clearInput()
    }
}