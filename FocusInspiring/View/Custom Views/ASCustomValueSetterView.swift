//
//  ASCustomValueSetterView.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 14.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: ASCustomValueSetterView: UIView

@IBDesignable
class ASCustomValueSetterView: UIView {

    // MARK: Input Properties

    // @todo REFACTOR: USE GENERIC INPUT VIEW -- CURRENTLY SPECIFIC TO EXTENDED UIPICKERVIEW
    private var pickerInput: UIPickerView?

    /// Used as input accessory view
    private var accessoryToolBar: UIToolbar?

    override var inputView: UIView? {
        get { pickerInput }
        set { pickerInput = newValue as? UIPickerView }
    }

    override var inputAccessoryView: UIToolbar? {
        get { accessoryToolBar }
        set { accessoryToolBar = newValue }
    }

    override var canBecomeFirstResponder: Bool { true }


    // MARK: View Properties

    /// The text of the valueButton label.
    var buttonText: String? {
        get { valueButton.titleLabel?.text }
        set { valueButton.setTitle(newValue, for: .normal) }
    }

    /// The font for all the view's elements.
    var commonFont: UIFont? {
        get { preLabel.font }
        set {
            guard let newValue = newValue else { return }

            preLabel.font = newValue
            postLabel.font = newValue
            valueButton.titleLabel?.font = newValue
        }
    }

    /// The fontsize for all the view's elements.
    var commonFontSize: CGFloat? {
        get { preLabel.font.pointSize }
        set {
            guard let newValue = newValue else { return }

            let newFont = UIFont.systemFont(ofSize: newValue)
            preLabel.font = newFont
            postLabel.font = newFont
            valueButton.titleLabel?.font = newFont
        }
    }

    /// The textcolor for all the view's elements.
    var commonTextColor: UIColor? {
        get { preLabel.textColor }
        set {
            guard let newValue = newValue else { return }

            preLabel.textColor = newValue
            postLabel.textColor = newValue
            valueButton.titleLabel?.textColor = newValue
        }
    }


    // MARK: Outlets

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var valueButton: UIButton!
    @IBOutlet weak var preLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!


    // MARK: Life Cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }


    private func initSubviews() {
        // Standard initialization logic
        let nib = UINib(nibName: "ASCustomValueSetterView", bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        contentView.clipsToBounds = true
        addSubview(contentView)

        // Custom initialization logic
        stackView.fillSuperview()
    }


    // MARK: Actions

    @IBAction func valueButtonTapped(_ sender: Any) {
        // Update row selection of picker
        pickerInput?.collectSelection()

        becomeFirstResponder()
    }

    @IBAction func inputConfirmed(_ sender: UIBarButtonItem?) {
        resignFirstResponder()

        // Update button and persistent values
        let picker = inputView as? UIPickerView
        picker?.saveSelection()

        updateButtonText()
    }

    @IBAction func inputCancelled(_ sender: UIBarButtonItem?) {
        resignFirstResponder()
    }


    // MARK: Public

    /**
     Setup method for specifying underlaid input view and label texts

     - Parameter inputView: View that becomes the first responder when button is tapped -- specialized to UIPickerView
     - Parameter preLabelText: String to be presented before the button text
     - Parameter postLabelText: String to be presented after the button text
     */
    func setupWith(inputView: UIPickerView, preLabelText: String? = nil, postLabelText: String? = nil) {
        self.inputView = inputView
        inputAccessoryView = createAccessoryView()

        // Update label texts
        preLabel.text = preLabelText
        postLabel.text = postLabelText

        buttonText = "???" // Value is to be set later via viewWillAppear
    }

    /// Update label text of button object with values from picker data source.
    func updateButtonText() {
        let dataSource = pickerInput?.dataSource as? PeriodData
        buttonText = dataSource?.textualRepresentation ?? "???"
    }


    // MARK: Helper

    /**
     Create a toolbar with a cancel and done button that can be used as accessory view.
     */
    private func createAccessoryView() -> UIToolbar {
        /// Make toolbar for leaving the pickerview
        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(inputCancelled(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(inputConfirmed(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        accessory.items = [cancelButton, flexSpace, doneButton]

        return accessory
    }
}
