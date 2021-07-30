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

// MARK: Default and User Keys

struct UserKey {
    struct PeriodValueKeyType {
        let count: String
        let unit: String
    }

    static let addNewNoteDefaultPeriod = PeriodValueKeyType(
        count: "UserKey: Default Period Count in AddNewVC",
        unit: "UserKey: Default Period Unit in AddNewVC"
    )
    static let repeatNoteDefaultPeriod = PeriodValueKeyType(
        count: "UserKey: Default Period Count for Repetition",
        unit: "UserKey: Default Period Unit for Repetition"
    )
}


// MARK: View and Layout Parameters

struct TextParameter {
    struct Title {
        static let listOfSuccess = "List of Glory"
        static let listOfActiveNotes = "List of Active Notes"
    }
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
    static let displayNoteStack = EmptyViewLabelMessage(title: "No more inspirational\nnotes for today", message: "Feel lucky anyway! :-)")

    static let successList = EmptyViewLabelMessage(title: "List still empty", message: "It seems like you have not added\nany inspirational note\nto your personal List of Glory yet.")

    static let activeNotesList = EmptyViewLabelMessage(title: "List currently empty", message: "It seems like you have currently\nno open ideas. Enjoy the day!")
}


// MARK: - Internal Identifiers

struct ViewControllerIdentifier {

    static let displayNoteVC: Int = 1
    static let addNewNoteVC: Int = 2
}

/// Keys for saving in UserDefaults
struct DefaultKey {
    static let hasLaunchedBefore = "App has launched before"

    /// User Settings
    static let reduceConfirmations = "Key for Reducing Number of Confirmations"
    static let enableTestingMode = "Key for Enabling Easier Testing"
}

/// Reuse Identifiers used across the app
struct ReuseIdentifier {
    struct ForViewController {
        /* @todo FILL */
    }

    struct ForTableViewCell {
        static let addNewDefaultPeriodSetting = "AddNewDefaultPeriodCellIdentifier"
        static let repeatDefaultPeriodSetting = "RepeatDefaultPeriodCellIdentifier"
    }

    // Identifiers for cells (old structure!) @todo
    static let inspirationalNoteCell = "InspirationalNoteCellIdentifier"

    // Identifiers for view controllers
    static let detailNoteViewController = "DetailNoteViewControllerIdentifier"
}
