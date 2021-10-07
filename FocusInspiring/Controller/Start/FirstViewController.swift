//
//  FirstViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 18.08.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: FirstViewController: UIViewController

class FirstViewController: UIViewController {

    // MARK: - Property

    /**
     Called on dismissal of this (initial) view controller.

     Called with the tabbar item index accordingly to the tapped button.
     */
    var onDismiss: (_ selectedTab: Int) -> Void = { _ in }


    // MARK: - Outlets

    @IBOutlet weak var globalStackView: UIStackView!

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var notShowAgainSwitch: UISwitch!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        // Layout of welcome text
        welcomeLabel.text = TextParameter.welcomeSlogan
        welcomeLabel.textAlignment = .center

        welcomeLabel.font = LayoutParameter.Font.largeTitle
        welcomeLabel.adjustsFontForContentSizeCategory = true

        // Layout of icon image
        iconImageView.image = UIImage(named: ResourceIdentifier.uiImageSrc.appIcon)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        globalStackView.axis = UIScreen.isDeviceOrientationPortrait() ? .vertical : .horizontal
    }


    // MARK: - Actions

    @IBAction func navigateToTodayTab(_ sender: UIButton) {
        onDismiss(ViewControllerIdentifier.displayNoteVC)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func navigateToAddNewTab(_ sender: UIButton) {
        onDismiss(ViewControllerIdentifier.addNewNoteVC)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func navigateToSuccessListTab(_ sender: UIButton) {
        onDismiss(ViewControllerIdentifier.listNotesVC)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func notShowAgainSwitchChanged(_ sender: UISwitch) {
        if notShowAgainSwitch.isOn {
            UserDefaults.standard.set(true, forKey: UserKey.doNotShowInitialViewAgain)
        } else {
            UserDefaults.standard.set(false, forKey: UserKey.doNotShowInitialViewAgain)
        }
    }
}
