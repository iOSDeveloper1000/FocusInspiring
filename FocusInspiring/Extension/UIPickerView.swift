//
//  UIPickerView.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 17.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


extension UIPickerView {

    /// Returns  the selected rows as an array of indices
    func selectedRows() -> [Int] {
        return (0..<numberOfComponents).map { selectedRow(inComponent: $0) }
    }


    // @opt-todo REFACTOR: MAKE GENERAL PROTOCOL AND IMPLEMENTATION FOR PICKER WITH SAVED PICKER SELECTION

    /// Select rows from saved selection in UserDefaults
    func collectSelection() {
        let countRow = UserDefaults.standard.integer(forKey: UserKey.periodPickerCount)
        let unitRow = UserDefaults.standard.integer(forKey: UserKey.periodPickerUnit)

        selectRow(countRow, inComponent: 0, animated: false)
        selectRow(unitRow, inComponent: 1, animated: false)
    }

    /// Save selected rows to UserDefaults
    func saveSelection() {
        let countRow = selectedRow(inComponent: 0)
        let unitRow = selectedRow(inComponent: 1)

        UserDefaults.standard.set(countRow, forKey: UserKey.periodPickerCount)
        UserDefaults.standard.set(unitRow, forKey: UserKey.periodPickerUnit)
    }
}
