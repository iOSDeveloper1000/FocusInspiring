//
//  SettingsViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 10.06.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: SettingsViewController: UITableViewController

class SettingsViewController: UITableViewController {

    private let VERSION_NUMBER = "0.1" // @todo Move to Constants file + Naming convention check


    // MARK: Outlets

    @IBOutlet weak var versionCell: UITableViewCell!


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        versionCell.detailTextLabel?.text = VERSION_NUMBER

        // @todo Load user settings from persistency
    }


    // MARK: Delegate

    /// Toggle accessory type to '.checkmark' when trying to select rows for this use
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier else {
            track("GUARD FAILED: Selected cell not found or has no reuse identifier")
            return indexPath
        }

        let checkmarkCellIdentifiers: [String] = ["ReduceConfirmationsCell", "EnableTestingCell"]

        if checkmarkCellIdentifiers.contains(identifier) {

            /// Handling cells that toggle checkmark accesssory on tap

            let selectedRow = tableView.cellForRow(at: indexPath)

            selectedRow?.accessoryType = (selectedRow?.accessoryType == UITableViewCell.AccessoryType.none) ? .checkmark : .none

            // @todo Save changed setting programmatically and in persistency

        } else if identifier == "RecommendationCell" {

            /// Handling cell that presents acitivity view controller on tap

            shareAppWithFriends()
        }

        return indexPath
    }


    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        /// Choose segue according to tapped cell
        switch segue.identifier {

        case "BuyCoffeeSegue":
            print("@todo Buy me a Coffee")

        case "AboutAppSegue":
            print("@todo About this App")

        default:
            track("Settings: Segue not found")
        }
    }


    // MARK: Own methods

    private func shareAppWithFriends() {
        // @todo set correct app id and url: "https://apps.apple.com/us/app/idxxxxxxxxxx"
        guard let urlStr = URL(string: "https://github.com/iOSDeveloper1000/FocusInspiring" ) else {
            track("GUARD FAILED: App url not convertible")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [urlStr], applicationActivities: nil)

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popup = activityVC.popoverPresentationController {
                popup.sourceView = self.view
                popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
            }
        }

        present(activityVC, animated: true, completion: nil)
    }
}
