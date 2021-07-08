//
//  Emptiable.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 19.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: Protocol Emptiable: UIViewController

/// Methods for indicating an empty UIViewController
protocol Emptiable: UIViewController {

    // @todo REFACTOR -- SUBCLASS UILABEL ?
    var backgroundLabel: UILabel? { get set }

    /**
     Handle background label for emptiable views

     - Parameter msg: message to be displayed, message will be removed if nil
    */
    func handleEmptyViewLabel(msg: EmptyViewLabelMessage?)

    /// Update layout of background label -- to be used in viewDidLayoutSubviews()
    func updateEmptyViewLayout()
}

// MARK: Type Definition

/// Type for a message that indicates an empty view
struct EmptyViewLabelMessage {
    let title: String
    let message: String
}


// MARK: Extension for Implementation

extension Emptiable {

    func handleEmptyViewLabel(msg: EmptyViewLabelMessage?) {

        if let msg = msg {

            setupBackgroundLabel(msg: msg)

        } else {

            /// Remove background label -- in case of non-empty screen
            backgroundLabel?.removeFromSuperview()
        }
    }

    func updateEmptyViewLayout() {

        backgroundLabel?.center = view.center
    }

    /// Setup background label with given message components
    private func setupBackgroundLabel(msg: EmptyViewLabelMessage) {

        let titleRange = NSMakeRange(0, msg.title.count)

        let attributedLabel = NSMutableAttributedString(string: "\(msg.title)\n\n\(msg.message)")
        attributedLabel.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 21), range: titleRange)

        if backgroundLabel == nil {
            /// Initialize label for the first time
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
}
