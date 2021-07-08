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

    /// Array keeping text entries for the picker row titles
    var data: [[String]]

    /// Keys for saving in UserDefaults - nil entries prevent saving associated component
    let saveKeys: [String?]

    /// String being used in front of the period declaration
    var preText: String

    /// String being used behind the period declaration
    var postText: String


    // @todo separate specialized things to own method(s)
    init(countMax: Int, saveKeys: [String?]? = nil, preText: String = "", postText: String = "") {

        data = setupPickerTitles()

        if let keys = saveKeys {
            self.saveKeys = keys
        } else {
            self.saveKeys = [String?](repeating: nil, count: data.count)
        }

        self.preText = preText
        self.postText = postText

        super.init()
    }


    // MARK: PickerData Implementation

    /// Save selected row indices to UserDefaults
    func saveSelection(given rows: [Int]) {
        zip(rows.indices, rows).forEach {
            if let key = saveKeys[$0] {
                UserDefaults.standard.set($1, forKey: key)
            }
        }
    }

    /// Retrieve row selection from UserDefaults
    func retrieveSelection() -> [Int?] {
        return saveKeys.map {
            if let key = $0 {
                return UserDefaults.standard.integer(forKey: key)
            } else {
                return nil
            }
        }
    }

    func textBy(selected rows: [Int]) -> String {
        guard rows[0] < data[0].count else { return "???" }
        guard let unitStr = DateUnit.init(rawValue: rows[1])?.toString else { return "???" }

        let countStr = data[0][rows[0]]

        /// Append plural 's' for any number greater than 1
        let periodStr = countStr + " " + unitStr + ((rows[0] > 0) ? "s" : "")

        return preText + periodStr + postText
    }


    // MARK: Specific Methods

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


    // MARK: PickerView Data Source and Delegation

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component < data.count else { return 0 }

        return data[component].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard component < data.count else { return nil }
        guard row < data[component].count else { return nil }

        return data[component][row]
    }
}


// MARK: Helper

fileprivate func setupPickerTitles() -> [[String]] {

    /// pickerTitles[0] represents the count values; pickerTitles[1] the date units like day, week, month and so on
    var pickerTitles: [[String]] = [[], []]

    var selectedDateUnits = PeriodData.DateUnit.allCases

    /// Do not use units second and minute in normal user mode (no testing)
    if !(UserDefaults.standard.bool(forKey: DefaultKey.enableTestingMode)) {

        selectedDateUnits.removeAll { return ($0 == .second || $0 == .minute) }
    }

    pickerTitles[0] = (1...DataParameter.periodCounterMaxValue).map { String($0) }
    pickerTitles[1] = selectedDateUnits.compactMap { $0.toString + "(s)" }

    return pickerTitles
}
