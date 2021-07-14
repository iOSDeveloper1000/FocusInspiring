//
//  PickerData.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 17.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


protocol PickerData: UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Properties

    /// Row titles for the picker -- each (sub)array represents one component.
    var rowTitles: [[String]] { get set }

    /// Representation of the current selection as a string
    var textualRepresentation: String? { get }

}
