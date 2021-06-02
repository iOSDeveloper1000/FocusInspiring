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

class DisplayNoteViewController: UIViewController, Emptiable, NSFetchedResultsControllerDelegate {

    /// Key used for assigning TemporaryDataItem in CoreData to this view controller
    private let editNotekey = "EditNoteFromDisplayKey"

    private let emptyViewTitle = "No more inspirational notes\nto display this time"
    private let emptyViewMessage = "Feel lucky anyway! :-)"


    // MARK: Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var presentingDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var representInTextField: PickerTextField!
    
    @IBOutlet weak var contentStackView: UIStackView!

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

    /// Data for the presented picker integrated in representInTextField keyboard
    var periodData: PeriodData!

    /// Label for displaying a message in case no more items are available
    var backgroundLabel: UILabel?


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpAndPerformFetch()

        setUpPickerTextField()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpAndPerformFetch()

        /// Display first inspirational note
        displayNextItem()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        /// Change to horizontal axis in landscape orientation
        contentStackView.axis = (UIScreen.main.bounds.height > UIScreen.main.bounds.width) ? .vertical : .horizontal
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateEmptyViewLayout()
    }


    // MARK: Actions

    @IBAction func checkmarkButtonPressed(_ sender: Any) {

        popupAlert(title: "Congratulations!", message: "Your inspiration will be added to your personal List of Glory.", alertStyle: .actionSheet, actionTitles: ["Add to List of Glory", "Cancel"], actionStyles: [.default, .cancel], actions: [checkmarkHandler(alertAction:), nil])
    }

    @IBAction func repeatButtonPressed(_ sender: Any) {

        if let target = getTargetDate() {
            popupAlert(title: "Your inspirational note will be presented again on \(dateFormatter.string(from: target)).", message: "", alertStyle: .actionSheet, actionTitles: ["Present again", "Cancel"], actionStyles: [.default, .cancel], actions: [repeatHandler(alertAction:), nil])
        } else {
            popupAlert(title: "Internal error", message: "Cannot compute future date. Try to set a different time period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
        }
    }

    /// For editButton action see segue preparation below

    @IBAction func deleteButtonPressed(_ sender: Any) {

        popupAlert(title: "Your note will be deleted permanently.", message: "", alertStyle: .actionSheet, actionTitles: ["Delete", "Cancel"], actionStyles: [.destructive, .cancel], actions: [deleteHandler(alertAction:), nil])
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

    private func setUpAndPerformFetch() {

        /// Perform fetches only if needed
        if fetchedItems.isEmpty {

            /// Clean up former fetches
            fetchedResultsController = nil

            let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

            /// Get all items dated for today or earlier
            fetchRequest.predicate = NSPredicate(format: "active == TRUE AND presentingDate <= %@", Date() as CVarArg)

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
    }

    private func setUpPickerTextField() {
        let keys = [DefaultKey.timeCountForPicker, DefaultKey.timeUnitForPicker]
        periodData = PeriodData(countMax: DataParameter.periodCounterMaxValue, saveKeys: keys, preText: "Further cycle for: ", postText: "?")
        representInTextField.setup(with: periodData)
    }


    // MARK: Core functionality

    private func displayNextItem() {

        /// Try further fetch before showing empty screen
        setUpAndPerformFetch()

        let isItemAvailable = !fetchedItems.isEmpty

        /// Set user interface
        prepareUIForNextItem(show: isItemAvailable)

        /// Take next item out of queue if available else popLast() will return nil
        displayedItem = fetchedItems.popLast()

        isItemAvailable ? updateNoteOnScreen() : nil
        isItemAvailable ? removeEmptyViewLabel() : setEmptyViewLabel(title: emptyViewTitle, message: emptyViewMessage)
    }

    /// Fill in content into the controller's view fields
    private func updateNoteOnScreen() {

        titleLabel.text = displayedItem.title
        creationDateLabel.text = "Created: \(dateFormatter.string(from: displayedItem.creationDate!))"
        presentingDateLabel.text = "Displayed: \(dateFormatter.string(from: displayedItem.presentingDate!))"
        if let imgData = displayedItem.image {
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.image = nil
        }
        textView.attributedText = displayedItem.attributedText
        representInTextField.updateText()
    }


    // MARK: Handler

    func checkmarkHandler(alertAction: UIAlertAction) {
        guard let uuid = displayedItem.uuid else {
            track("GUARD FAILED")
            return
        }

        /// Remove scheduled notification if applicable
        LocalNotificationHandler.shared.removePendingNotification(uuid: uuid)

        /// Set this item to inactive, i.e. put it to List of Glory
        displayedItem.active = false
        dataController.saveViewContext()

        displayNextItem()
    }

    func repeatHandler(alertAction: UIAlertAction) {
        guard let uuid = displayedItem.uuid else {
            track("GUARD FAILED")
            return
        }

        /// Change date of next presentation to newly computed date
        displayedItem.presentingDate = getTargetDate()
        dataController.saveViewContext()

        /// Update and reschedule user notification
        LocalNotificationHandler.shared.convenienceSchedule(uuid: uuid, body: "You have an open inspiration to be managed. See what it is...", dateTime: DateComponents(calendar: Calendar.autoupdatingCurrent, second: 7)) // @todo SET CORRECT DATETIME

        displayNextItem()
    }

    func deleteHandler(alertAction: UIAlertAction) {
        guard let uuid = displayedItem.uuid else {
            track("GUARD FAILED")
            return
        }

        /// Remove scheduled notification if applicable
        LocalNotificationHandler.shared.removePendingNotification(uuid: uuid)

        /// Delete displayed note
        dataController.viewContext.delete(displayedItem)
        dataController.saveViewContext()

        displayNextItem()
    }


    // MARK: Helper

    private func prepareUIForNextItem(show: Bool) {

        /// Enable/Disable navigationbar items
        let barButtons: [UIBarButtonItem] = [checkmarkButton, repeatButton, editButton, deleteButton]
        for barButton in barButtons {
            barButton.isEnabled = show
        }

        /// Display/hide UI elements
        let subviews: [UIView] = [titleLabel, creationDateLabel, presentingDateLabel, imageView, textView, representInTextField]
        for element in subviews {
            element.isHidden = !show
        }

        /// Enter textfield text with period specified by last user operation
        show ? representInTextField.updateText() : nil
    }

    private func getTargetDate() -> Date? {
        let selection = representInTextField.inputPicker.selectedRows()

        return periodData.computeTargetDateBy(selected: selection)
    }
}
