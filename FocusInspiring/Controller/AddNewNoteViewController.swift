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

    // Key used for assigning TemporaryDataItem in CoreData to this view controller
    private let addNewNoteKey: String = "AddNewNoteKey"


    // MARK: Outlets

    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var periodPickerView: UIPickerView!
    @IBOutlet weak var textView: CustomTextView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var imageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var fileButton: UIBarButtonItem!

    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!


    // MARK: Properties

    var targetDate: Date!

    var temporaryNote: TemporaryDataItem!

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<TemporaryDataItem>!

    var periodPickerDelegate: PeriodPickerDelegate!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFetchedResultsController() // Fetch temporary note object

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

    @IBAction func fileButtonPressed(_ sender: Any) {
        // @todo implement file attaching
        print("File attaching still to be implemented")
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        // Get confirmation by user to clear unsaved contents
        popupAlert(title: "Delete unsaved note?", message: "", alertStyle: .alert, actionTitles: ["Cancel", "Delete"], actionStyles: [.cancel, .destructive], actions: [nil, clearHandler(alertAction:)])
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        toggleUserInterface(enable: false)

        guard let target = calculateTargetDate() else {
            fatalError("Cannot compute target date for representing note")
        }

        targetDate = target

        popupAlert(title: "Note finished?", message: "If so, you get reminded of your new inspiration on \(targetDate!).", alertStyle: .alert, actionTitles: ["Cancel", "OK"], actionStyles: [.cancel, .default], actions: [abortSaveHandler(alertAction:), saveHandler(alertAction:)])
    }


    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToFlickrSearch" {
            let navigationController = segue.destination as! UINavigationController
            let flickrController = navigationController.topViewController as! FlickrSearchCollectionViewController

            flickrController.returnImage = { imageData in

                self.imageView.image = UIImage(data: imageData)

                // Save image data in temporary note
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

        setUpPeriodPicker()

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
    }

    private func setUpPeriodPicker() {

        periodPickerDelegate = PeriodPickerDelegate()

        periodPickerView.delegate = periodPickerDelegate
        periodPickerView.dataSource = periodPickerDelegate

        // Fetch picker rows from stored user specific values
        let pickerCountRow: Int = UserDefaults.standard.integer(forKey: SaveKey.timeCountForPicker)
        let pickerUnitRow: Int = UserDefaults.standard.integer(forKey: SaveKey.timeUnitForPicker)

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
            let sourceTypeDescription = (sourceType == .camera) ? "Camera" : "Photo library"

            popupAlert(title: "\(sourceTypeDescription) not available", message: "It seems like the requested source type cannot be used. Assert allowing usage in the settings.", alertStyle: .alert, actionTitles: ["Cancel", "Go to Settings"], actionStyles: [.cancel, .default], actions: [nil, sourceNotAvailableHandler(alertAction:)])
        }
    }

    private func saveNewItem(targetDate: Date) {

        let newItem = InspirationItem(context: dataController.viewContext)

        newItem.active = true
        newItem.creationDate = Date()
        newItem.presentingDate = targetDate
        newItem.title = titleField.text

        // Save text note if one was created
        if textView.text != CustomTextView.TextConstant.defaultPlaceholder {
            newItem.attributedText = textView.attributedText
        }

        // Save image if one was selected
        if let image = imageView.image {
            newItem.image = image.jpegData(compressionQuality: 0.98)
        }
        // @todo store file attachments

        dataController.saveViewContext()
    }

    private func calculateTargetDate() -> Date? {

        // Retrieve selected count value from picker view, default value if picker was not changed
        let selectedPickerRawCount = periodPickerDelegate.selectedRawCount ?? UserDefaults.standard.integer(forKey: SaveKey.timeCountForPicker)

        // Retrieve selected unit from picker view, default value if picker was not changed
        let selectedPickerRawUnit = periodPickerDelegate.selectedRawUnit ?? UserDefaults.standard.integer(forKey: SaveKey.timeUnitForPicker)

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
            UserDefaults.standard.set(selectedRawCount, forKey: SaveKey.timeCountForPicker)
        }
        if let selectedRawUnit = periodPickerDelegate.selectedRawUnit {
            UserDefaults.standard.set(selectedRawUnit, forKey: SaveKey.timeUnitForPicker)
        }
    }


    // MARK: Handler

    func clearHandler(alertAction: UIAlertAction) {
        clearUserInterface()
    }

    func abortSaveHandler(alertAction: UIAlertAction) {
        toggleUserInterface(enable: true)
    }

    func saveHandler(alertAction: UIAlertAction) {
        saveNewItem(targetDate: targetDate)
        saveUserDefaults()

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
        imageButton.isEnabled = enable
        periodPickerView.isUserInteractionEnabled = enable
        cameraButton.isEnabled = enable
        fileButton.isEnabled = false // @todo file attaching to be implemented
        saveButton.isEnabled = enable
    }

    private func clearUserInterface() {
        titleField.clearTextField()
        textView.clearTextView()
        imageView.image = nil

        // Clear also temporary note from managed object context
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
