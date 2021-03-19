//
//  Emptiable.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 19.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


/// Methods for indicating an empty UIViewController
protocol Emptiable: UIViewController {

    var backgroundLabel: UILabel? { get set }

    func setEmptyViewLabel(title: String, message: String)

    func removeEmptyViewLabel()

    func updateEmptyViewLayout()
}


extension Emptiable {

    /// Sets a background label with the specified text indicating an empty screen
    func setEmptyViewLabel(title: String, message: String) {

        let titleRange = NSMakeRange(0, title.count)

        let attributedLabel = NSMutableAttributedString(string: "\(title)\n\n\(message)")
        attributedLabel.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 21), range: titleRange)

        if backgroundLabel == nil {
            backgroundLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        }

        /// Use as many lines as needed
        backgroundLabel?.numberOfLines = 0

        backgroundLabel?.attributedText = attributedLabel

        backgroundLabel?.center = view.center
        backgroundLabel?.textAlignment = .center
        backgroundLabel?.textColor = .lightGray

        view.addSubview(backgroundLabel!)
    }

    /// Removes background label indicating an empty screen
    func removeEmptyViewLabel() {
        backgroundLabel?.removeFromSuperview()
    }

    /// Updates layout of background label -- to be used in viewDidLayoutSubviews()
    func updateEmptyViewLayout() {

        backgroundLabel?.center = view.center
    }
}
