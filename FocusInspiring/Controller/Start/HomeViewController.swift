//
//  HomeViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: HomeViewController: UIViewController

class HomeViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!


    // MARK: Life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        imageView.image = UIImage(named: "2021-04_LampIcon")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let isLandscapeMode = (UIScreen.main.bounds.height < UIScreen.main.bounds.width)

        /// Set layout depending on device orientation
        welcomeLabel.text = isLandscapeMode ? "WELCOME  FEELING  INSPIRED" : "WELCOME\t\t\t\t\t\nFEELING\n\t\t\t\tINSPIRED"
        welcomeLabel.font = .systemFont(ofSize: isLandscapeMode ? 30.0 : 35.0)
        welcomeLabel.textAlignment = .center
    }
}
