//
//  AddNewNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: AddNewNoteViewController: UIViewController

class AddNewNoteViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var periodPickerView: UIPickerView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var imageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var fileButton: UIBarButtonItem!

    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!


    // MARK: Properties

    var newItem: InspirationItem!

    var dataController: DataController!

    var periodPickerDelegate: PeriodPickerDelegate!
    var textNoteDelegate: TextNoteDelegate!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpPeriodPicker()

        textNoteDelegate = TextNoteDelegate()
        textView.delegate = textNoteDelegate

        clearUserInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        toggleUserInterface(enable: true)
    }


    // MARK: Actions

    @IBAction func imageButtonPressed(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        pickImage(sourceType: .camera)
    }

    @IBAction func fileButtonPressed(_ sender: Any) {
        // @todo implement file attaching
        print("File attaching still to be implemented")
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        // Get confirmation by user to clear unsaved contents
        popupAlert(title: "Are you sure to delete the unsaved note?", message: "", alertStyle: .alert, actionTitles: ["Cancel", "Delete"], actionStyles: [.cancel, .destructive], actions: [
                    { _ in },
                    { _ in
                        self.clearUserInterface()
                    }
        ])
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        toggleUserInterface(enable: false)

        guard let target = calculateTargetDate() else {
            fatalError("Cannot compute target date for representing note")
        }

        popupAlert(title: "Description finished?", message: "If so, you get reminded of your new inspiration on \(target).", alertStyle: .alert, actionTitles: ["Cancel", "OK"], actionStyles: [.cancel, .default], actions: [
                    { _ in
                        self.toggleUserInterface(enable: true)
                    },
                    { _ in
                        self.saveNewItem(targetDate: target)
                        self.saveUserDefaults()

                        self.clearUserInterface()
                        self.toggleUserInterface(enable: true)
                    }
        ])
    }


    // MARK: Setup

    private func setUpPeriodPicker() {

        periodPickerDelegate = PeriodPickerDelegate()

        periodPickerView.delegate = periodPickerDelegate
        periodPickerView.dataSource = periodPickerDelegate

        // Fetch picker rows from stored user specific values
        let pickerCountRow: Int = UserDefaults.standard.integer(forKey: AppDelegate.DefaultKey.timeCountForPicker)
        let pickerUnitRow: Int = UserDefaults.standard.integer(forKey: AppDelegate.DefaultKey.timeUnitForPicker)

        let pickerCountComponent = PeriodPickerDelegate.Constant.timeCounterComponent
        let pickerUnitComponent = PeriodPickerDelegate.Constant.timeUnitComponent

        periodPickerView.selectRow(pickerCountRow, inComponent: pickerCountComponent, animated: true)
        periodPickerView.selectRow(pickerUnitRow, inComponent: pickerUnitComponent, animated: true)

    }

    // MARK: Core functionality

    private func pickImage(sourceType: UIImagePickerController.SourceType) {

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType

            present(imagePicker, animated: true, completion: nil)

        } else {

            popupAlert(title: "\(sourceType.rawValue) not available", message: "It seems like the requested source type cannot be used. Assert to allow usage in the settings.", alertStyle: .alert, actionTitles: ["Cancel", "Go to Settings"], actionStyles: [.cancel, .default], actions: [
                        { _ in },
                        { _ in
                            print("Go to settings pressed")
                            // @todo implement Go to settings
                        }
            ])
        }
    }

    private func saveNewItem(targetDate: Date) {
        let newItem = InspirationItem(context: dataController.viewContext)
        newItem.active = true
        newItem.creationDate = Date()
        newItem.presentingDate = targetDate
        newItem.title = titleField.text
        newItem.text = textView.text
        if let image = imageView.image {
            newItem.image = image.jpegData(compressionQuality: 0.98)
        }
        // @todo store file attachments

        dataController.saveViewContext()
    }

    private func calculateTargetDate() -> Date? {

        // Retrieve selected count value from picker view, default value if picker was not changed
        let selectedPickerRawCount = periodPickerDelegate.selectedRawCount ?? UserDefaults.standard.integer(forKey: AppDelegate.DefaultKey.timeCountForPicker)

        // Retrieve selected unit from picker view, default value if picker was not changed
        let selectedPickerRawUnit = periodPickerDelegate.selectedRawUnit ?? UserDefaults.standard.integer(forKey: AppDelegate.DefaultKey.timeUnitForPicker)

        // Convert picker raw values to computable time values
        let pickerCount = selectedPickerRawCount + 1
        guard let pickerUnit = DateCalculator.DateUnit(rawValue: selectedPickerRawUnit) else {
            return nil
        }

        // Use DateCalculator to compute target date for representing note
        let dateComponents = DateCalculator.convertDateUnits2DateComponents(value: pickerCount, unit: pickerUnit)
        let targetDate = DateCalculator.addToCurrentDate(period: dateComponents)

        return targetDate
    }

    private func saveUserDefaults() {
        if let selectedRawCount = periodPickerDelegate.selectedRawCount {
            UserDefaults.standard.set(selectedRawCount, forKey: AppDelegate.DefaultKey.timeCountForPicker)
        }
        if let selectedRawUnit = periodPickerDelegate.selectedRawUnit {
            UserDefaults.standard.set(selectedRawUnit, forKey: AppDelegate.DefaultKey.timeUnitForPicker)
        }
    }


    // MARK: User Interface

    private func toggleUserInterface(enable: Bool) {
        titleField.isEnabled = enable
        textView.isUserInteractionEnabled = enable
        imageButton.isEnabled = enable
        periodPickerView.isUserInteractionEnabled = enable
        cameraButton.isEnabled = enable
        fileButton.isEnabled = false // @todo file attaching to be implemented
        saveButton.isEnabled = enable
    }

    private func clearUserInterface() {
        titleField.text = ""
        textView.text = "Enter your text note here."
        imageView.image = nil
    }
}


// MARK: UIImagePickerController Delegation

extension AddNewNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.image = image

        } else {
            // @todo error handling
            print("Image not found")
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
