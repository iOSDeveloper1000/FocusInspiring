//
//  PickerTextField.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 17.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


/// Text field that uses a customizable UIPickerView as input view
class PickerTextField: UITextField, UITextFieldDelegate {

    // MARK: Properties

    /// Associated picker view
    var inputPicker: UIPickerView!

    /// Data source for the picker view
    var pickerSource: PickerData!

    /// Buffers the selected rows when user starts editing in order to reset to these values if user cancels his input
    private var initialRowsBuffer: [Int] = []


    // MARK: Public Interface

    func setup(with data: PickerData) {

        delegate = self

        /// Use standard UIPickerView with customizable datasource as input view
        inputPicker = UIPickerView()
        pickerSource = data

        inputPicker.delegate = pickerSource
        inputPicker.dataSource = pickerSource

        inputPicker.backgroundColor = .lightGray

        /// Link textfield input view to the picker
        inputView = inputPicker
        inputAccessoryView = createAccessoryView()

        /// Update picker initial selection and displayed text by saved selection
        inputPicker.selectRows(pickerSource.retrieveSelection())
        updateText()
    }

    /// Updates the displayed text
    func updateText() {
        let selection = inputPicker.selectedRows()

        text = pickerSource.textBy(selected: selection)
    }


    // MARK: Actions

    @IBAction func cancelPressed(_ sender: UIBarButtonItem?) {
        resignFirstResponder()

        /// Reset row selection to previous state
        inputPicker.selectRows(initialRowsBuffer)
    }

    @IBAction func donePressed(_ sender: UIBarButtonItem?) {
        resignFirstResponder()

        let selection = inputPicker.selectedRows()

        /// Update displayed text and save selected rows
        text = pickerSource.textBy(selected: selection)
        pickerSource.saveSelection(given: selection)
    }


    // MARK: Helper

    private func createAccessoryView() -> UIToolbar {
        /// Make toolbar for leaving the pickerview
        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        accessory.items = [cancelButton, flexSpace, doneButton]

        return accessory
    }


    // MARK: TextField Delegation

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        inputPicker.reloadAllComponents()

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// Reset to these values in case user cancels
        initialRowsBuffer = inputPicker.selectedRows()
    }
}
