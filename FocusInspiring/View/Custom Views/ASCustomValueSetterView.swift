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

    // MARK: - Input Properties

    /// Used as customized input view
    private var responsiveInputView: ResponsiveSelectorView?

    /// Used as input accessory view
    private var accessoryToolBar: UIToolbar?

    override var inputView: UIView? {
        get { responsiveInputView }
        set { responsiveInputView = newValue as? ResponsiveSelectorView }
    }

    override var inputAccessoryView: UIToolbar? {
        get { accessoryToolBar }
        set { accessoryToolBar = newValue }
    }

    override var canBecomeFirstResponder: Bool { true }

    var onValueConfirm: ((ConvertibleTimeComponent?) -> Void)?


    // MARK: - View Properties

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


    // MARK: - Outlets

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var valueButton: UIButton!
    @IBOutlet weak var preLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!


    // MARK: - Life Cycle

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


    // MARK: - Actions

    @IBAction func valueButtonTapped(_ sender: Any) {
        responsiveInputView?.clearInput()

        becomeFirstResponder()
    }

    @IBAction func inputConfirmed(_ sender: UIBarButtonItem?) {
        resignFirstResponder()

        buttonText = responsiveInputView?.printedUserInput

        onValueConfirm?(responsiveInputView?.convertedData)
    }

    @IBAction func inputCancelled(_ sender: UIBarButtonItem?) {
        resignFirstResponder()
    }


    // MARK: - Public

    /**
     Setup method for specifying underlaid input view and label texts.

     - Parameter inputView: View that becomes the first responder when button is tapped -- specialized to ResponsiveSelectorView for now
     - Parameter preLabelText: String to be presented before the button
     - Parameter postLabelText: String to be presented after the button
     - Parameter callbackOnConfirm: Function will be called when user confirms his input
     */
    func setup(inputView: ResponsiveSelectorView, preLabelText: String? = nil, postLabelText: String? = nil, callbackOnConfirm: ((ConvertibleTimeComponent?) -> Void)? = nil) {
        self.inputView = inputView
        inputAccessoryView = createAccessoryView()

        onValueConfirm = callbackOnConfirm

        // Update label texts
        preLabel.text = preLabelText
        postLabel.text = postLabelText

        buttonText = "???" // Indicates unset button
    }


    // MARK: - Helper

    // @todo REFACTOR: OVERWRITE INPUTACCESSORYVIEW
    /**
     Create a toolbar with a cancel and done button that can be used as accessory view.
     */
    private func createAccessoryView() -> UIToolbar {
        /// Make toolbar for resigning from input mode
        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(inputCancelled(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(inputConfirmed(_:)))
        //let textFieldItem = UIBarButtonItem(customView: UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 0))) @todo REDESIGN VIEW
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        accessory.items = [cancelButton, flexSpace, doneButton]

        return accessory
    }
}
