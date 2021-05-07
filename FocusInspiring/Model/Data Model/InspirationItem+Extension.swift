//
//  InspirationItem+Extension.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 26.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation
import CoreData


extension InspirationItem {
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(Date(), forKey: "creationDate")
        setPrimitiveValue(UUID().uuidString, forKey: "uuid")
    }
}
