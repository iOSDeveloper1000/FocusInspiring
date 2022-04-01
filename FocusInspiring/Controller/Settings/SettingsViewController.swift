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

    // MARK: - Types and Properties

    private enum AlertUserForChangedSetting {
        case afterRestart
        case forFutureActions

        var messageString: String {
            switch self {
            case .afterRestart:
                return "hint-changed-setting-after-restart"~
            case .forFutureActions:
                return "hint-changed-setting-for-future-actions"~
            }
        }
    }

    private enum NotifyTimeMode {
        case saveTime
        case customTime
    }

    /**
     Selected mode for delivery time of due notes.
     */
    private var selectedNotifyMode: NotifyTimeMode = .saveTime


    // MARK: - Outlets

    @IBOutlet weak var enableTestingCell: UITableViewCell!
    @IBOutlet weak var addNewDefaultPeriodLabel: EditablePeriodLabel!
    @IBOutlet weak var repeatDefaultPeriodLabel: EditablePeriodLabel!

    @IBOutlet weak var deliverAtSaveTimeCell: UITableViewCell!
    @IBOutlet weak var deliverAtCustomTimeCell: UITableViewCell!
    @IBOutlet weak var customTimePicker: UIDatePicker!

    @IBOutlet weak var versionLabel: UILabel!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserSettingsSection()
        setupUserNotificationsSection()

        versionLabel.text = AppParameter.versionString
    }


    // MARK: - Action

    @IBAction func customTimePickerValueChanged(sender: UIDatePicker) {
        UserDefaults.standard.set(sender.date, forKey: UserKey.customDeliveryTime)
    }


    // MARK: - UITableView Delegate

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier else {
            track("GUARD FAILED: Selected cell not found or has no reuse identifier")
            return indexPath
        }

        let cellIdentifier = ReuseIdentifier.forTableViewCell.self

        // Handle user interaction according to selected cell
        switch identifier {
        case cellIdentifier.enableTestModeSetting:
            handleTestModeSetting()

        case cellIdentifier.addNewDefaultPeriodSetting:
            addNewDefaultPeriodLabel.clearInputField()
            addNewDefaultPeriodLabel.becomeFirstResponder()

        case cellIdentifier.repeatDefaultPeriodSetting:
            repeatDefaultPeriodLabel.clearInputField()
            repeatDefaultPeriodLabel.becomeFirstResponder()

        case cellIdentifier.deliverNotesAtSaveTime:
            handleNotifyTimeSetting(selected: .saveTime)

        case cellIdentifier.deliverNotesAtCustomTime:
            handleNotifyTimeSetting(selected: .customTime)

        case cellIdentifier.recommendationInfo:
            shareAppWithFriends()

        default: // Cell without interaction or calling segue
            break
        }

        return indexPath
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SettingsDetailViewController else { return }

        if segue.identifier == ReuseIdentifier.forSegue.aboutInfoToDetail {
            vc.requestedPage = "About"
        }
    }


    // MARK: - Setup

    private func setupUserSettingsSection() {
        // Retrieve user settings
        enableTestingCell.accessoryType = UserDefaults.standard.bool(forKey: UserKey.enableTestMode) ? .checkmark : .none

        // Setup labels for user default periods
        addNewDefaultPeriodLabel.text = fetchUserDefaultPeriod(for: UserKey.addNewNoteDefaultPeriod)
        repeatDefaultPeriodLabel.text = fetchUserDefaultPeriod(for: UserKey.repeatNoteDefaultPeriod)

        addNewDefaultPeriodLabel.onValueConfirm = {
            self.setUserDefaultPeriod(with: $0, for: UserKey.addNewNoteDefaultPeriod)
            self.alertUserForChangedSetting(with: .afterRestart)
        }
        repeatDefaultPeriodLabel.onValueConfirm = {
            self.setUserDefaultPeriod(with: $0, for: UserKey.repeatNoteDefaultPeriod)
            self.alertUserForChangedSetting(with: .afterRestart)
        }
    }

    private func setupUserNotificationsSection() {
        let isModeSaveTime = UserDefaults.standard.bool(forKey: UserKey.deliverAtSaveTime)

        deliverAtSaveTimeCell.accessoryType = isModeSaveTime ? .checkmark : .none
        deliverAtCustomTimeCell.accessoryType = isModeSaveTime ? .none : .checkmark

        customTimePicker.isEnabled = !isModeSaveTime

        if let storedTime = UserDefaults.standard.object(forKey: UserKey.customDeliveryTime) as? Date {
            customTimePicker.date = storedTime
        }

        selectedNotifyMode = isModeSaveTime ? .saveTime : .customTime
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

    private func handleTestModeSetting() {

        let isAccessoryTypeNone = (enableTestingCell.accessoryType == .none)

        enableTestingCell.accessoryType = isAccessoryTypeNone ? .checkmark : .none
        UserDefaults.standard.setValue(isAccessoryTypeNone, forKey: UserKey.enableTestMode)

        alertUserForChangedSetting(with: .afterRestart)
    }

    private func handleNotifyTimeSetting(selected mode: NotifyTimeMode) {

        // Execute only if changed
        if mode != selectedNotifyMode {
            let isModeSaveTime = (mode == .saveTime)

            deliverAtSaveTimeCell.accessoryType = isModeSaveTime ? .checkmark : .none
            deliverAtCustomTimeCell.accessoryType = isModeSaveTime ? .none : .checkmark

            customTimePicker.isEnabled = !isModeSaveTime

            UserDefaults.standard.setValue(isModeSaveTime, forKey: UserKey.deliverAtSaveTime)

            selectedNotifyMode = mode

            alertUserForChangedSetting(with: .forFutureActions)
        }
    }

    private func fetchUserDefaultPeriod(for userKey: UserKey.PeriodValueKeyType) -> String {

        let countValue = UserDefaults.standard.integer(forKey: userKey.count)
        let unitIntValue = UserDefaults.standard.integer(forKey: userKey.unit)

        let periodValue = ConvertibleTimeComponent(count: countValue, componentRawValue: unitIntValue)

        return periodValue.isValid() ? periodValue.description : "period-unassigned"~
    }

    private func setUserDefaultPeriod(with timeValue: ConvertibleTimeComponent, for userKey: UserKey.PeriodValueKeyType) {

        if let countValue = timeValue.count,
           let unitValue = timeValue.component {
            // Store user selected values persistently
            UserDefaults.standard.set(countValue, forKey: userKey.count)
            UserDefaults.standard.set(unitValue.rawValue, forKey: userKey.unit)
        } else {
            // Store dummy values
            UserDefaults.standard.set(0 /* unset */, forKey: userKey.count)
            UserDefaults.standard.set(99 /* unset */, forKey: userKey.unit)
        }
    }

    private func alertUserForChangedSetting(with useCase: AlertUserForChangedSetting) {

        popupAlert(title: useCase.messageString, message: "", alertStyle: .alert, actionTitles: ["action-quick-confirm"~], actionStyles: [.default], actions: [nil])
    }
}
