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


    // MARK: Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        imageView.image = UIImage(named: "2021-04_LampIcon")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let isPortraitMode = UIScreen.isDeviceOrientationPortrait()

        /// Layout shall depend on device orientation
        welcomeLabel.text = isPortraitMode ? "WELCOME\t\t\t\t\t\nFEELING\n\t\t\t\tINSPIRED" : "WELCOME  FEELING  INSPIRED"
        welcomeLabel.font = .systemFont(ofSize: isPortraitMode ? 35 : 30)
        welcomeLabel.textAlignment = .center
    }
}
