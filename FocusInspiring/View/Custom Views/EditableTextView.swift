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

    // MARK: Properties

    /// Routine set by caller of this class to save contents at certain points
    var saveContentChanges: ((NSAttributedString) -> Void)?

    private var attributedPlaceholder: NSAttributedString {
        let placeholder = NSMutableAttributedString(string: TextParameter.textPlaceholder)

        let range = NSRange(location: 0, length: placeholder.string.utf16.count)
        placeholder.setAttributes([.font: UIFont.systemFont(ofSize: TextParameter.textFontSize)], range: range)

        return placeholder
    }


    // MARK: Public interface

    public func setUpCustomTextView(with initText: NSAttributedString?, saveRoutine: ((NSAttributedString) -> Void)?) {
        delegate = self

        saveContentChanges = saveRoutine
        setUpKeyboardToolbar()

        /// Initialize textview with saved attributed text if existing, else placeholder text
        if let initText = initText {
            attributedText = initText
        } else {
            clearTextView()
        }
    }

    /// Set textview to placeholder text with default formatting
    public func clearTextView() {
        attributedText = attributedPlaceholder
        textColor = UIColor.lightGray
    }

    /// Returns true if textview is empty or holding placeholder, false otherwise
    public func isEmptyText() -> Bool {
        return text.isEmpty || (text == TextParameter.textPlaceholder)
    }


    // MARK: TextView Delegation

    func textViewDidBeginEditing(_ textView: UITextView) {

        /// Empty placeholder text
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        saveContentChanges?(textView.attributedText)

        /// Reset to placeholder text
        if textView.attributedText.string.isEmpty {
            textView.attributedText = attributedPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }


    // MARK: Toolbar Actions

    @IBAction func boldPressed(sender: Any) {
        addFormatAttribute(.font, value: UIFont.boldSystemFont(ofSize: TextParameter.textFontSize), in: selectedRange)
    }

    @IBAction func italicPressed(sender: Any) {
        addFormatAttribute(.font, value: UIFont.italicSystemFont(ofSize: TextParameter.textFontSize), in: selectedRange)
    }

    @IBAction func underlinePressed(sender: Any) {
        addFormatAttribute(.underlineStyle, value: 1, in: selectedRange)
    }

    @IBAction func highlightPressed(sender: Any) {
        addFormatAttribute(.backgroundColor, value: UIColor.yellow, in: selectedRange)
    }

    @IBAction func clearFormattingPressed(sender: Any) {
        addFormatAttribute(nil, value: nil, in: selectedRange)
    }

    @IBAction func donePressed(sender: Any) {
        resignFirstResponder()
    }


    // MARK: Helper

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

    private func addFormatAttribute(_ name: NSAttributedString.Key?, value: Any?, in range: NSRange) {
        let newAttributedString = attributedText.mutableCopy() as! NSMutableAttributedString

        if let name = name {
            /// Add formatting
            newAttributedString.addAttribute(name, value: value!, range: range)
        } else {
            /// Clear formatting to app default
            newAttributedString.setAttributes([.font: UIFont.systemFont(ofSize: TextParameter.textFontSize)], range: range)
        }

        let selectedTextRangeCopy = selectedTextRange

        attributedText = newAttributedString
        selectedTextRange = selectedTextRangeCopy

        saveContentChanges?(newAttributedString)
    }
}
