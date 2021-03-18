//
//  PickerView+Extension.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 17.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


extension UIPickerView {

    /// Returns  the selected rows as an array of indices
    func selectedRows() -> [Int] {
        return (0..<numberOfComponents).map { selectedRow(inComponent: $0) }
    }

    /// Select rows given array of indices
    func selectRows(_ rows: [Int?]) {
        zip(rows, rows.indices).forEach {
            if let row = $0 {
                selectRow(row, inComponent: $1, animated: false)
            }
        }
    }
}
