//
//  PickerData.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 17.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


protocol PickerData: UIPickerViewDelegate, UIPickerViewDataSource {

    var data: [[String]] { get set }

    /// Save selected row indices to the used store
    func saveSelection(given rows: [Int])

    /// Retrieve row indices from the used store
    func retrieveSelection() -> [Int?]

    /// Convert selected row indices to a printable string
    func textBy(selected rows: [Int]) -> String

}
