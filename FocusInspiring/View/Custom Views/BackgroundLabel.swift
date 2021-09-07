//
//  UILabel.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 26.08.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: BackgroundLabel: UILabel

public class BackgroundLabel: UILabel {

    /**
     Update message in formatted label text.
     */
    public func updateText(with msg: Message) {

        let titleRange = NSMakeRange(0, msg.title.count)

        let attributedLabel = NSMutableAttributedString(string: "\(msg.title)\n\n\(msg.body)")
        attributedLabel.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .title2), range: titleRange)

        attributedText = attributedLabel
        adjustsFontForContentSizeCategory = true
    }

    /**
     Center label aligment -- should be called from `viewDidLayoutSubviews()`.
     */
    public func centerInSuperview() {

        if let superview = superview {
            center = superview.center
        }
    }
}
