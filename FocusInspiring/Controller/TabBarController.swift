//
//  TabBarController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 26.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: TabBarController: UITabBarController

class TabBarController: UITabBarController {
    
    // MARK: Properties
    
    var dataController: DataController!
    
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup child view controllers
        setupChildViewControllers()
    }
    
    // MARK: Helper
    
    private func setupChildViewControllers() {
        // @todo
        guard let viewControllers = viewControllers else {
            fatalError("No view controller found")
        }
        
        for controller in viewControllers {
            switch controller {
            case let controller as DisplayNoteViewController:
                controller.dataController = dataController
            case let controller as AddNewNoteViewController:
                controller.dataController = dataController
            default:
                print("Default case not in use")
            }
        }
    }
}
