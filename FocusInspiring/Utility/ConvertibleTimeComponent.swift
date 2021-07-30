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

        let rawString = (count > 0) ? "\(count) \(unitString)" : "none"

        // Append plural 's
        return (count > 1 && component != .none) ? "\(rawString)s" : rawString
    }

    /// Conversion to DateComponents object
    var dateComponent: DateComponents? {
        var result: DateComponents?

        switch component {
        case .sec: result = DateComponents(second: count)
        case .min: result = DateComponents(minute: count)
        case .day: result = DateComponents(day: count)
        case .week: result = DateComponents(weekOfYear: count)
        case .month: result = DateComponents(month: count)
        case .year: result = DateComponents(year: count)

        default: break
        }

        return result
    }


    // MARK: - Init Methods

    init(count: Int, component: RawComponent) {
        self.count = count
        self.component = component
    }

    init(count: Int, calendarComponent: Calendar.Component) {
        guard count > 0 else {
            self.init(count: 0, component: .none)
            return
        }

        switch calendarComponent {
        case .second: self.init(count: count, component: .sec)
        case .minute: self.init(count: count, component: .min)
        case .day: self.init(count: count, component: .day)
        case .weekOfYear: self.init(count: count, component: .week)
        case .month: self.init(count: count, component: .month)
        case .year: self.init(count: count, component: .year)

        // other values of type Calendar.Component not used
        default: self.init(count: 0, component: .none)
        }
    }

    init(count: Int, componentRawValue: Int) {
        self.count = count
        self.component = RawComponent(rawValue: componentRawValue) ?? .none
    }
}
