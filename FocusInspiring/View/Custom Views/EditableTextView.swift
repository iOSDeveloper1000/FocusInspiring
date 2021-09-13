//
//  EditableTextView.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 03.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: EditableTextView: UITextView, UITextViewDelegate

class EditableTextView: UITextView, UITextViewDelegate {

    // MARK: - Properties

    /// Routine set by caller of this class to save contents at certain points
    var saveContentChanges: ((NSAttributedString) -> Void)?

    private var attributedPlaceholder: NSAttributedString {
        let placeholder = NSMutableAttributedString(string: TextParameter.textPlaceholder)

        let range = NSRange(location: 0, length: placeholder.string.utf16.count)
        placeholder.setAttributes([.font: UIFont.preferredFont(forTextStyle: .subheadline)], range: range)

        return placeholder
    }


    // MARK: - Public

    /**
     Setup method for editable textviews.

     - Parameter with: Attributed string that will be displayed in the textview.
     - Parameter saveRoutine: Optional closure that will be called on releasing input mode and format changes.
     */
    public func setup(with initText: NSAttributedString?, saveRoutine: ((NSAttributedString) -> Void)?) {
        delegate = self

        saveContentChanges = saveRoutine
        setUpKeyboardToolbar()

        // Set text to given attributed string else to placeholder
        if let initText = initText {
            attributedText = initText
        } else {
            clear()
        }
    }

    /**
     Reset text in textview to placeholder text.

     Formatting will be default one.
     */
    public func clear() {

        attributedText = attributedPlaceholder
        adjustsFontForContentSizeCategory = true
        textColor = UIColor.lightGray
    }

    /**
     Returns _true_, if textview is empty or holding placeholder text, otherwise _false_.
     */
    public func isEmpty() -> Bool {

        return text.isEmpty || (text == TextParameter.textPlaceholder)
    }


    // MARK: - TextView Delegate

    func textViewDidBeginEditing(_ textView: UITextView) {

        // Empty the placeholder text
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        saveContentChanges?(textView.attributedText)

        guard let textView = textView as? EditableTextView else { return }

        // Reset to placeholder text if empty
        if textView.attributedText.string.isEmpty {
            textView.clear()
        }
    }


    // MARK: - Toolbar Actions

    @IBAction func boldPressed(sender: UIBarButtonItem) {
        let boldSystemFont = UIFont.boldSystemFont(ofSize: 17)
        let font = UIFontMetrics(forTextStyle: .body).scaledFont(for: boldSystemFont)

        addFormatAttributes([.font: font], in: selectedRange)
    }

    @IBAction func italicPressed(sender: UIBarButtonItem) {
        let italicSystemFont = UIFont.italicSystemFont(ofSize: 17)
        let font = UIFontMetrics(forTextStyle: .body).scaledFont(for: italicSystemFont)

        addFormatAttributes([.font: font], in: selectedRange)
    }

    @IBAction func underlinePressed(sender: UIBarButtonItem) {
        addFormatAttributes([.underlineStyle: 1], in: selectedRange)
    }

    @IBAction func highlightPressed(sender: UIBarButtonItem) {
        addFormatAttributes([.backgroundColor: UIColor.yellow,
                             .foregroundColor: UIColor.black],
                            in: selectedRange)
    }

    @IBAction func clearFormattingPressed(sender: UIBarButtonItem) {
        addFormatAttributes([:], in: selectedRange)
    }

    @IBAction func donePressed(sender: UIBarButtonItem) {
        resignFirstResponder()
    }


    // MARK: - Helper

    private func setUpKeyboardToolbar() {

        let boldItem = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: self, action: #selector(boldPressed(sender:)))
        let italicItem = UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: self, action: #selector(italicPressed(sender:)))
        let underlineItem = UIBarButtonItem(image: UIImage(systemName: "underline"), style: .done, target: self, action: #selector(underlinePressed(sender:)))

        let highlightItem = UIBarButtonItem(image: UIImage(systemName: "highlighter"), style: .plain, target: self, action: #selector(highlightPressed(sender:)))
        let clearFormatItem = UIBarButtonItem(image: UIImage(systemName: "clear"), style: .plain, target: self, action: #selector(clearFormattingPressed(sender:)))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(sender:)))

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 44))
        toolbar.items = [flexSpace, boldItem, italicItem, underlineItem, flexSpace, highlightItem, flexSpace, clearFormatItem, flexSpace, flexSpace, doneButton]

        inputAccessoryView = toolbar
    }

    /**
     Add format attributes to specified text range or reset formatting.

     - Parameter attrs: Format attributes to be applied. If empty, formatting will be reset to default.
     - Parameter in: Range in which the attributes shall be applied.
     */
    private func addFormatAttributes(_ attrs: [NSAttributedString.Key: Any], in range: NSRange) {
        let newAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString

        if attrs.count > 0 {
            newAttributedString.addAttributes(attrs, range: range)
        } else {
            // Clear formatting to app default
            newAttributedString.setAttributes([.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.label], range: range)
        }

        let selectedTextRangeCopy = selectedTextRange

        attributedText = newAttributedString
        selectedTextRange = selectedTextRangeCopy
        adjustsFontForContentSizeCategory = true

        saveContentChanges?(newAttributedString)
    }
}
