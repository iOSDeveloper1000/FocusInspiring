//
//  FlickrSearchResponse.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 13.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


struct PhotoMetaData: Decodable {

    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String

}

struct PhotoPage: Decodable {

    let page: Int
    let pages: Int
    let perpage: Int
    let total: String

    let photo: [PhotoMetaData]

}

struct FlickrSearchResponse: Decodable {

    let photos: PhotoPage
    let stat: String

}
