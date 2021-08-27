//
//  Constants.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 18.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// Definition of Constants and Strings for App FocusInspiring

// MARK: - General App Parameters

struct AppParameter {

    static let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    // @todo set correct app id and url: "https://apps.apple.com/us/app/idxxxxxxxxxx"
    static let appUrl = "https://github.com/iOSDeveloper1000/FocusInspiring"
}


// MARK: - Keys for UserDefaults

struct UserKey {
    static let appLaunchedBefore = "User Key: App has launched before"
    static let doNotShowInitialViewAgain = "User Key: Do not show initial screen again"

    static let reduceUserQueries = "User Key: Reduce number of Queries to the User"
    static let enableTestMode = "User Key: Enable Test Mode"

    static let deliverAtSaveTime = "User Key: Deliver Notes at Save Time"
    static let customDeliveryTime = "User Key: Custom Delivery Time"


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

    /**
     Reset stored parameter values in UserDefaults -- for first app launch
     */
    static func setupUserDefaults() {
        UserDefaults.standard.set(true, forKey: appLaunchedBefore)

        UserDefaults.standard.set(0 /* unset */, forKey: addNewNoteDefaultPeriod.count)
        UserDefaults.standard.set(99 /* unset */, forKey: addNewNoteDefaultPeriod.unit)
        UserDefaults.standard.set(0 /* unset */, forKey: repeatNoteDefaultPeriod.count)
        UserDefaults.standard.set(99 /* unset */, forKey: repeatNoteDefaultPeriod.unit)

        UserDefaults.standard.set(true, forKey: deliverAtSaveTime)

        UserDefaults.standard.synchronize()
    }
}


// MARK: - View and Layout Parameters

struct TextParameter {

    struct Title {
        static let listOfSuccess = "List of Glory"
        static let listOfActiveNotes = "List of Active Notes"
    }
    static let textPlaceholder = "Enter your text note here"

    static let textFontSize: CGFloat = 16
    static let titleFontSize: CGFloat = 21
}

/**
 Structure containing strings for label texts across the app.
 */
struct LabelText {

    struct EmptyView {
        static let displayNoteStack = Message(title: "No more Inspirational\nNotes for Today", body: "Feel lucky anyway :-)")
        static let successList = Message(title: "List still empty", body: "It seems like you have not added\nany inspirational note\nto your personal List of Glory yet.")
        static let activeNotesList = Message(title: "List currently empty", body: "It seems like you have currently\nno open ideas. Enjoy the day :-)")
    }
}

struct LayoutParameter {

    struct ListNotesCollectionView {
        static let itemsPerRowPortrait: Int = 3
        static let itemsPerRowLandscape: Int = 4
        static let lineSpacing: CGFloat = 1.0
        static let interitemSpacing: CGFloat = 4.0
    }

    // Add layout parameters for further views here.
}

/**
 Structure containing date formatting objects for different purposes.
 */
struct DateFormatting {
    /**
     DateFormatter used for reporting dates in full date style mode.
     */
    static let declarationFormat: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        if UserDefaults.standard.bool(forKey: UserKey.enableTestMode) {
            df.timeStyle = .medium
        }
        return df
    }()
    /**
     DateFormatter used for formatting dates within header and footer sections.
     */
    static let headerFormat: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }()
}


// MARK: - Internal Identifiers

struct ViewControllerIdentifier {
    // to be synchronized with Main.storyboard when changed !
    static let displayNoteVC: Int = 0
    static let addNewNoteVC: Int = 1
    static let listNotesVC: Int = 2
    static let settingsVC: Int = 3
}

/**
 Structure containing reuse identifiers used across the app.
 */
struct ReuseIdentifier {

    struct forViewController {
        static let detailNote = "DetailNoteViewControllerIdentifier"
    }

    struct forCollectionViewCell {
        static let inspirationalNote = "InspirationalNoteCellIdentifier"
        static let imageSearchResult = "ImageSearchResultCellIdentifier"
    }

    struct forTableViewCell {
        static let reduceUserQueriesSetting = "ReduceUserQueriesCellIdentifier"
        static let enableTestModeSetting = "EnableTestModeCellIdentifier"
        static let addNewDefaultPeriodSetting = "AddNewDefaultPeriodCellIdentifier"
        static let repeatDefaultPeriodSetting = "RepeatDefaultPeriodCellIdentifier"

        static let recommendationInfo = "RecommendationCellIdentifier"
    }

    struct forSegue {
        static let initialDisplayNoteToFirst = "SegueInitiallyToFirstVC"
        static let displayNoteToEditNote = "SegueDisplayNoteToEditNote"
        static let addNewNoteToImageSearch = "SegueAddNewNoteToImageSearch"
        static let editNoteToImageSearch = "SegueEditNoteToImageSearch"

        static let buyCoffeeSettingToDetail = "SegueBuyCoffeeSettingToDetail"
        static let aboutInfoToDetail = "SegueAboutAppInfoToDetail"
    }

    struct forObjectKey {
        static let editingNote = "EditingNoteIdentifier"
        static let addingNewNote = "AddingNewNoteIdentifier"
    }
}
