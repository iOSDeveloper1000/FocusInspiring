//
//  UIAlertController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 24.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


extension UIAlertController {

    /// Workaround for the enduring iOS bug with actionsheets described here: https://stackoverflow.com/a/58666480
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
