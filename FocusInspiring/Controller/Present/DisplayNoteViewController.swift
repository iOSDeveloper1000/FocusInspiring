//
//  DisplayNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: DisplayNoteViewController: UIViewController

class DisplayNoteViewController: UIViewController {

    // MARK: - Properties

    var displayedItem: InspirationItem!
    var fetchedItems: [InspirationItem] = []

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    /// Flag indicates to present FirstViewController once (presented modally)
    var presentOverlayViewInitially: Bool = true

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

    /// Label presented when no more notes are available
    var emptyViewLabel: BackgroundLabel?


    // MARK: - Outlets

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


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.bool(forKey: UserKey.doNotShowInitialViewAgain) {
            presentOverlayViewInitially = false
        }

        setUpAndPerformFetch()
        setupPeriodSetterView()

        // Setup background label
        emptyViewLabel = addBackgroundLabel(message: LabelText.EmptyView.displayNoteStack)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        displayNextItem() // next = first after (re)appear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if presentOverlayViewInitially {
            performSegue(withIdentifier: ReuseIdentifier.forSegue.initialDisplayNoteToFirst, sender: nil)
            presentOverlayViewInitially = false // present only once per app launch
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Switch to horizontal axis in landscape orientation
        contentStackView.axis = UIScreen.isDeviceOrientationPortrait() ? .vertical : .horizontal
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        emptyViewLabel?.centerInSuperview()
    }


    // MARK: - Actions

    @IBAction func checkmarkButtonPressed(_ sender: Any) {

        popupAlert(title: "Congratulations!", message: "Your inspiration will be added to your personal List of Glory.", alertStyle: .actionSheet, actionTitles: ["Add to List of Glory", "Cancel"], actionStyles: [.default, .cancel], actions: [checkmarkHandler(alertAction:), nil])
    }

    @IBAction func repeatButtonPressed(_ sender: Any) {
        guard let selectedPeriod = selectedPeriod else {
            popupAlert(title: "Period not set", message: "It seems like you have not entered a time duration for this note becoming visible again. Try to set a new period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
            return
        }

        // Compute target date by selected period
        target = selectedPeriod.computeDeliveryDate(given: Date())

        guard let targetDate = targetDate else {
            popupAlert(title: "Internal error", message: "Could not convert the given target date. Try to set a different period.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
            return
        }

        popupAlert(title: "Your inspirational note will be presented again on \(dateFormatter.string(from: targetDate)).", message: "", alertStyle: .actionSheet, actionTitles: ["Present again", "Cancel"], actionStyles: [.default, .cancel], actions: [repeatHandler(alertAction:), nil])
    }

    // For editButton action see segue preparation below

    @IBAction func deleteButtonPressed(_ sender: Any) {

        popupAlert(title: "Your note will be deleted permanently.", message: "", alertStyle: .actionSheet, actionTitles: ["Delete", "Cancel"], actionStyles: [.destructive, .cancel], actions: [deleteHandler(alertAction:), nil])
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == ReuseIdentifier.forSegue.initialDisplayNoteToFirst {
            guard let vc = segue.destination as? FirstViewController else { return }

            vc.onDismiss = { (selectedTabItem) in
                guard let tabBarController = self.tabBarController else {
                    track("GUARD FAILED: TabBarController not found")
                    return
                }
                tabBarController.selectedIndex = selectedTabItem
            }

        } else if segue.identifier == ReuseIdentifier.forSegue.displayNoteToEditNote {
            guard let vc = segue.destination as? EditNoteViewController else { return }

            /// Although editNote is saved in a managed object context it won't be used for saving between sessions yet
            let editNote = TemporaryDataItem(context: dataController.backgroundContext)
            editNote.title = displayedItem?.title ?? ""
            editNote.attributedText = displayedItem?.attributedText ?? nil
            editNote.image = displayedItem?.image ?? nil
            editNote.objectKey = ReuseIdentifier.forObjectKey.editingNote

            vc.temporaryNote = editNote
            vc.completion = { (editConfirmed, edit) in
                if editConfirmed {
                    guard let edit = edit else { return }

                    // Copy back edited note
                    self.displayedItem.title = edit.title
                    self.displayedItem.attributedText = edit.attributedText
                    self.displayedItem.image = edit.image
                    self.dataController.saveViewContext()

                    // Update screen
                    self.updateNoteOnScreen()
                }
            }
        }
    }


    // MARK: - Setup

    /**
     Instantiates fetched results controller and performs fetch.

     Does only peform a new fetch if there are no more items from a former fetch.
     */
    private func setUpAndPerformFetch() {

        // Perform a new fetch only if needed
        if fetchedItems.isEmpty {

            // @todo CHECK WHETHER CAN BE OPTIMIZED IN PERFORMANCE
            /// Clean up former fetches
            fetchedResultsController = nil

            let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

            /// Get all items dated for today or earlier
            fetchRequest.predicate = NSPredicate(format: "active == TRUE AND presentingDate <= %@", Date() as CVarArg)

            let sortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]

            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "currentActiveNotes")

            do {
                try fetchedResultsController.performFetch()
                fetchedItems = fetchedResultsController.fetchedObjects ?? []
            } catch {
                fatalError("The fetch could not be performed: \(error.localizedDescription)")
            }
        }
    }

    /**
    Setup period setter view and initialize button text.
     */
    private func setupPeriodSetterView() {

        periodSetterView.setup(inputView: responsiveSelectorView, preLabelText: "Further cycle for ", postLabelText: "?") { self.selectedPeriod = $0 }
        periodSetterView.buttonText = collectDefaultPeriod()
    }


    // MARK: - Private Core API

    private func displayNextItem() {

        // Try further fetch for due active notes if none available
        setUpAndPerformFetch()

        let isStackNonEmpty: Bool = !fetchedItems.isEmpty

        // Show or hide UI elements
        switchVisibilityOfUI(enable: isStackNonEmpty)

        // Will be nil if no more items are in queue
        displayedItem = fetchedItems.popLast()

        if isStackNonEmpty {
            updateNoteOnScreen()
        }
    }

    /**
     Updates UI elements with content of a new note.
     */
    private func updateNoteOnScreen() {

        titleLabel.text = displayedItem.title
        // @todo ADAPT DATEFORMATTER TO NEEDS
        creationDateLabel.text = "Created: \(dateFormatter.string(from: displayedItem.creationDate!))"
        presentingDateLabel.text = "Displayed: \(dateFormatter.string(from: displayedItem.presentingDate!))"
        if let imgData = displayedItem.image {
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.image = nil
        }
        textView.attributedText = displayedItem.attributedText
    }


    // MARK: - Handler

    func checkmarkHandler(alertAction: UIAlertAction) {
        guard let uuid = displayedItem.uuid else {
            track("GUARD FAILED")
            return
        }

        // Remove scheduled notification if applicable
        LocalNotificationHandler.shared.removePendingNotification(uuid: uuid)

        // Set this item to inactive, i.e. put it to success list
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


    // MARK: - Helper

    private func switchVisibilityOfUI(enable: Bool) {

        // Enable or disable items in navigation bar
        let barButtons: [UIBarButtonItem] = [checkmarkButton, repeatButton, editButton, deleteButton]
        for barButton in barButtons {
            barButton.isEnabled = enable
        }

        // Display or hide UI elements
        let subviews: [UIView] = [titleLabel, creationDateLabel, presentingDateLabel, imageView, textView, periodSetterView]
        for element in subviews {
            element.isHidden = !enable
        }

        // Display background label only if stack is empty
        emptyViewLabel?.isHidden = enable
    }

    /**
     Retrieve user's default period setting
     */
    private func collectDefaultPeriod() -> String? {

        let countValue = UserDefaults.standard.integer(forKey: UserKey.repeatNoteDefaultPeriod.count)
        let unitIntValue = UserDefaults.standard.integer(forKey: UserKey.repeatNoteDefaultPeriod.unit)

        selectedPeriod = ConvertibleTimeComponent(count: countValue, componentRawValue: unitIntValue)

        return selectedPeriod?.description
    }
}
