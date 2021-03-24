//
//  CollectionViewFlowLayout.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 22.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: CollectionViewFlowLayout: UICollectionViewFlowLayout

class CollectionViewFlowLayout: UICollectionViewFlowLayout {

    // MARK: Properties (with defaults)

    var lineSpacing: CGFloat = 20
    var interitemSpacing: CGFloat = 10
    var itemsPerRowPortrait: CGFloat = 3
    var itemsPerRowLandscape: CGFloat = 5


    // MARK: Life cycle

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        // Item size
        /// Items per row shall depend on UI orientation
        let itemsPerRow = (UIScreen.main.bounds.height > UIScreen.main.bounds.width) ? itemsPerRowPortrait : itemsPerRowLandscape

        let padding = 2 * lineSpacing + (itemsPerRow - 1) * interitemSpacing
        let availableWidth = collectionView.bounds.width - padding
        let cellSize = availableWidth / itemsPerRow

        itemSize = CGSize(width: cellSize, height: cellSize)

        // Edge insets
        /// Use equally spaced insets
        let inset = lineSpacing

        sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

        // Spacing

        minimumLineSpacing = lineSpacing

        minimumInteritemSpacing = interitemSpacing
    }


    // MARK: Setting parameters

    func setLayoutParameters(spacing: CGFloat, itemsPerRowPortrait: Int, itemsPerRowLandscape: Int) {
        setLayoutParameters(lineSpacing: spacing, interitemSpacing: spacing, itemsPerRowPortrait: itemsPerRowPortrait, itemsPerRowLandscape: itemsPerRowLandscape)
    }

    func setLayoutParameters(lineSpacing: CGFloat, interitemSpacing: CGFloat, itemsPerRowPortrait: Int, itemsPerRowLandscape: Int) {
        self.lineSpacing = lineSpacing
        self.interitemSpacing = interitemSpacing
        self.itemsPerRowPortrait = CGFloat(itemsPerRowPortrait)
        self.itemsPerRowLandscape = CGFloat(itemsPerRowLandscape)
    }
}
