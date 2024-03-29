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
/**
 Structure containing strings for label texts across the app.
 */
struct LabelText {

    struct EmptyView {
        static let displayNoteStack = Message(title: "display-note-vc-empty-title"~, body: "display-note-vc-empty-body"~)
        static let successList = Message(title: "list-notes-vc-empty-success-title"~, body: "list-notes-vc-empty-success-body"~)
        static let activeNotesList = Message(title: "list-notes-vc-empty-active-title"~, body: "list-notes-vc-empty-active-body"~)
    }
}

struct LayoutParameter {
    static let maxWidthInputView: CGFloat = 320

    struct Font {
        static let body = UIFont.preferredFont(forTextStyle: .body)
        static let largeTitle = UIFont.preferredFont(forTextStyle: .largeTitle)
    }

    struct TextColor {
        static let standard = UIColor.label
        static let placeholder = UIColor.lightGray
    }

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

/**
 Structure containing identifiers for resource objects.
 */
struct ResourceIdentifier {

    struct uiImageSrc {
        static let appIcon = "2021_AppIcon"
    }
}

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
    }

    struct forTableViewCell {
        static let enableTestModeSetting = "EnableTestModeCellIdentifier"
        static let addNewDefaultPeriodSetting = "AddNewDefaultPeriodCellIdentifier"
        static let repeatDefaultPeriodSetting = "RepeatDefaultPeriodCellIdentifier"

        static let deliverNotesAtSaveTime = "NotifyAtSaveTimeCellIdentifier"
        static let deliverNotesAtCustomTime = "NotifyAtCustomTimeCellIdentifier"

        static let recommendationInfo = "RecommendationCellIdentifier"
    }

    struct forSegue {
        static let initialDisplayNoteToFirst = "SegueInitiallyToFirstVC"
        static let displayNoteToEditNote = "SegueDisplayNoteToEditNote"

        static let aboutInfoToDetail = "SegueAboutAppInfoToDetail"
    }

    struct forObjectKey {
        static let restoreTmpNoteInEdit = "EditTemporaryNoteIdentifier"
        static let restoreTmpNoteInAddNew = "AddNewTemporaryNoteIdentifier"
    }
}
