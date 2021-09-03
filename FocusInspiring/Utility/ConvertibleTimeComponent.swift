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

    let count: Int?
    let component: Calendar.Component?

    /**
     A readable string that represents a time period composed of a number and a date component.

     Missing components will be replaced by a question mark.
     */
    var description: String {
        let unitStr: String

        // @todo LOCALIZE TIME UNITS - NOTE PLURAL FORMS
        switch component {
        case .second: unitStr = "sec"
        case .minute: unitStr = "min"
        case .day: unitStr = "day"
        case .weekOfYear: unitStr = "week"
        case .month: unitStr = "month"
        case .year: unitStr = "year"
        default: unitStr = "?"
        }

        guard let count = count, count > 0 else { return "? \(unitStr)" }
        guard let component = component else { return "\(count) ?" }

        var resultStr = "\(count) \(unitStr)"

        // Append plural s for some units
        let appendPluralSUnits: Array<Calendar.Component> = [.day, .weekOfYear, .month, .year]
        if count > 1 && appendPluralSUnits.contains(component) {
            resultStr = "\(resultStr)s"
        }

        return resultStr
    }


    // MARK: - Initialization

    init(count: Int?, calendarComponent: Calendar.Component?) {
        self.count = count
        self.component = calendarComponent
    }

    init(count: Int, componentRawValue: Int) {
        self.init(count: count, calendarComponent: Calendar.Component(rawValue: componentRawValue))
    }

    init() {
        self.init(count: nil, calendarComponent: nil)
    }


    // MARK: - Public

    /**
     Returns _true_,  if count and calendar component have non-zero and non-nil values, otherwise _false_.
     */
    func isValid() -> Bool {
        if description.contains("?") { return false }

        return true
    }

    /**
     Compute future date (with exact time) by adding self to given reference date.

     It decides to use the exact time of the reference date or a user specified time. For test calendar components (seconds and minutes), it will not do any further processing.
     - Parameter given: Reference date
     */
    func computeDeliveryDate(given refDate: Date) -> DateComponents? {
        guard let component = component,
              let count = count else { return nil }
        guard let targetRawDate = Calendar.current.date(byAdding: component, value: count, to: refDate) else { return nil }

        var targetDateComponents: DateComponents?

        let isTestComponent: Bool = (component == .second || component == .minute)
        let useOriginalTime: Bool = UserDefaults.standard.bool(forKey: UserKey.deliverAtSaveTime)

        if isTestComponent || useOriginalTime {

            // Use all components as given down to seconds
            targetDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetRawDate)
        } else {

            // Use settings specified time
            guard let customNotifyTime = UserDefaults.standard.object(forKey: UserKey.customDeliveryTime) as? Date else { return nil }

            let customNotifyHourMinute = Calendar.current.dateComponents([.hour, .minute], from: customNotifyTime)

            targetDateComponents = Calendar.current
                .dateComponents([.year, .month, .day], from: targetRawDate)
            targetDateComponents?.setValue(customNotifyHourMinute.hour, for: .hour)
            targetDateComponents?.setValue(customNotifyHourMinute.minute, for: .minute)
        }

        return targetDateComponents
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
