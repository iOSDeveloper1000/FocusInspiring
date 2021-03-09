//
//  CollectionViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate

class CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Outlets

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!


    // MARK: Properties

    var dataController: DataController!

    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    private struct LayoutConstant {
        static let spacing: CGFloat = 15
        static let itemsPerRowPortrait: CGFloat = 2
        static let itemsPerRowLandscape: CGFloat = 3
    }


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFetchedResultsController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpFetchedResultsController()

        collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        flowLayout.invalidateLayout()
    }


    // MARK: Setup

    private func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

        // Get all inactive items, means being in List of Glory
        fetchRequest.predicate = NSPredicate(format: "active == FALSE")

        let sortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "inspirationSuccessList")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }


    // MARK: Collection View Delegation

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return fetchedResultsController.sections?.count ?? 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InspirationalNoteIdentifier", for: indexPath) as! InspirationalNoteCell

        let note = fetchedResultsController.object(at: indexPath)

        // Equip cell with label and (default) image
        cell.subTitle.text = note.title ?? "<no title>"

        if let img = note.image {
            cell.imageView.image = UIImage(data: img)
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        print("Segue to detail view not yet implemented")
    }
}


// MARK: Collection View Flow Layout Delegation

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Items per row shall depend on UI orientation
        let itemsPerRow = (UIScreen.main.bounds.height > UIScreen.main.bounds.width) ? LayoutConstant.itemsPerRowPortrait : LayoutConstant.itemsPerRowLandscape

        let padding = (itemsPerRow + 1) * LayoutConstant.spacing
        let availableWidth = collectionView.bounds.width - padding
        let cellSize = availableWidth / itemsPerRow

        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        // Use equally spaced insets
        let inset = LayoutConstant.spacing

        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return LayoutConstant.spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return LayoutConstant.spacing
    }
}
