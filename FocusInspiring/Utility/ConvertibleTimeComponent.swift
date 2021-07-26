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

    // MARK: - Type Definition

    //  @todo REFACTOR: USE CALENDAR.COMPONENT INSTEAD ?
    enum RawComponent: Int {
        case none = 0 // empty value

        case sec
        case min
        case day
        case week
        case month
        case year
    }


    // MARK: - Properties

    let count: Int
    let component: RawComponent

    var description: String {
        var unitString: String

        switch component {
        case .sec: unitString = "second"
        case .min: unitString = "minute"
        case .day: unitString = "day"
        case .week: unitString = "week"
        case .month: unitString = "month"
        case .year: unitString = "year"
        default: unitString = "?"
        }

        let rawString = "\(count) \(unitString)"

        // Append plural 's
        return (count > 1 && component != .none) ? "\(rawString)s" : rawString
    }

    /// Conversion to DateComponents object
    var dateComponent: DateComponents {
        switch component {
        case .sec: return DateComponents(second: count)
        case .min: return DateComponents(minute: count)
        case .day: return DateComponents(day: count)
        case .week: return DateComponents(weekOfYear: count)
        case .month: return DateComponents(month: count)
        case .year: return DateComponents(year: count)
        default: break
        }

        return DateComponents() // zero value
    }


    // MARK: - Init Methods

    init(count: Int, component: RawComponent) {
        self.count = count
        self.component = component
    }

    init(count: Int, calendarComponent: Calendar.Component) {
        self.count = count

        switch calendarComponent {
        case .second: component = .sec
        case .minute: component = .min
        case .day: component = .day
        case .weekOfYear: component = .week
        case .month: component = .month
        case .year: component = .year

        // other values of type Calendar.Component not used
        default: component = .none
        }
    }

    init(count: Int, componentRawValue: Int) {
        self.count = count
        self.component = RawComponent(rawValue: componentRawValue) ?? .none
    }
}
