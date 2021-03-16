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

    typealias SaveKey = AppDelegate.DefaultKey

    /// Key used for assigning TemporaryDataItem in CoreData to this view controller
    private let addNewNoteKey: String = "AddNewNoteKey"

    private func presentTimeMessage(_ period: String) -> String {
        return "Will be presented in: " + period
    }


    // MARK: Outlets

    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var textView: CustomTextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var presentInTextField: UITextField!
    
    @IBOutlet weak var imageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!

    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!


    // MARK: Properties

    var temporaryNote: TemporaryDataItem!

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<TemporaryDataItem>!

    /// Date formatter for the displayed dates
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    /// Pickerview presented as keyboard for presenting period textfield
    var periodPickerBoard: PeriodPicker!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Fetch object with temporary note
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


    // MARK: Actions

    @IBAction func imageButtonPressed(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        pickImage(sourceType: .camera)
    }

    /// For searchButton action see segue preparation below


    @IBAction func clearButtonPressed(_ sender: Any) {
        /// Disallow user to edit during clear action
        toggleUserInterface(enable: false)

        /// Get confirmation by user to clear unsaved contents
        popupAlert(title: "Your unsaved note will be deleted permanently.", message: "", alertStyle: .actionSheet, actionTitles: ["Clear", "Cancel"], actionStyles: [.destructive, .cancel], actions: [clearHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        /// Disallow user to edit during save action
        toggleUserInterface(enable: false)

        if let targetDate = DateCalculator.getTargetDate(from: periodPickerBoard) {
            popupAlert(title: "Your new inspirational note will be saved and presented on \(dateFormatter.string(from: targetDate))", message: "", alertStyle: .actionSheet, actionTitles: ["Save", "Cancel"], actionStyles: [.default, .cancel], actions: [saveHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
        } else {
            popupAlert(title: "Internal error", message: "Cannot compute future date. Try to set a different time period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [cancelActionSheetHandler(alertAction:)])
        }
    }

    @IBAction func cancelPickerPressed(_ sender: UIBarButtonItem?) {
        presentInTextField.resignFirstResponder()
    }

    @IBAction func donePickerPressed(_ sender: UIBarButtonItem?) {
        presentInTextField.resignFirstResponder()

        let periodString = DateCalculator.getPeriodString(from: periodPickerBoard)
        presentInTextField.text = presentTimeMessage(periodString)
    }


    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToFlickrSearch" {
            let navigationController = segue.destination as! UINavigationController
            let flickrController = navigationController.topViewController as! FlickrSearchCollectionViewController

            flickrController.returnImage = { imageData in

                self.imageView.image = UIImage(data: imageData)

                /// Save image data in temporary note
                self.temporaryNote?.image = imageData
                self.dataController.saveBackgroundContext()
            }
        }
    }


    // MARK: Setup

    private func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<TemporaryDataItem> = TemporaryDataItem.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "objectKey == %@", addNewNoteKey)
        fetchRequest.sortDescriptors = []

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.backgroundContext, sectionNameKeyPath: nil, cacheName: "temporaryNote")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()

            switch fetchedResultsController.fetchedObjects?.count ?? 0 {
            case 0:
                // Instantiate new data item since none was found
                temporaryNote = TemporaryDataItem(context: dataController.backgroundContext)
                temporaryNote.objectKey = addNewNoteKey
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

        titleField.setUpCustomTextField(with: temporaryNote?.title, saveRoutine: { (titleString) in
            self.temporaryNote?.title = titleString
            self.dataController.saveBackgroundContext()
        })

        textView.setUpCustomTextView(with: temporaryNote?.attributedText, saveRoutine: { (attributedString) in
            self.temporaryNote?.attributedText = attributedString
            self.dataController.saveBackgroundContext()
        })

        if let imgData = temporaryNote?.image {
            imageView.image = UIImage(data: imgData)
        }

        setUpTextFieldWithPeriodPicker()

        /// Enter textfield text with period specified by last user operation
        periodPickerBoard.setRowsFromUserDefaults()
        let periodString = DateCalculator.getPeriodString(from: periodPickerBoard)
        presentInTextField.text = presentTimeMessage(periodString)
    }

    private func setUpTextFieldWithPeriodPicker() {
        periodPickerBoard = PeriodPicker()

        periodPickerBoard.delegate = periodPickerBoard
        periodPickerBoard.dataSource = periodPickerBoard

        periodPickerBoard.backgroundColor = .lightGray
        periodPickerBoard.reloadAllComponents()

        /// Link textfield to the periodpicker
        presentInTextField.inputView = periodPickerBoard

        /// Make toolbar for leaving the pickerview
        let pickerAccesssory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPickerPressed(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePickerPressed(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerAccesssory.items = [cancelButton, flexSpace, doneButton]

        presentInTextField.inputAccessoryView = pickerAccesssory
    }


    // MARK: Core functionality

    private func pickImage(sourceType: UIImagePickerController.SourceType) {

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType

            present(imagePicker, animated: true, completion: nil)

        } else {
            let sourceTypeDescription = (sourceType == .camera) ? "Camera" : "Photo library"

            popupAlert(title: "\(sourceTypeDescription) not available", message: "It seems like the requested source type cannot be used. Assert allowing usage in the settings.", alertStyle: .alert, actionTitles: ["Cancel", "Go to Settings"], actionStyles: [.cancel, .default], actions: [nil, sourceNotAvailableHandler(alertAction:)])
        }
    }

    private func saveNewItem() {

        let newItem = InspirationItem(context: dataController.viewContext)

        newItem.active = true
        newItem.creationDate = Date()
        newItem.presentingDate = DateCalculator.getTargetDate(from: periodPickerBoard)
        newItem.title = titleField.text

        /// Save text note if one was created
        if textView.text != CustomTextView.TextConstant.defaultPlaceholder {
            newItem.attributedText = textView.attributedText
        }

        /// Save image if one was selected
        if let image = imageView.image {
            newItem.image = image.jpegData(compressionQuality: 0.98)
        }

        dataController.saveViewContext()

        /// Save period selection each time user confirms by saving a note
        periodPickerBoard.saveSelectedRowsToUserDefaults()
    }


    // MARK: Handler

    func clearHandler(alertAction: UIAlertAction) {
        clearUserInterface()

        /// Reenable user interface for further editing
        toggleUserInterface(enable: true)
    }

    func cancelActionSheetHandler(alertAction: UIAlertAction) {
        /// Reenable user interface for further editing
        toggleUserInterface(enable: true)
    }

    func saveHandler(alertAction: UIAlertAction) {
        saveNewItem()

        /// Clear and reenable user interface for a further note
        clearUserInterface()
        toggleUserInterface(enable: true)
    }

    func sourceNotAvailableHandler(alertAction: UIAlertAction) {
        print("Go to settings pressed")
        // @todo implement Go to settings
    }


    // MARK: User Interface

    private func toggleUserInterface(enable: Bool) {
        titleField.isEnabled = enable
        textView.isUserInteractionEnabled = enable
        presentInTextField.isEnabled = enable

        imageButton.isEnabled = enable
        cameraButton.isEnabled = enable
        searchButton.isEnabled = enable

        clearButton.isEnabled = enable
        saveButton.isEnabled = enable
    }

    private func clearUserInterface() {
        titleField.clearTextField()
        textView.clearTextView()
        imageView.image = nil

        /// Clear also temporary note from managed object context
        temporaryNote.title = nil
        temporaryNote.attributedText = nil
        temporaryNote.image = nil

        dataController.saveBackgroundContext()
    }
}


// MARK: UIImagePickerController Delegation

extension AddNewNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.image = uiImage

            // Save image data in temporary note
            temporaryNote?.image = uiImage.jpegData(compressionQuality: 0.98)
            dataController.saveBackgroundContext()

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
