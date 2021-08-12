//
//  ConvertibleTimeComponent.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 28.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


// MARK: ConvertibleTimeComponent: CustomStringConvertible

struct ConvertibleTimeComponent: CustomStringConvertible {

    // MARK: - Properties

    let count: Int
    let component: Calendar.Component

    var description: String {
        var unitString: String

        switch component {
        case .second: unitString = "sec"
        case .minute: unitString = "min"
        case .day: unitString = "day"
        case .weekOfYear: unitString = "week"
        case .month: unitString = "month"
        case .year: unitString = "year"
        default: unitString = "?"
        }

        var valueString = (count > 0) ? "\(count) \(unitString)" : "none"

        // Append plural s for some units
        let appendPluralSUnits: Array<Calendar.Component> = [.day, .weekOfYear, .month, .year]
        valueString = (count > 1 && appendPluralSUnits.contains(component)) ? "\(valueString)s" : valueString

        return valueString
    }


    // MARK: - Initialization

    init(count: Int, calendarComponent: Calendar.Component) {
        self.count = count
        self.component = calendarComponent
    }

    init(count: Int, componentRawValue: Int) {
        self.count = count
        self.component = Calendar.Component(rawValue: componentRawValue) ?? .calendar // .calender = "unset"
    }


    // MARK: - Public

    func addSelf(to refDate: Date) -> DateComponents? {
        guard let targetDate = Calendar.current.date(byAdding: component, value: count, to: refDate) else {
            return nil
        }

        let units: Array<Calendar.Component>

        // @todo append hour-minute-second in cases user selected clock time for notifications
        // @todo ... add selection in settings vc

        if UserDefaults.standard.bool(forKey: UserKey.enableTestMode) {
            // Take all calendar components up to seconds
            units = [.year, .month, .day, .hour, .minute, .second]
        } else {
            // Crop date components beyond days
            units = [.year, .month, .day]
        }

        return Calendar.current.dateComponents(Set(units), from: targetDate)
    }
}


// MARK: - extension Calendar.Component
/**
 Use Calendar.Component values with integer raw values
 */
extension Calendar.Component: RawRepresentable {
    public var rawValue: Int {
        switch self {
        case .calendar:
            return 0
        case .day:
            return 1
        case .era:
            return 2
        case .hour:
            return 3
        case .minute:
            return 4
        case .month:
            return 5
        case .nanosecond:
            return 6
        case .quarter:
            return 7
        case .second:
            return 8
        case .timeZone:
            return 9
        case .weekday:
            return 10
        case .weekdayOrdinal:
            return 11
        case .weekOfMonth:
            return 12
        case .weekOfYear:
            return 13
        case .year:
            return 14
        case .yearForWeekOfYear:
            return 15
        @unknown default:
            return 99
        }
    }

    public init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .calendar
        case 1:
            self = .day
        case 2:
            self = .era
        case 3:
            self = .hour
        case 4:
            self = .minute
        case 5:
            self = .month
        case 6:
            self = .nanosecond
        case 7:
            self = .quarter
        case 8:
            self = .second
        case 9:
            self = .timeZone
        case 10:
            self = .weekday
        case 11:
            self = .weekdayOrdinal
        case 12:
            self = .weekOfMonth
        case 13:
            self = .weekOfYear
        case 14:
            self = .year
        case 15:
            self = .yearForWeekOfYear
        default:
            return nil
        }
    }
}
