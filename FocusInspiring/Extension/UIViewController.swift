//
//  UIViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 02.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


extension UIViewController {

    // MARK: - Alert

    /**
     Constructs generically an alert message and displays it to the user.

     Each action must be given exactly one title, one style and one action closure (can be _nil_). Each array must follow the same order of actions.
     - Parameter title: Headline of the alert.
     - Parameter message: Body text of the alert.
     - Parameter alertStyle: Preferred style of the alert: i.e. actionSheet or alert.
     - Parameter actionTitles: Set of titles -- each title represents one action.
     - Parameter actionStyles: The styles for the possible actions.
     - Parameter actions: The closures representing the actions.
     */
    public func popupAlert(title: String, message: String, alertStyle: UIAlertController.Style, actionTitles: [String], actionStyles: [UIAlertAction.Style], actions: [((UIAlertAction) -> Void)?]) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        for(index, indexTitle) in actionTitles.enumerated() {
            
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            
            alertController.addAction(action)
        }

        // Workaround - See remark in UIAlertController extension.
        alertController.pruneNegativeWidthConstraints()
        
        present(alertController, animated: true)
    }


    // MARK: - Background label

    /**
     Adds a label with the given message to the background of the view controller.

     - Parameter message: Message to be displayed.
     - Returns: Background label that will be displayed.
     */
    public func addBackgroundLabel(message: Message) -> BackgroundLabel {

        let bgLabel = BackgroundLabel(frame: view.frame)

        bgLabel.updateText(with: message)

        // Set layout parameter
        bgLabel.numberOfLines = 0 // Use as many lines as needed
        bgLabel.center = view.center
        bgLabel.textAlignment = .center
        bgLabel.textColor = .lightGray

        view.addSubview(bgLabel)

        return bgLabel
    }
}
