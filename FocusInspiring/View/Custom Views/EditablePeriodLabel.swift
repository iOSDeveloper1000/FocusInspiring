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

    /**
     Customized input view for the label.
     */
    private var responsiveInputView: ResponsiveSelectorView = {
        ResponsiveSelectorView(frame: CGRect(origin: .zero, size: CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)))
    }()

    override var inputView: UIView { responsiveInputView }

    /**
     Text field integrated in the input accessory view.
     */
    private var accessoryTextField: UITextField!

    override var inputAccessoryView: UIToolbar {
        // Setup text field at first use
        if accessoryTextField == nil {
            accessoryTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
            accessoryTextField.adjustsFontForContentSizeCategory = true
            accessoryTextField.textAlignment = .center
            accessoryTextField.placeholder = " Tap to select a time period.  "
            accessoryTextField.borderStyle = .none
            accessoryTextField.backgroundColor = .systemBackground
        }
        responsiveInputView.updateTextFieldTextBy = { self.accessoryTextField?.text = $0 }

        // Make toolbar for resigning from first responder
        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        accessory.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(inputCancelled(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(inputConfirmed(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let textFieldItem = UIBarButtonItem(customView: accessoryTextField)

        accessory.items = [cancelButton, flexSpace, textFieldItem, flexSpace, doneButton]

        return accessory
    }

    override var canBecomeFirstResponder: Bool { true }

    /**
     Callback method called with user confirming his input.

     To be set by the view controller in the setup process.
     */
    var onValueConfirm: ((ConvertibleTimeComponent) -> Void)?


    // MARK: - Actions

    @IBAction func inputConfirmed(_ sender: UIBarButtonItem) {
        resignFirstResponder()

        onValueConfirm?(responsiveInputView.convertedData)

        let rawString = responsiveInputView.printedRawInput

        text = rawString.contains("?") ? TextParameter.nilPeriod : rawString
    }

    @IBAction func inputCancelled(_ sender: UIBarButtonItem) {
        resignFirstResponder()
    }

    /**
     Clears the text field of the input view.
     */
    public func clearInputField() {
        responsiveInputView.clearInput()
    }
}
