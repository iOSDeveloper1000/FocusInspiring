//
//  PeriodPickerDelegate.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 03.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: PeriodPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource

class PeriodPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Constants

    struct Constant {
        static let timeCounterComponent: Int = 1
        static let timeUnitComponent: Int = 2

        static let pickerDescriptiveString = "Present in:  "
        static let timeCounterMaxValue: Int = 30
    }


    // MARK: Properties

    var selectedRawCount: Int?
    var selectedRawUnit: Int?


    // MARK: Delegate and Data Source methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Constant.timeUnitComponent + 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        switch component {
        case 0:
            return 1
        case Constant.timeCounterComponent:
            return Constant.timeCounterMaxValue
        case Constant.timeUnitComponent:
            return DateCalculator.DateUnit.allCases.count
        default:
            fatalError("Default case in picker view not available")
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch component {
        case 0:
            return Constant.pickerDescriptiveString
        case Constant.timeCounterComponent:
            return String(row + 1)
        case Constant.timeUnitComponent:
            return DateCalculator.DateUnit(rawValue: row)?.stringValue ?? nil
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if component == Constant.timeCounterComponent {
            selectedRawCount = row
        } else if component == Constant.timeUnitComponent {
            selectedRawUnit = row
        }
    }
}
