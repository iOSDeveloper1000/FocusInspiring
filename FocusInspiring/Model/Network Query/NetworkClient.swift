//
//  NetworkClient.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation


class NetworkClient {

    struct Constant {
        static let endpoint = "https://api.flickr.com/services/rest"
        static let staticUrl = "https://live.staticflickr.com"
        static let apiKey = ""
        static let apiMethod = "flickr.photos.search"
        static let photosPerPage = 30
        static let pageNumber = 7
    }


    class func downloadImageUrlList(searchTerm: String, completion: @escaping ([String]?, HttpStatusResponse?, Error?) -> Void) {

        let searchString = "\(Constant.endpoint)?api_key=\(Constant.apiKey)&method=\(Constant.apiMethod)&format=json&per_page=\(Constant.photosPerPage)&page=\(Constant.pageNumber)&text=\(searchTerm)"

        guard let searchStr = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }

        guard let searchUrl = URL(string: searchStr) else { return }

        let task = URLSession.shared.dataTask(with: searchUrl, completionHandler: { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                return
            }

            let decoder = JSONDecoder()
            let jsonData = data.subdata(in: 14..<data.count-1)

            do {
                let responseBody = try decoder.decode(FlickrSearchResponse.self, from: jsonData)

                /// Synthesize the static photo urls
                var photoUrls = [String]()
                for img in responseBody.photos.photo {
                    let url = "\(Constant.staticUrl)/\(img.server)/\(img.id)_\(img.secret)_c.jpg"
                    photoUrls.append(url)
                }

                DispatchQueue.main.async {
                    completion(photoUrls, nil, nil)
                }

            } catch {
                /// Catch HTTP error response
                do {
                    let responseBody = try decoder.decode(HttpStatusResponse.self, from: jsonData)
                    DispatchQueue.main.async {
                        completion(nil, responseBody, error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, nil, error)
                    }
                }
            }
        })
        task.resume()
    }

    class func downloadImage(from url: URL, completion: @escaping (Data?) -> Void) {

        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url) {

                DispatchQueue.main.async {
                    completion(data)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
