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

    // MARK: Time Units

    enum TimeUnit: Int, CaseIterable {
        case second = 0 // @todo - only for easier testing
        case minute     // @todo - only for easier testing
        case hour       // @todo - only for easier testing
        case day
        case week
        case month
        case year

        var stringValue: String {
            switch self {
            case .second: return "second"
            case .minute: return "minute"
            case .hour: return "hour"
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            }
        }
    }


    var selectedCount: Int?
    var selectedUnit: String?


    // MARK: Delegate and Data Source methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        var numberOfRows: Int = 1

        switch component {
        case 0:
            numberOfRows = 60
        case 1:
            numberOfRows = TimeUnit.allCases.count
        default:
            print("ERROR Default case not available")
        }

        return numberOfRows
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch component {
        case 0:
            return String(row + 1)
        case 1:
            return TimeUnit(rawValue: row)?.stringValue ?? "???"
        default:
            return "???"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if component == 0 {

            selectedCount = row + 1

        } else if component == 1 {

            selectedUnit = TimeUnit.init(rawValue: row)?.stringValue

        }

    }

}
