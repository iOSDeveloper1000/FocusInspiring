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

struct AppParameter {
    static let versionNumber = "0.1" // @todo Update with every publishing

    // @todo set correct app id and url: "https://apps.apple.com/us/app/idxxxxxxxxxx"
    static let appUrl = "https://github.com/iOSDeveloper1000/FocusInspiring"
}

struct DataParameter {
    static let periodCounterMaxValue = 30
}


// MARK: View and Layout Parameters

struct TextParameter {
    static let textPlaceholder = "Enter your text note here"

    static let textFontSize: CGFloat = 16
    static let titleFontSize: CGFloat = 21
}

struct LayoutParameter {
    /// Layout parameters for ListNotesCollectionViewController
    struct ListNotesCollectionView {
        static let itemsPerRowPortrait: Int = 3
        static let itemsPerRowLandscape: Int = 4
        static let lineSpacing: CGFloat = 1.0
        static let interitemSpacing: CGFloat = 4.0
    }

    // Add layout parameters for further views here.
}

struct EmptyViewLabel {
    /// Label text for ListNotesCollectionViewController
    struct ListNotesCollectionView {
        static let title = "List still empty"
        static let message = "It seems like you have not added\nany inspirational note\nto your personal List of Glory yet."
    }

    // Add further empty view label text here.
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

    /// User Settings
    static let reduceConfirmations = "Key for Reducing Number of Confirmations"
    static let enableTestingMode = "Key for Enabling Easier Testing"
}

/// Reuse Identifiers used across the app
struct ReuseIdentifier {

    // Identifiers for cells
    static let inspirationalNoteCell = "InspirationalNoteCellIdentifier"

    // Identifiers for view controllers
    static let detailNoteViewController = "DetailNoteViewControllerIdentifier"
}
