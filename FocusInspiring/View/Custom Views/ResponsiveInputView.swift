//
//  ResponsiveInputView.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 26.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


protocol ResponsiveInputView {
    associatedtype ReturnValue: CustomStringConvertible

    /// String that describes the user input
    var printedRawInput: String { get }

    /// Formatted user specified value that can be fetched by calling instances
    var convertedData: ReturnValue { get }

    /// Clear former input from any output medium (like textField or textView).
    func clearInput()

}
