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

        periodPickerDelegate = PeriodPickerDelegate()
        textNoteDelegate = TextNoteDelegate()

        periodPickerView.delegate = periodPickerDelegate
        periodPickerView.dataSource = periodPickerDelegate
        textView.delegate = textNoteDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // @todo fetch field entries from UserDefaults

        clearUserInterface()
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

        popupAlert(title: "Finished the description?", message: "If so, you get reminded of your new inspiration in \(periodPickerDelegate.selectedCount ?? 1) \(periodPickerDelegate.selectedUnit ?? "").", alertStyle: .alert, actionTitles: ["Cancel", "OK"], actionStyles: [.cancel, .default], actions: [
                    { _ in
                        self.toggleUserInterface(enable: true)
                    },
                    { _ in
                        self.saveNewItem()

                        self.clearUserInterface()
                        self.toggleUserInterface(enable: true)
                    }
        ])
    }


    // MARK: Helper

    private func saveNewItem() {
        let newItem = InspirationItem(context: dataController.viewContext)
        newItem.active = true
        newItem.creationDate = Date()
        newItem.presentingDate = Date() // @todo alert controller for asking user
        newItem.title = titleField.text
        newItem.text = textView.text
        if let image = imageView.image {
            newItem.image = image.pngData()
        }
        // @todo store file attachments

        dataController.saveViewContext()
    }

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
}


// MARK: UIImagePickerControllerDelegate

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
