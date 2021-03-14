//
//  DateCalculator.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 05.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


// MARK: DateCalculator

public class DateCalculator {

    // MARK: Time Unit Type

    enum DateUnit: Int, CaseIterable {
        case day = 0
        case week
        case month
        case year

        case second     // @todo - only for easier testing
        case minute     // @todo - only for easier testing

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


    // MARK: Public Interface

    class func getPeriodString(from picker: PeriodPicker) -> String {

        let selectedRawCount = picker.getCountRow()
        let selectedRawUnit = picker.getUnitRow()

        let countString = String(selectedRawCount + 1)

        if let unitString = DateUnit(rawValue: selectedRawUnit)?.toString {
            return countString + " " + unitString + ((selectedRawCount > 0) ? "s" : "")
        } else {
            return "???"
        }
    }

    class func getTargetDate(from picker: PeriodPicker) -> Date? {

        let selectedRawCount = picker.getCountRow()
        let selectedRawUnit = picker.getUnitRow()

        // Convert raw values from period picker to computable time values
        let count: Int = selectedRawCount + 1
        guard let unit = DateUnit(rawValue: selectedRawUnit) else {
            return nil
        }

        // Calculate and return target date
        return convertPeriodToFutureDate(count: count, unit: unit)
    }


    // MARK: Helper

    private class func convertPeriodToFutureDate(count: Int, unit: DateUnit) -> Date? {
        var components = DateComponents()

        switch unit {
        case .second: components.second = count
        case .minute: components.minute = count
        case .day: components.day = count
        case .week: components.weekOfYear = count
        case .month: components.month = count
        case .year: components.year = count
        }

        return Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
    }
}
