//
//  Constants.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 18.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// Definition of Constants for FocusInspiring App

// MARK: General App Parameters

struct DataParameter {
    static let periodCounterMaxValue = 30
}


// MARK: View and Layout Parameters

struct TextParameter {
    static let textPlaceholder = "Enter your text note here"

    static let textFontSize: CGFloat = 16
    static let titleFontSize: CGFloat = 21
}


// MARK: Internal Keys and Parameters

struct InternalConstant {
    static let indexOfDisplayVCInTabBar = 1
}

/// Keys for saving in UserDefaults
struct DefaultKey {
    static let hasLaunchedBefore = "App has launched before"

    static let timeCountForPicker = "Key for Picker Time Counter Raw Value"
    static let timeUnitForPicker = "Key for Picker Time Unit Raw Value"
}
