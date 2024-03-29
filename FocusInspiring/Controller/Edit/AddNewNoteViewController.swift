//
//  AddNewNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: AddNewNoteViewController: UIViewController, NSFetchedResultsControllerDelegate

class AddNewNoteViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties

    var temporaryNote: TemporaryDataItem!

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<TemporaryDataItem>!

    var selectedPeriod: ConvertibleTimeComponent? // Written by closure

    /// Target date for future display of note in DateComponents
    var target: DateComponents?

    /// Target date for future display of note
    var targetDate: Date? {
        guard let target = target else { return nil }

        return Calendar.current.date(from: target)
    }


    // MARK: - Outlets

    @IBOutlet weak var titleField: EditableTextField!
    @IBOutlet weak var textView: EditableTextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var periodSetterView: CustomValueSetterView!

    @IBOutlet weak var imageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch temporary note object
        setUpFetchedResultsController()

        setupUserInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpFetchedResultsController()

        toggleUserInterface(enable: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }


    // MARK: - Actions

    @IBAction func imageButtonPressed(_ sender: UIBarButtonItem) {
        replaceImage(sourceType: .photoLibrary)
    }

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        replaceImage(sourceType: .camera)
    }

    @IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
        // Disallow user to edit during clear action
        toggleUserInterface(enable: false)

        // Get confirmation by user for clearing unsaved contents
        popupAlert(title: "alert-title-delete-temporary-note"~, message: "", alertStyle: .actionSheet, actionTitles: ["action-delete-confirm"~, "action-cancel"~], actionStyles: [.destructive, .cancel], actions: [clearHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
    }

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        // Disallow user to edit during save action
        toggleUserInterface(enable: false)

        guard let selectedPeriod = selectedPeriod,
              selectedPeriod.isValid() else {
            popupAlert(title: "alert-title-period-incomplete"~, message: "alert-message-period-incomplete"~, alertStyle: .alert, actionTitles: ["action-quick-confirm"~], actionStyles: [.default], actions: [cancelActionSheetHandler(alertAction:)])
            return
        }

        // Compute target date by selected period
        target = selectedPeriod.computeDeliveryDate(given: Date())

        guard let targetDate = targetDate else {
            track("GUARD FAILED: Target date unset")
            return
        }

        if isNoteEmpty() {
            popupAlert(title: "alert-title-note-incomplete"~, message: "alert-message-note-incomplete"~, alertStyle: .alert, actionTitles: ["action-save-note-incomplete"~, "action-cancel"~], actionStyles: [.default, .cancel], actions: [saveHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
        } else {
            let dateString = DateFormatting.declarationFormat.string(from: targetDate)
            popupAlert(title: "action-title-save-note"~dateString, message: "", alertStyle: .actionSheet, actionTitles: ["action-save-confirm"~, "action-cancel"~], actionStyles: [.default, .cancel], actions: [saveHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
        }
    }


    // MARK: - Setup

    private func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<TemporaryDataItem> = TemporaryDataItem.fetchRequest()

        let objectIdentifier = ReuseIdentifier.forObjectKey.restoreTmpNoteInAddNew
        fetchRequest.predicate = NSPredicate(format: "objectKey == %@", objectIdentifier)
        fetchRequest.sortDescriptors = []

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.backgroundContext, sectionNameKeyPath: nil, cacheName: "temporaryNote")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()

            switch fetchedResultsController.fetchedObjects?.count ?? 0 {
            case 0:
                /// Instantiate new data item since none was found
                temporaryNote = TemporaryDataItem(context: dataController.backgroundContext)
                temporaryNote.objectKey = objectIdentifier
                dataController.saveBackgroundContext()
            case 1:
                temporaryNote = fetchedResultsController.fetchedObjects![0]
            default:
                fatalError("The fetch for an AddNewNote data item delivered multiple objects")
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    private func setupUserInterface() {

        // Setup title field
        titleField.setUpCustomTextField(with: temporaryNote?.title, saveRoutine: { (titleString) in
            self.temporaryNote?.title = titleString
            self.dataController.saveBackgroundContext()
        })

        // Setup text view
        textView.setup(with: temporaryNote?.attributedText, saveRoutine: { (attributedString) in
            self.temporaryNote?.attributedText = attributedString
            self.dataController.saveBackgroundContext()
        })

        // Setup image view
        if let imgData = temporaryNote?.image {
            imageView.isHidden = false
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.isHidden = true
        }

        // Setup period setter view and initialize button with user default value
        periodSetterView.setup(preLabelText: "label-present-note"~, postLabelText: ".") { self.selectedPeriod = $0 }
        periodSetterView.buttonText = collectDefaultPeriod()
    }


    // MARK: - Private Core API

    private func replaceImage(sourceType: UIImagePickerController.SourceType) {

        if imageView.image != nil {
            popupAlert(title: "alert-title-replace-image"~, message: "alert-message-replace-image"~, alertStyle: .alert, actionTitles: ["action-overwrite-image"~, "action-cancel"~], actionStyles: [.destructive, .cancel], actions: [{ _ in self.pickNewImage(sourceType: sourceType) }, nil]
            )
        } else {
            pickNewImage(sourceType: sourceType)
        }
    }

    private func pickNewImage(sourceType: UIImagePickerController.SourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType

        present(imagePicker, animated: true, completion: nil)
    }

    private func saveNewItem() -> InspirationItem? {
        guard let targetDate = targetDate else {
            track("GUARD FAILED: Target date not computed")
            return nil
        }

        let newItem = InspirationItem(context: dataController.viewContext)

        newItem.active = true
        newItem.title = titleField.text

        // .uuid and .creationDate are set automatically
        newItem.presentingDate = targetDate

        // Save text note if one was created
        if textView.text != "add-new-text-placeholder"~ {
            newItem.attributedText = textView.attributedText
        }

        // Save image if one was selected
        if let image = imageView.image {
            newItem.image = image.jpegData(compressionQuality: 0.98)
        }

        dataController.saveViewContext()

        return newItem
    }


    // MARK: - Handler

    func clearHandler(alertAction: UIAlertAction) {
        clearUserInterface()

        // Reenable user interface for further editing
        toggleUserInterface(enable: true)
    }

    func cancelActionSheetHandler(alertAction: UIAlertAction) {
        // Reenable user interface for further editing
        toggleUserInterface(enable: true)
    }

    func saveHandler(alertAction: UIAlertAction) {
        let newItem = saveNewItem()

        guard let uuid = newItem?.uuid else {
            track("GUARD FAILED: UUID not set")
            return
        }
        guard let target = target else {
            track("GUARD FAILED: Target in DateComponents not set")
            return
        }

        // Add and schedule local notification
        LocalNotificationHandler.shared.convenienceSchedule(uuid: uuid, body: "notification-message-general"~, dateTime: target)

        // Clear and reenable user interface for a further note
        clearUserInterface()
        toggleUserInterface(enable: true)
    }


    // MARK: - Helper

    /**
     Check whether user-entered note is empty

     Empty note is defined here as:
     - empty title OR
     - NO image AND NO text note entered
     */
    private func isNoteEmpty() -> Bool {
        guard let titleText = titleField.text else {
            track("GUARD FAILED: Title text is nil")
            return true
        }

        return titleText.isEmpty || (imageView.image == nil && textView.isEmpty())
    }

    private func toggleUserInterface(enable: Bool) {
        titleField.isEnabled = enable
        textView.isEditable = enable
        periodSetterView.isUserInteractionEnabled = enable

        // Toolbar button items
        imageButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ? enable : false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) ? enable : false

        // Navigation bar button items
        clearButton.isEnabled = enable
        saveButton.isEnabled = enable
    }

    private func clearUserInterface() {
        titleField.clearTextField()
        textView.clear()

        imageView.isHidden = true
        imageView.image = nil

        // Clear temporary note from managed object context as well
        temporaryNote.title = nil
        temporaryNote.attributedText = nil
        temporaryNote.image = nil

        dataController.saveBackgroundContext()
    }

    /**
     Retrieve user's default period setting.
     */
    private func collectDefaultPeriod() -> String? {
        let countValue = UserDefaults.standard.integer(forKey: UserKey.addNewNoteDefaultPeriod.count)
        let unitIntValue = UserDefaults.standard.integer(forKey: UserKey.addNewNoteDefaultPeriod.unit)

        selectedPeriod = ConvertibleTimeComponent(count: countValue, componentRawValue: unitIntValue)

        return selectedPeriod!.isValid() ? selectedPeriod!.description : "period-unassigned"~
    }
}


// MARK: - UIImagePickerController Delegate

extension AddNewNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.isHidden = false
            imageView.image = uiImage

            // Save image data to a temporary note
            temporaryNote?.image = uiImage.jpegData(compressionQuality: 0.98)
            dataController.saveBackgroundContext()

        } else {
            popupAlert(title: "alert-title-missing-image-data"~, message: "alert-message-missing-image-data"~, alertStyle: .alert, actionTitles: ["action-quick-confirm"~], actionStyles: [.default], actions: [nil])
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
