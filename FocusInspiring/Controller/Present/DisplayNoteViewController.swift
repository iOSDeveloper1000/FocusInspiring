//
//  DisplayNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: DisplayNoteViewController: UIViewController, Emptiable, NSFetchedResultsControllerDelegate

class DisplayNoteViewController: UIViewController, Emptiable, NSFetchedResultsControllerDelegate {

    // MARK: Properties

    var displayedItem: InspirationItem!
    var fetchedItems: [InspirationItem] = []

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    /// Date formatter for the displayed dates
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        if UserDefaults.standard.bool(forKey: UserKey.enableTestMode) {
            df.timeStyle = .medium
        }
        return df
    }()

    let responsiveSelectorView = ResponsiveSelectorView(frame: CGRect(origin: .zero, size: CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)))

    var selectedPeriod: ConvertibleTimeComponent? // Written by closure

    /// Target date for future display of note in DateComponents
    var target: DateComponents?

    /// Target date for future display of note
    var targetDate: Date? {
        guard let target = target else {
            return nil
        }
        return Calendar.current.date(from: target)
    }

    /// Displays a message in case no more items are available
    var backgroundLabel: UILabel?


    // MARK: Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var presentingDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var periodSetterView: ASCustomValueSetterView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var checkmarkButton: UIBarButtonItem!
    @IBOutlet weak var repeatButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpAndPerformFetch()

        setupPeriodSetterView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        displayNextItem() // next = first after (re)appear
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        /// Change to horizontal axis in landscape orientation
        contentStackView.axis = UIScreen.isDeviceOrientationPortrait() ? .vertical : .horizontal
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
        guard let selectedPeriod = selectedPeriod else {
            popupAlert(title: "Period not set", message: "It seems like you have not entered a time duration for this note becoming visible again. Try to set a new period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
            return
        }

        // Compute target date by selected period
        target = selectedPeriod.addSelf(to: Date())

        guard let targetDate = targetDate else {
            popupAlert(title: "Internal error", message: "Could not convert the given target date. Try to set a different period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
            return
        }

        popupAlert(title: "Your inspirational note will be presented again on \(dateFormatter.string(from: targetDate)).", message: "", alertStyle: .actionSheet, actionTitles: ["Present again", "Cancel"], actionStyles: [.default, .cancel], actions: [repeatHandler(alertAction:), nil])
    }

    /// For editButton action see segue preparation below

    @IBAction func deleteButtonPressed(_ sender: Any) {

        popupAlert(title: "Your note will be deleted permanently.", message: "", alertStyle: .actionSheet, actionTitles: ["Delete", "Cancel"], actionStyles: [.destructive, .cancel], actions: [deleteHandler(alertAction:), nil])
    }


    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ReuseIdentifier.forSegue.displayNoteToEditNote {
            let controller = segue.destination as! EditNoteViewController

            /// Although editNote is saved in a managed object context it won't be used for saving between sessions
            let editNote = TemporaryDataItem(context: dataController.backgroundContext)
            editNote.title = displayedItem?.title ?? ""
            editNote.attributedText = displayedItem?.attributedText ?? nil
            editNote.image = displayedItem?.image ?? nil
            editNote.objectKey = ReuseIdentifier.forObjectKey.editingNote

            controller.temporaryNote = editNote
            controller.completion = { (editConfirmed, edit) in
                if editConfirmed {
                    guard let edit = edit else { return }

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

    /// Setup period setter view and initialize button text with user default value if available
    private func setupPeriodSetterView() {

        periodSetterView.setup(inputView: responsiveSelectorView, preLabelText: "Further cycle for ", postLabelText: "?") { self.selectedPeriod = $0 }
        periodSetterView.buttonText = collectDefaultPeriod()
    }


    // MARK: Core private API

    private func displayNextItem() {

        /// Try further fetch before showing empty screen
        setUpAndPerformFetch()

        let isItemAvailable = !fetchedItems.isEmpty

        /// Set user interface
        prepareUIForNextItem(show: isItemAvailable)

        /// Take next item out of queue if available else popLast() will return nil
        displayedItem = fetchedItems.popLast()

        var emptyMessage: EmptyViewLabelMessage? = nil /// nil means 'remove background label'

        if isItemAvailable {
            updateNoteOnScreen()
        } else {
            /// Display message in background -- indicating empty stack
            emptyMessage = EmptyViewLabel.displayNoteStack
        }

        /// Handle background label
        handleEmptyViewLabel(msg: emptyMessage)
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
            // @todo INFORM USER
            return
        }
        guard let target = target,
              let targetDate = targetDate else {
            track("GUARD FAILED: Target date not computed")
            // @todo INFORM USER
            return
        }

        /// Change date of next presentation to newly computed date
        displayedItem.presentingDate = targetDate
        dataController.saveViewContext()

        /// Update and reschedule user notification
        LocalNotificationHandler.shared.convenienceSchedule(uuid: uuid, body: "You have an open inspiration to be managed. See what it is...", dateTime: target)

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
        let subviews: [UIView] = [titleLabel, creationDateLabel, presentingDateLabel, imageView, textView, periodSetterView]
        for element in subviews {
            element.isHidden = !show
        }
    }

    /// Retrieve user's default period setting
    private func collectDefaultPeriod() -> String? {
        let countValue = UserDefaults.standard.integer(forKey: UserKey.repeatNoteDefaultPeriod.count)
        let unitIntValue = UserDefaults.standard.integer(forKey: UserKey.repeatNoteDefaultPeriod.unit)

        selectedPeriod = ConvertibleTimeComponent(count: countValue, componentRawValue: unitIntValue)

        return selectedPeriod?.description
    }
}
