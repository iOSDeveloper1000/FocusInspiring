//
//  UIScreen.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 05.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


extension UIScreen {

    /**
     Return true if device orientation is portrait otherwise false

     In default case, uses current main UIScreen for determination.
     - Parameter for: If not nil uses this parameter for determining orientation.
     - Returns: Boolean value true if device is in portrait mode otherwise false.
     */
    public static func isDeviceOrientationPortrait(for screenSize: CGSize? = nil) -> Bool {

        if let screenSize = screenSize {
            return screenSize.height > screenSize.width
        } else {
            return main.bounds.height > main.bounds.width
        }
    }

    /**
     The length of the shorter screen edge.
     */
    public static var lengthShortEdge: CGFloat {
        min(main.bounds.width, main.bounds.height)
    }
}
