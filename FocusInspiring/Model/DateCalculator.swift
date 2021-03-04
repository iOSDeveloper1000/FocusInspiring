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

        var stringValue: String {
            switch self {
            case .day: return "day(s)"
            case .week: return "week(s)"
            case .month: return "month(s)"
            case .year: return "year(s)"
            case .second: return "second(s)"
            case .minute: return "minute(s)"
            }
        }
    }


    // MARK: Date calculation

    class func convertDateUnits2DateComponents(value: Int, unit: DateUnit) -> DateComponents {

        var components = DateComponents()

        switch unit {
        case .second: components.second = value
        case .minute: components.minute = value
        case .day: components.day = value
        case .week: components.weekOfYear = value
        case .month: components.month = value
        case .year: components.year = value
        }

        return components
    }

    class func addToCurrentDate(period: DateComponents) -> Date? {

        let resultingDate = Calendar.autoupdatingCurrent.date(byAdding: period, to: Date())
        print("Resulting date: \(resultingDate!)")

        return resultingDate
    }
}
