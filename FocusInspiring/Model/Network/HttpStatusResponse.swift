//
//  HttpStatusResponse.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 13.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


struct HttpStatusResponse: Codable {

    let stat: String
    let code: Int
    let message: String

}
