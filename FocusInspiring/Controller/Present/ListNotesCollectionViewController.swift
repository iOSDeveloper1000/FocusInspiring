//
//  ListNotesCollectionViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 25.06.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: ListNotesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, Emptiable

class ListNotesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, Emptiable {

    // MARK: Properties

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    var backgroundLabel: UILabel?

    var successNotesSectionIndex: Int? /// Section index of successful terminated notes in FRC
    var activeNotesSectionIndex: Int? /// Section index of ongoing active notes in FRC


    // MARK: Outlets

    @IBOutlet weak var listControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: CollectionViewFlowLayout!

    @IBOutlet weak var collectionViewTopLayoutConstraint: NSLayoutConstraint!


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFetchedResultsController()

        collectionView.delegate = self
        collectionView.dataSource = self

        let layoutParam = LayoutParameter.ListNotesCollectionView.self
        flowLayout.setLayoutParameters(lineSpacing: layoutParam.lineSpacing, interitemSpacing: layoutParam.interitemSpacing, itemsPerRowPortrait: layoutParam.itemsPerRowPortrait, itemsPerRowLandscape: layoutParam.itemsPerRowLandscape)

        collectionView.collectionViewLayout = flowLayout
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpFetchedResultsController()

        /// Select List of Glory as default and primary view
        navigationItem.title = TextParameter.Title.listOfSuccess
        listControl.selectedSegmentIndex = 0

        collectionView.reloadData()
        flowLayout?.invalidateLayout()

        listControl.isUserInteractionEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        listControl.isUserInteractionEnabled = false

        fetchedResultsController = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard tabBarController?.selectedIndex == 3 else { return }

        /// Hide segmented control in landscape orientation
        let isOrientationPortrait = UIScreen.isDeviceOrientationPortrait(for: size)
        collectionViewTopLayoutConstraint?.constant = isOrientationPortrait ? 60 : 0
        listControl?.isHidden = !isOrientationPortrait

        flowLayout?.invalidateLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateEmptyViewLayout()
    }


    // MARK: Action

    @IBAction func listControlIndexChanged(_ sender: Any) {

        /// Disable segmented control to change during reload of collection view
        listControl.isUserInteractionEnabled = false

        let titleStruct = TextParameter.Title.self
        navigationItem.title = (listControl.selectedSegmentIndex == 1) ? titleStruct.listOfActiveNotes : titleStruct.listOfSuccess

        collectionView.reloadData()

        /// Enable segmented control again
        listControl.isUserInteractionEnabled = true
    }


    // MARK: Setup

    private func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

        /// No predicate used since all notes shall be loaded

        let sectionSortDescriptor = NSSortDescriptor(key: "active", ascending: true)
        let presentingSortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: false)

        fetchRequest.sortDescriptors = [sectionSortDescriptor, presentingSortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: "active", cacheName: "listOfAllSavedNotes")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // @todo INFORM USER WITH A POP-UP
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }


    // MARK: CollectionView Data Source & Delegation

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let countSections = fetchedResultsController.sections?.count else {
            track("GUARD FAILED: FRC has no sections")
            return 1
        }

        let selectedSegment = listControl.selectedSegmentIndex
        var emptyMessage: EmptyViewLabelMessage? = (selectedSegment == 1) ? EmptyViewLabel.activeNotesList : EmptyViewLabel.successList


        /// Reset section indices
        successNotesSectionIndex = nil /// nil = empty section for success entries
        activeNotesSectionIndex = nil /// nil = empty section for active entries

        switch countSections {
        case 0:
            /// emptyMessage according to selected segment will be presented
            break

        case 1:
            let sectionValue = fetchedResultsController.sections?[0].name /// Value for key 'active'
            let isActiveNotesSectionNonEmpty: Bool = (sectionValue == "1")

            /// Set section index of displayed section
            isActiveNotesSectionNonEmpty ? (activeNotesSectionIndex = 0) : (successNotesSectionIndex = 0)

            if isActiveNotesSectionNonEmpty ^ (selectedSegment == 0) {
                emptyMessage = nil
            }

        case 2:
            /// Successful notes as well as active notes are existing.
            successNotesSectionIndex = 0
            activeNotesSectionIndex = 1

            /// Remove empty view label
            emptyMessage = nil

        default:
            emptyMessage = nil
            track("UNKNOWN DEFAULT: More than two sections in FRC found")
            break
        }

        handleEmptyViewLabel(msg: emptyMessage)

        return countSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        var count = fetchedResultsController.sections?[section].numberOfObjects ?? 0

        let selectedSection: Int? = (listControl.selectedSegmentIndex == 1) ? activeNotesSectionIndex : successNotesSectionIndex

        if selectedSection != section {
            /// This method's call belongs to the section that shall be hidden.
            count = 0
        }

        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.inspirationalNoteCell, for: indexPath) as! InspirationalNoteCell

        let note = fetchedResultsController.object(at: indexPath)

        /// Active notes shall be shaded such that it is immediately noticeable when not the success list is presented
        let shadeThisItem: Bool = note.active

        /// Equip cell with label and (default) image
        cell.subtitle.text = (note.title ?? "").isEmpty ? "<no title>" : note.title
        cell.subtitle.textColor = shadeThisItem ? UIColor.lightGray : UIColor.label

        if let img = note.image {
            cell.imageView.image = UIImage(data: img)
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }

        cell.imageView.backgroundColor = shadeThisItem ? UIColor.gray : UIColor.clear

        cell.layoutIfNeeded()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        /// Instantiate and push viewcontroller for presenting note in detail mode
        let detailNoteVC = self.storyboard?.instantiateViewController(identifier: ReuseIdentifier.detailNoteViewController) as! DetailNoteViewController

        detailNoteVC.dataController = dataController
        detailNoteVC.note = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(detailNoteVC, animated: true)
    }

    /*func collectionView(UICollectionView, contextMenuConfigurationForItemAt: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // @opt-todo IMPLEMENT CONTEXT MENU
    }*/
}


// MARK: Extension for NSFetchedResultsControllerDelegate

extension ListNotesCollectionViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /// Empty body -- from the Documentation:
        ///     "A delegate must implement at least one of the change tracking delegate methods in order for change tracking to be enabled. Providing an empty implementation of controllerDidChangeContent(_:) is sufficient."
    }
}
