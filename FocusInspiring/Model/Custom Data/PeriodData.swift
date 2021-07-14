//
//  PeriodData.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 17.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation
import UIKit


// MARK: PeriodData: NSObject, PickerData

class PeriodData: NSObject, PickerData {

    // MARK: Internal Type for Time Periods

    enum DateUnit: Int, CaseIterable {
        case day = 0
        case week
        case month
        case year

        case second     /* Just for facilitating tests */
        case minute     /* Just for facilitating tests */

        var toString: String {
            switch self {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"

            case .second: return "second"
            case .minute: return "minute"
            }
        }
    }


    // MARK: Properties

    var rowTitles: [[String]]

    var textualRepresentation: String? {
        get {
            var text = ""
            var textAppend = ""

            for (component, row) in currentSelection.enumerated() {
                if let row = row {
                    textAppend = rowTitles[component][row]
                } else {
                    textAppend = "???"
                }

                text = (text.isEmpty) ? textAppend : text + " \(textAppend)"
            }
            return text
        }
    }

    /// Current selection of the picker -- each entry represents one column of the picker
    private var currentSelection: [Int?]


    // @todo REFACTOR: SEPARATE AND TIDY UP
    init(countMax: Int) {

        rowTitles = setupPickerTitles()

        // @todo READ SELECTION WITH EACH VIEW APPEAR
        // Collect picker selection from peristently stored values
        let countRow = UserDefaults.standard.integer(forKey: UserKey.periodPickerCount)
        let unitRow = UserDefaults.standard.integer(forKey: UserKey.periodPickerUnit)
        currentSelection = [countRow, unitRow]

        super.init()
    }


    // MARK: Specific Methods

    // @todo REFACTOR: USE CUSTOMIZED UTILITY FUNCTION
    func computeTargetDateBy(selected rows: [Int]) -> Date? {

        /// Convert raw values into internally used time values
        let count: Int = rows[0] + 1
        guard let unit = DateUnit(rawValue: rows[1]) else { return nil }

        var components = DateComponents()

        switch unit {
        case .day: components.day = count
        case .week: components.weekOfYear = count
        case .month: components.month = count
        case .year: components.year = count

        case .second: components.second = count
        case .minute: components.minute = count
        }

        return Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
    }


    // MARK: Data Source and Delegation

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return rowTitles.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component < rowTitles.count else { return 0 }

        return rowTitles[component].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard component < rowTitles.count else { return nil }
        guard row < rowTitles[component].count else { return nil }

        return rowTitles[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard component < currentSelection.count else { return }

        currentSelection[component] = row

        // @opt-todo CHANGE PLURAL S IN DATA ARRAY HERE
    }
}


// MARK: Helper

fileprivate func setupPickerTitles() -> [[String]] {

    /// pickerTitles[0] represents the count values; pickerTitles[1] the date units like day, week, month and so on
    var pickerTitles: [[String]] = [[], []]

    var selectedDateUnits = PeriodData.DateUnit.allCases

    /// Do not use units second and minute in normal user mode (no testing)
    if !(UserDefaults.standard.bool(forKey: DefaultKey.enableTestingMode)) {

        selectedDateUnits.removeAll { ($0 == .second) || ($0 == .minute) }
    }

    pickerTitles[0] = (1...DataParameter.periodCounterMaxValue).map { String($0) }
    pickerTitles[1] = selectedDateUnits.compactMap { $0.toString + "(s)" }

    return pickerTitles
}
