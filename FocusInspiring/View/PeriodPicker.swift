//
//  PeriodPicker.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 14.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


class PeriodPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    typealias SaveKey = AppDelegate.DefaultKey


    // MARK: Properties

    private let counterComponentIndex: Int = 0
    private let unitComponentIndex: Int = 1

    private let counterMaxValue: Int = 30


    // MARK: Public Interface

    public func getCountRow() -> Int {
        return selectedRow(inComponent: counterComponentIndex)
    }

    public func getUnitRow() -> Int {
        return selectedRow(inComponent: unitComponentIndex)
    }

    public func setRowsFromUserDefaults() {
        let userCountRow = UserDefaults.standard.integer(forKey: SaveKey.timeCountForPicker)
        let userUnitRow = UserDefaults.standard.integer(forKey: SaveKey.timeUnitForPicker)

        selectRow(userCountRow, inComponent: counterComponentIndex, animated: false)
        selectRow(userUnitRow, inComponent: unitComponentIndex, animated: false)
    }

    public func saveSelectedRowsToUserDefaults() {
        let selectedCountRow = selectedRow(inComponent: counterComponentIndex)
        let selectedUnitRow = selectedRow(inComponent: unitComponentIndex)

        UserDefaults.standard.set(selectedCountRow, forKey: SaveKey.timeCountForPicker)
        UserDefaults.standard.set(selectedUnitRow, forKey: SaveKey.timeUnitForPicker)
    }


    // MARK: Data Source

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return unitComponentIndex + 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        switch component {

        case counterComponentIndex:
            return counterMaxValue

        case unitComponentIndex:
            return DateCalculator.DateUnit.allCases.count

        default:
            print("Unknown component index in pickerView(_:numberOfRowsInComponent:)")
            return 0
        }
    }


    // MARK: Delegation

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch component {

        case counterComponentIndex:
            return String(row + 1)

        case unitComponentIndex:
            if let unitString = DateCalculator.DateUnit(rawValue: row)?.toString {
                return unitString + "(s)"
            } else {
                return nil
            }

        default:
            print("Unknown component index in pickerView(_:titleForRow:forComponent:)")
            return nil
        }
    }
}
