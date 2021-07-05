//
//  BasicDataTypes.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 05.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


extension Bool {

    /// Returns a Boolean value indicating whether two Boolean operands are not equal (XOR operation).
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}
