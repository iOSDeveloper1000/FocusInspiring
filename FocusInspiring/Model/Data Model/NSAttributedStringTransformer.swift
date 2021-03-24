//
//  NSAttributedStringTransformer.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 15.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//


import UIKit
import CoreData


/// Workaround for the secure unarchiving of attributed strings as described here: https://developer.apple.com/forums/thread/653853
@objc(NSAttributedStringTransformer)
class NSAttributedStringTransformer: NSSecureUnarchiveFromDataTransformer {
        override class var allowedTopLevelClasses: [AnyClass] {
                return super.allowedTopLevelClasses + [NSAttributedString.self]
        }
}
