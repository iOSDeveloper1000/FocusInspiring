//
//  UIScreen.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 05.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


extension UIScreen {

    /// Returns true if device orientation is portrait otherwise false.
    public static func isDeviceOrientationPortrait() -> Bool {

        return main.bounds.height > main.bounds.width
    }
}
