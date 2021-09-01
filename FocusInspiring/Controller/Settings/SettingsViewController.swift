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

    // MARK: - Type Definition

    private enum AlertUserForChangedSetting {
        case afterRestart
        case forFutureActions

        var messageString: String {
            switch self {
            case .afterRestart:
                return "Changed setting will become active after restart of app."
            case .forFutureActions:
                return "Changed setting will be used for all notes saved in future."
            }
        }
    }


    // MARK: - Outlets

    @IBOutlet weak var reduceConfirmationsCell: UITableViewCell!
    @IBOutlet weak var enableTestingCell: UITableViewCell!

    @IBOutlet weak var addNewDefaultPeriodLabel: EditablePeriodLabel!
    @IBOutlet weak var repeatDefaultPeriodLabel: EditablePeriodLabel!

    @IBOutlet weak var deliveryModeSwitch: UISwitch!

    @IBOutlet weak var deliverAtCustomTimeCell: UITableViewCell!
    @IBOutlet weak var deliverAtCustomTimeLabel: UILabel!
    @IBOutlet weak var customTimePicker: UIDatePicker!

    @IBOutlet weak var versionLabel: UILabel!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserSettingsSection()
        setupUserNotificationsSection()

        versionLabel.text = AppParameter.versionString
    }


    // MARK: - Actions

    @IBAction func deliveryModeSwitchValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserKey.deliverAtSaveTime)
        UserDefaults.standard.set(customTimePicker.date, forKey: UserKey.customDeliveryTime)

        // Disable custom time picker cell
        handleCustomTimePickerCell(enable: !sender.isOn)
        alertUserForChangedSetting(with: .forFutureActions)
    }

    @IBAction func customTimePickerValueChanged(sender: UIDatePicker) {
        UserDefaults.standard.set(sender.date, forKey: UserKey.customDeliveryTime)
    }


    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier else {
            track("GUARD FAILED: Selected cell not found or has no reuse identifier")
            return indexPath
        }

        let cellIdentifier = ReuseIdentifier.forTableViewCell.self

        // Handle user interaction according to selected cell
        switch identifier {
        case cellIdentifier.reduceUserQueriesSetting:
            handleAccessoryTypeAndPersistency(for: reduceConfirmationsCell, withKey: UserKey.reduceUserQueries)

        case cellIdentifier.enableTestModeSetting:
            handleAccessoryTypeAndPersistency(for: enableTestingCell, withKey: UserKey.enableTestMode)
            alertUserForChangedSetting(with: .afterRestart)

        case cellIdentifier.addNewDefaultPeriodSetting:
            addNewDefaultPeriodLabel.clearInputField()
            addNewDefaultPeriodLabel.becomeFirstResponder()

        case cellIdentifier.repeatDefaultPeriodSetting:
            repeatDefaultPeriodLabel.clearInputField()
            repeatDefaultPeriodLabel.becomeFirstResponder()

        case cellIdentifier.recommendationInfo:
            shareAppWithFriends()

        case "SegueCell", "NonSelectableCell":
            // Processed with Action or Navigation method
            break

        default:
            track("UNKNOWN DEFAULT: Reuse identifier in Settings table")
            break
        }

        return indexPath
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SettingsDetailViewController else { return }

        let segueIdentifier = ReuseIdentifier.forSegue.self

        switch segue.identifier {
        case segueIdentifier.buyCoffeeSettingToDetail:
            vc.requestedPage = "Contribution"

        case segueIdentifier.aboutInfoToDetail:
            vc.requestedPage = "About"

        default:
            track("UNKNOWN DEFAULT: Segue in Settings")
        }
    }


    // MARK: - Setup

    private func setupUserSettingsSection() {
        // Retrieve user settings
        reduceConfirmationsCell.accessoryType = UserDefaults.standard.bool(forKey: UserKey.reduceUserQueries) ? .checkmark : .none
        enableTestingCell.accessoryType = UserDefaults.standard.bool(forKey: UserKey.enableTestMode) ? .checkmark : .none

        // Setup labels for user default periods
        addNewDefaultPeriodLabel.text = collectUserDefaultPeriod(for: UserKey.addNewNoteDefaultPeriod)
        repeatDefaultPeriodLabel.text = collectUserDefaultPeriod(for: UserKey.repeatNoteDefaultPeriod)

        addNewDefaultPeriodLabel.onValueConfirm = {
            self.updateUserDefaultPeriod(with: $0, for: UserKey.addNewNoteDefaultPeriod)
            self.alertUserForChangedSetting(with: .afterRestart)
        }
        repeatDefaultPeriodLabel.onValueConfirm = {
            self.updateUserDefaultPeriod(with: $0, for: UserKey.repeatNoteDefaultPeriod)
            self.alertUserForChangedSetting(with: .afterRestart)
        }
    }

    private func setupUserNotificationsSection() {
        let deliverAtSaveTime = UserDefaults.standard.bool(forKey: UserKey.deliverAtSaveTime)

        deliveryModeSwitch.isOn = deliverAtSaveTime
        handleCustomTimePickerCell(enable: !deliverAtSaveTime)

        if let storedTime = UserDefaults.standard.object(forKey: UserKey.customDeliveryTime) as? Date {
            customTimePicker.date = storedTime
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

    private func updateUserDefaultPeriod(with timeValue: ConvertibleTimeComponent?, for userKey: UserKey.PeriodValueKeyType) {
        guard let timeValue = timeValue else {
            track("GUARD FAILED: Selected default period is nil")
            return
        }

        // Store user selected values persistently in UserDefaults
        UserDefaults.standard.set(timeValue.count, forKey: userKey.count)
        UserDefaults.standard.set(timeValue.component.rawValue, forKey: userKey.unit)
    }

    private func handleCustomTimePickerCell(enable: Bool) {

        deliverAtCustomTimeCell.isUserInteractionEnabled = enable
        deliverAtCustomTimeLabel.isEnabled = enable
        customTimePicker.isEnabled = enable
    }

    private func alertUserForChangedSetting(with useCase: AlertUserForChangedSetting) {

        popupAlert(title: useCase.messageString, message: "", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
    }
}
