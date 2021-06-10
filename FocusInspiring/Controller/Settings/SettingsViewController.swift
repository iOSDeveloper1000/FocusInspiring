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

            /// Toggle accessory type
            let selectedRow = tableView.cellForRow(at: indexPath)

            selectedRow?.accessoryType = (selectedRow?.accessoryType == UITableViewCell.AccessoryType.none) ? .checkmark : .none

            // @todo Save changed setting programmatically and in persistency
        }

        return indexPath
    }


    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        /// Choose segue according to tapped cell
        switch segue.identifier {

        case "ShareWithFriendsSegue":
            print("@todo Share with Friends")

        case "BuyCoffeeSegue":
            print("@todo Buy me a Coffee")

        case "AboutAppSegue":
            print("@todo About this App")

        default:
            track("Settings: Segue not found")
        }
    }
}
