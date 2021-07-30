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

    // MARK: - Outlets

    @IBOutlet weak var reduceConfirmationsCell: UITableViewCell!
    @IBOutlet weak var enableTestingCell: UITableViewCell!

    @IBOutlet weak var addNewDefaultPeriodLabel: EditablePeriodLabel!
    @IBOutlet weak var repeatDefaultPeriodLabel: EditablePeriodLabel!

    @IBOutlet weak var versionLabel: UILabel!
    

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = AppParameter.versionNumber

        // Retrieve user settings
        reduceConfirmationsCell.accessoryType = UserDefaults.standard.bool(forKey: DefaultKey.reduceConfirmations) ? .checkmark : .none
        enableTestingCell.accessoryType = UserDefaults.standard.bool(forKey: DefaultKey.enableTestingMode) ? .checkmark : .none

        // Setup labels for user default periods
        addNewDefaultPeriodLabel.text = collectUserDefaultPeriod(for: UserKey.addNewNoteDefaultPeriod)
        repeatDefaultPeriodLabel.text = collectUserDefaultPeriod(for: UserKey.repeatNoteDefaultPeriod)

        addNewDefaultPeriodLabel.onValueConfirm = {
            self.updateUserDefaultPeriod(with: $0, for: UserKey.addNewNoteDefaultPeriod)
            self.alertUserWhenChangingSettings()
        }
        repeatDefaultPeriodLabel.onValueConfirm = {
            self.updateUserDefaultPeriod(with: $0, for: UserKey.repeatNoteDefaultPeriod)
            self.alertUserWhenChangingSettings()
        }
    }


    // MARK: - TableView Delegation

    /// Toggle accessory type to '.checkmark' when trying to select rows for this use
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier else {
            track("GUARD FAILED: Selected cell not found or has no reuse identifier")
            return indexPath
        }

        let cellReuseIdentifier = ReuseIdentifier.ForTableViewCell.self

        switch identifier {
        case "ReduceConfirmationsCell":
            handleAccessoryTypeAndPersistency(for: reduceConfirmationsCell, withKey: DefaultKey.reduceConfirmations)

        case "EnableTestingCell":
            handleAccessoryTypeAndPersistency(for: enableTestingCell, withKey: DefaultKey.enableTestingMode)
            alertUserWhenChangingSettings()

        case cellReuseIdentifier.addNewDefaultPeriodSetting:
            addNewDefaultPeriodLabel.clearInputField()
            addNewDefaultPeriodLabel.becomeFirstResponder()

        case cellReuseIdentifier.repeatDefaultPeriodSetting:
            repeatDefaultPeriodLabel.clearInputField()
            repeatDefaultPeriodLabel.becomeFirstResponder()

        case "RecommendationCell":
            shareAppWithFriends()

        case "VersionCell", "CoffeeButtonCell", "AboutAppCell":
            break

        default:
            track("UNKNOWN DEFAULT: Reuse identifier in Settings table")
        }

        return indexPath
    }


    // MARK: - Navigation

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


    // MARK: - Helpers

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

        let isAccessoryTypeNone = (cell.accessoryType == .none)

        cell.accessoryType = isAccessoryTypeNone ? .checkmark : .none
        UserDefaults.standard.setValue(isAccessoryTypeNone, forKey: key)
    }

    private func collectUserDefaultPeriod(for userKey: UserKey.PeriodValueKeyType) -> String {

        let countValue = UserDefaults.standard.integer(forKey: userKey.count)
        let unitIntValue = UserDefaults.standard.integer(forKey: userKey.unit)

        let defaultPeriod = ConvertibleTimeComponent(count: countValue, componentRawValue: unitIntValue)

        return defaultPeriod.description
    }

    private func updateUserDefaultPeriod(with value: ConvertibleTimeComponent?, for userKey: UserKey.PeriodValueKeyType) {
        guard let value = value else {
            track("GUARD FAILED: Selected default period is nil")
            return
        }

        // Store user selected values persistently in UserDefaults
        UserDefaults.standard.set(value.count, forKey: userKey.count)
        UserDefaults.standard.set(value.component.rawValue, forKey: userKey.unit)
    }

    private func alertUserWhenChangingSettings() {

        popupAlert(title: "Changed settings may become active only after restart of app.", message: "", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
    }
}
