//
//  DisplayNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: DisplayNoteViewController: UIViewController, NSFetchedResultsControllerDelegate

class DisplayNoteViewController: UIViewController, NSFetchedResultsControllerDelegate {

    private func presentTimeMessage(_ period: String) -> String {
        return "Further cycle for: " + period + "?"
    }

    /// Key used for assigning TemporaryDataItem in CoreData to this view controller
    private let editNotekey = "EditNoteFromDisplayKey"

    private let emptyControllerMessage = "No more inspirational notes to display this time.\n\nFeel lucky anyway! :-)"


    // MARK: Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var presentingDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var representInTextField: UITextField!
    
    @IBOutlet weak var checkmarkButton: UIBarButtonItem!
    @IBOutlet weak var repeatButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!


    // MARK: Properties

    var displayedItem: InspirationItem!
    var fetchedItems: [InspirationItem] = []

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    /// Date formatter for the displayed dates
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    /// Pickerview presented as keyboard for representing period textfield
    var periodPickerBoard: PeriodPicker!

    /// Label for displaying a message in case no more items are available
    var backgroundLabel: UILabel!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()

        setUpTextFieldWithPeriodPicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupFetchedResultsController()

        /// Display first inspirational note
        displayNextItem()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }


    // MARK: Actions

    @IBAction func checkmarkButtonPressed(_ sender: Any) {

        popupAlert(title: "Congratulations!", message: "Your inspiration will be added to your personal List of Glory.", alertStyle: .actionSheet, actionTitles: ["Add to List of Glory", "Cancel"], actionStyles: [.default, .cancel], actions: [checkmarkHandler(alertAction:), nil])
    }

    @IBAction func repeatButtonPressed(_ sender: Any) {

        if let targetDate = DateCalculator.getTargetDate(from: periodPickerBoard) {
            popupAlert(title: "Your inspirational note will be presented again on \(dateFormatter.string(from: targetDate)).", message: "", alertStyle: .actionSheet, actionTitles: ["Present again", "Cancel"], actionStyles: [.default, .cancel], actions: [repeatHandler(alertAction:), nil])
        } else {
            popupAlert(title: "Internal error", message: "Cannot compute future date. Try to set a different time period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
        }
    }

    /// For editButton action see segue preparation below

    @IBAction func deleteButtonPressed(_ sender: Any) {

        popupAlert(title: "Your note will be deleted permanently.", message: "", alertStyle: .actionSheet, actionTitles: ["Delete", "Cancel"], actionStyles: [.destructive, .cancel], actions: [deleteHandler(alertAction:), nil])
    }

    @IBAction func cancelPickerPressed(_ sender: UIBarButtonItem?) {
        representInTextField.resignFirstResponder()
    }

    @IBAction func donePickerPressed(_ sender: UIBarButtonItem?) {
        representInTextField.resignFirstResponder()

        let periodString = DateCalculator.getPeriodString(from: periodPickerBoard)
        representInTextField.text = presentTimeMessage(periodString)
    }


    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToEditNote" {
            let controller = segue.destination as! EditNoteViewController

            /// Although editNote is saved in a managed object context it won't be used for saving between sessions
            let editNote = TemporaryDataItem(context: dataController.backgroundContext)
            editNote.title = displayedItem?.title ?? ""
            editNote.attributedText = displayedItem?.attributedText ?? nil
            editNote.image = displayedItem?.image ?? nil
            editNote.objectKey = editNotekey

            controller.temporaryNote = editNote
            controller.completion = { (editConfirmed, edit) in
                if editConfirmed {
                    guard  let edit = edit else { return }

                    /// Copy back edited note
                    self.displayedItem.title = edit.title
                    self.displayedItem.attributedText = edit.attributedText
                    self.displayedItem.image = edit.image
                    self.dataController.saveViewContext()

                    /// Update screen
                    self.updateNoteOnScreen()
                }
            }
        }
    }


    // MARK: Setup

    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

        /// Get all items dated for today or earlier
        let current = Date()
        fetchRequest.predicate = NSPredicate(format: "active == TRUE AND presentingDate <= %@", current as CVarArg)

        let sortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "currentActiveNotes")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            fetchedItems = fetchedResultsController.fetchedObjects ?? []
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    private func setUpTextFieldWithPeriodPicker() {
        periodPickerBoard = PeriodPicker()

        periodPickerBoard.delegate = periodPickerBoard
        periodPickerBoard.dataSource = periodPickerBoard

        periodPickerBoard.backgroundColor = .lightGray
        periodPickerBoard.reloadAllComponents()

        /// Link textfield to the periodpicker
        representInTextField.inputView = periodPickerBoard

        /// Make toolbar for leaving the pickerview
        let pickerAccesssory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPickerPressed(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePickerPressed(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerAccesssory.items = [cancelButton, flexSpace, doneButton]

        representInTextField.inputAccessoryView = pickerAccesssory
    }


    // MARK: Core functionality

    private func displayNextItem() {

        let isItemAvailable = !fetchedItems.isEmpty

        /// Set user interface
        prepareUIForNextItem(show: isItemAvailable)

        /// Take next item out of queue if available
        displayedItem = isItemAvailable ? fetchedItems.popLast() : nil

        isItemAvailable ? updateNoteOnScreen() : nil
        isItemAvailable ? removeBackgroundMessage() : setBackgroundMessage(message: emptyControllerMessage)
    }

    /// Fill in content into the controller's view fields
    private func updateNoteOnScreen() {
        titleLabel.text = displayedItem.title
        creationDateLabel.text = "Created on \(dateFormatter.string(from: displayedItem.creationDate!))"
        presentingDateLabel.text = "Displayed on \(dateFormatter.string(from: displayedItem.presentingDate!))"
        if let imgData = displayedItem.image {
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.image = nil
        }
        textView.attributedText = displayedItem.attributedText
    }


    // MARK: Handler

    func checkmarkHandler(alertAction: UIAlertAction) {
        /// Set this item to inactive, i.e. put it to List of Glory
        displayedItem.active = false
        dataController.saveViewContext()

        displayNextItem()
    }

    func repeatHandler(alertAction: UIAlertAction) {
        /// Change date of next presentation to newly computed date
        displayedItem.presentingDate = DateCalculator.getTargetDate(from: periodPickerBoard)
        dataController.saveViewContext()

        /// Save period selection each time user confirms by saving a note
        periodPickerBoard.saveSelectedRowsToUserDefaults()

        displayNextItem()
    }

    func deleteHandler(alertAction: UIAlertAction) {
        /// Delete currently displayed note
        dataController.viewContext.delete(displayedItem)
        dataController.saveViewContext()

        displayNextItem()
    }


    // MARK: User Interface

    private func prepareUIForNextItem(show: Bool) {

        /// Enable/Disable navigationbar items
        let barButtons: [UIBarButtonItem] = [checkmarkButton, repeatButton, editButton, deleteButton]
        for barButton in barButtons {
            barButton.isEnabled = show
        }

        /// Permanently disallow editing in this controller
        textView.isUserInteractionEnabled = false

        /// Display/hide UI elements
        let subviews: [UIView] = [titleLabel, creationDateLabel, presentingDateLabel, imageView, textView, representInTextField]
        for element in subviews {
            element.isHidden = !show
        }

        if show {
            /// Enter textfield text with period specified by last user operation
            periodPickerBoard.setRowsFromUserDefaults()
            let periodString = DateCalculator.getPeriodString(from: periodPickerBoard)
            representInTextField.text = presentTimeMessage(periodString)
        }

    }

    private func setBackgroundMessage(message: String) {

        if backgroundLabel == nil {
            backgroundLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        }

        backgroundLabel.text = message
        backgroundLabel.textAlignment = .center
        backgroundLabel.textColor = .gray
        backgroundLabel.numberOfLines = 0 // Use as many lines as needed

        view.addSubview(backgroundLabel)
    }
    
    private func removeBackgroundMessage() {
        backgroundLabel?.removeFromSuperview()
    }
}
