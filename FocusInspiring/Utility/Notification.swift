//
//  Notification.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 29.04.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


struct Notification {

    var id: String
    var body: String?
    var dateTime: DateComponents

    init(id: String, body: String? = nil, dateTime: DateComponents) {
        self.id = id
        self.body = body
        self.dateTime = dateTime
    }
}
