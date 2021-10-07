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
    @IBOutlet weak var searchButton: UIBarButtonItem!

    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch temporary note object
        setUpFetchedResultsController()

        setUpUserInterface()
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

    @IBAction func imageButtonPressed(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        pickImage(sourceType: .camera)
    }

    // For searchButton action see segue preparation below


    @IBAction func clearButtonPressed(_ sender: Any) {
        /// Disallow user to edit during clear action
        toggleUserInterface(enable: false)

        /// Get confirmation by user to clear unsaved contents
        popupAlert(title: "Your unsaved note will be deleted permanently.", message: "", alertStyle: .actionSheet, actionTitles: ["Clear", "Cancel"], actionStyles: [.destructive, .cancel], actions: [clearHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        // Disallow user to edit during save action
        toggleUserInterface(enable: false)

        guard let selectedPeriod = selectedPeriod,
              selectedPeriod.isValid() else {
            popupAlert(title: "Period incomplete or unset", message: "It seems like you have not entered a valid time duration for this note to come back into focus. Try to set a new period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [cancelActionSheetHandler(alertAction:)])
            return
        }

        // Compute target date by selected period
        target = selectedPeriod.computeDeliveryDate(given: Date())

        guard let targetDate = targetDate else {
            track("GUARD FAILED: Target date unset")
            return
        }

        if isNoteEmpty() {
            popupAlert(title: "Empty note", message: "It seems like you have not entered a title or some descriptional elements (like text or image).", alertStyle: .alert, actionTitles: ["Save anyway", "Cancel"], actionStyles: [.default, .cancel], actions: [saveHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
        } else {
            let dateStr = DateFormatting.declarationFormat.string(from: targetDate)
            popupAlert(title: "Your new inspirational note will be saved and presented on \(dateStr)", message: "", alertStyle: .actionSheet, actionTitles: ["Save", "Cancel"], actionStyles: [.default, .cancel], actions: [saveHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ReuseIdentifier.forSegue.addNewNoteToImageSearch {
            let navigationController = segue.destination as! UINavigationController
            let flickrController = navigationController.topViewController as! FlickrSearchCollectionViewController

            flickrController.returnImage = { imageData in

                self.imageView.isHidden = false
                self.imageView.image = UIImage(data: imageData)

                /// Save image data in temporary note
                self.temporaryNote?.image = imageData
                self.dataController.saveBackgroundContext()
            }
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

    private func setUpUserInterface() {

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
        periodSetterView.setup(preLabelText: "Will be presented in ", postLabelText: ".") { self.selectedPeriod = $0 }
        periodSetterView.buttonText = collectDefaultPeriod()
    }


    // MARK: - Private Core API

    private func pickImage(sourceType: UIImagePickerController.SourceType) {

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
        if textView.text != TextParameter.textPlaceholder {
            newItem.attributedText = textView.attributedText
        }

        /// Save image if one was selected
        if let image = imageView.image {
            newItem.image = image.jpegData(compressionQuality: 0.98)
        }

        dataController.saveViewContext()

        return newItem
    }


    // MARK: - Handler

    func clearHandler(alertAction: UIAlertAction) {
        clearUserInterface()

        /// Reenable user interface for further editing
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
        LocalNotificationHandler.shared.convenienceSchedule(uuid: uuid, body: "You have an open inspiration to be managed. See what it is...", dateTime: target)

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
        searchButton.isEnabled = enable

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

    /// Retrieve user's default period setting
    private func collectDefaultPeriod() -> String? {
        let countValue = UserDefaults.standard.integer(forKey: UserKey.addNewNoteDefaultPeriod.count)
        let unitIntValue = UserDefaults.standard.integer(forKey: UserKey.addNewNoteDefaultPeriod.unit)

        selectedPeriod = ConvertibleTimeComponent(count: countValue, componentRawValue: unitIntValue)

        return selectedPeriod!.isValid() ? selectedPeriod!.description : TextParameter.nilPeriod
    }
}


// MARK: - UIImagePickerController Delegate

extension AddNewNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.isHidden = false
            imageView.image = uiImage

            /// Save image data in temporary note
            temporaryNote?.image = uiImage.jpegData(compressionQuality: 0.98)
            dataController.saveBackgroundContext()

        } else {
            popupAlert(title: "Image not found", message: "The selected image cannot be loaded into the app.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
