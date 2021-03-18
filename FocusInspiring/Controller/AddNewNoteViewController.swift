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

    /// Key used for assigning TemporaryDataItem in CoreData to this view controller
    private let addNewNoteKey: String = "AddNewNoteKey"


    // MARK: Outlets

    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var textView: CustomTextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var presentInTextField: PickerTextField!
    
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

    /// Data for the presented picker integrated in presentInTextField keyboard
    var periodData: PeriodData!


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
        presentInTextField.updateText()
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

        if let target = getTargetDate() {
            popupAlert(title: "Your new inspirational note will be saved and presented on \(dateFormatter.string(from: target))", message: "", alertStyle: .actionSheet, actionTitles: ["Save", "Cancel"], actionStyles: [.default, .cancel], actions: [saveHandler(alertAction:), cancelActionSheetHandler(alertAction:)])
        } else {
            popupAlert(title: "Internal error", message: "Cannot compute future date. Try to set a different time period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [cancelActionSheetHandler(alertAction:)])
        }
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
                /// Instantiate new data item since none was found
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

        let keys = [DefaultKey.timeCountForPicker, DefaultKey.timeUnitForPicker]
        periodData = PeriodData(countMax: periodCounterMaxValue, saveKeys: keys, preText: "Will be presented in: ")
        presentInTextField.setup(with: periodData)
    }


    // MARK: Core functionality

    private func pickImage(sourceType: UIImagePickerController.SourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType

        present(imagePicker, animated: true, completion: nil)
    }

    private func saveNewItem() {

        let newItem = InspirationItem(context: dataController.viewContext)

        newItem.active = true
        newItem.creationDate = Date()
        newItem.presentingDate = getTargetDate()
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


    // MARK: Helper

    private func toggleUserInterface(enable: Bool) {
        titleField.isEnabled = enable
        textView.isUserInteractionEnabled = enable
        presentInTextField.isEnabled = enable

        imageButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ? enable : false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) ? enable : false
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

    private func getTargetDate() -> Date? {
        let selection = presentInTextField.inputPicker.selectedRows()

        return periodData.computeTargetDateBy(selected: selection)
    }
}


// MARK: UIImagePickerController Delegation

extension AddNewNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

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
