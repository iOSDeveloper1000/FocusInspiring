//
//  CustomOperators.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 03.09.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


/**
 Custom postfix operator for localized strings -- shortcut notation.
 */
postfix operator ~
postfix func ~(string: String) -> String {
    return NSLocalizedString(string, comment: "")
}


/**
 Custom infix operator for localized strings with exactly one placeholder -- shortcut notation.
 */
infix operator ~
func ~(string: String, insert: String) -> String {
    let localized = NSLocalizedString(string, comment: "")

    return String.localizedStringWithFormat(localized, insert)
}
