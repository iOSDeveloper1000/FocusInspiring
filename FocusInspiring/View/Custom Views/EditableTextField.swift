//
//  EditableTextField.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 10.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: EditableTextField: UITextField, UITextFieldDelegate

class EditableTextField: UITextField, UITextFieldDelegate {

    /// Set by caller of this class to save contents at certain points
    var saveContentChanges: ((String) -> Void)?


    // MARK: Public Interface

    public func setUpCustomTextField(with initText: String?, saveRoutine: ((String) -> Void)?) {
        delegate = self

        saveContentChanges = saveRoutine

        text = initText ?? ""
    }

    public func clearTextField() {
        text = ""
    }


    // MARK: TextField Delegation

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        saveContentChanges?(textField.text ?? "")
    }

}
