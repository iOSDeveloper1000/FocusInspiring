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

    // MARK: Outlets

    @IBOutlet weak var reduceConfirmationsCell: UITableViewCell!
    @IBOutlet weak var enableTestingCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        versionCell.detailTextLabel?.text = AppParameter.versionNumber

        reduceConfirmationsCell.accessoryType = UserDefaults.standard.bool(forKey: DefaultKey.reduceConfirmations) ? .checkmark : .none
        enableTestingCell.accessoryType = UserDefaults.standard.bool(forKey: DefaultKey.enableTestingMode) ? .checkmark : .none
    }


    // MARK: Delegate

    /// Toggle accessory type to '.checkmark' when trying to select rows for this use
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier else {
            track("GUARD FAILED: Selected cell not found or has no reuse identifier")
            return indexPath
        }

        switch identifier {
        case "ReduceConfirmationsCell":
            handleAccessoryTypeAndPersistency(for: reduceConfirmationsCell, withKey: DefaultKey.reduceConfirmations)

        case "EnableTestingCell":
            handleAccessoryTypeAndPersistency(for: enableTestingCell, withKey: DefaultKey.enableTestingMode)
            alertUserWhenChangingSettings()

        case "RecommendationCell":
            shareAppWithFriends()

        case "VersionCell", "CoffeeButtonCell", "AboutAppCell":
            break

        default:
            track("UNKNOWN DEFAULT: Reuse identifier in Settings table")
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
            track("UNKNOWN DEFAULT: Segue in Settings")
        }
    }


    // MARK: Helper

    private func shareAppWithFriends() {
        guard let urlStr = URL(string: AppParameter.appUrl ) else {
            track("GUARD FAILED: App url could not be converted")
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

    private func handleAccessoryTypeAndPersistency(for cell: UITableViewCell, withKey key: String) {

        let isNoneAccessoryType = (cell.accessoryType == .none)

        cell.accessoryType = isNoneAccessoryType ? .checkmark : .none
        UserDefaults.standard.setValue(isNoneAccessoryType, forKey: key)
    }

    private func alertUserWhenChangingSettings() {

        popupAlert(title: "Please close and restart app for modified settings becoming active.", message: "", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
    }
}
