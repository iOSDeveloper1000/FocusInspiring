//
//  RootViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 26.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: RootViewController: UITabBarController

class RootViewController: UITabBarController {
    
    // MARK: Property
    
    var dataController: DataController!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpChildViewControllers()
    }


    // MARK: Setup

    private func setUpChildViewControllers() {

        guard let viewControllers = viewControllers else {
            fatalError("No view controller found")
        }

        for controller in viewControllers {

            switch controller {

            case let controller as DisplayNoteViewController:
                controller.dataController = dataController

            case let controller as AddNewNoteViewController:
                controller.dataController = dataController

            case let navigationVC as UINavigationController:
                if let collectionVC = navigationVC.topViewController as? ListNotesCollectionViewController {
                    collectionVC.dataController = dataController
                }

            default:
                break
            }
        }
    }
}
