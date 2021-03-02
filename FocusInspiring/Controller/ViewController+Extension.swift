//
//  ViewController+Extension.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 02.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// Extension for alert messages, as described in https://stackoverflow.com/a/60414319

extension UIViewController{
    
    public func popupAlert(title: String, message: String, alertStyle: UIAlertController.Style, actionTitles: [String], actionStyles: [UIAlertAction.Style], actions: [((UIAlertAction) -> Void)]){

        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        for(index, indexTitle) in actionTitles.enumerated() {
            
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            
            alertController.addAction(action)
        }
        
        present(alertController, animated: true)
    }
}
