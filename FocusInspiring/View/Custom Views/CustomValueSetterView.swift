//
//  CustomValueSetterView.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 14.07.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: CustomValueSetterView: UIView

@IBDesignable
class CustomValueSetterView: UIView {

    // MARK: - Properties

    /**
     Customized input view.
     */
    private var responsiveInputView: ResponsiveSelectorView = {
        ResponsiveSelectorView(frame: CGRect(origin: .zero, size: CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)))
    }()

    override var inputView: UIView? {
        get { responsiveInputView }
        set { responsiveInputView = newValue as! ResponsiveSelectorView }
    }

    /**
     Text field integrated in the input accessory view.
     */
    private var accessoryTextField: UITextField!

    override var inputAccessoryView: UIToolbar {
        // Setup text field at first use
        if accessoryTextField == nil {
            accessoryTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
            accessoryTextField.adjustsFontForContentSizeCategory = true
            accessoryTextField.textAlignment = .center
            accessoryTextField.placeholder = " Tap to select a time period.  "
            accessoryTextField.borderStyle = .none
            accessoryTextField.backgroundColor = .systemBackground
        }
        responsiveInputView.updateTextFieldTextBy = { self.accessoryTextField?.text = $0 }

        // Make toolbar for resigning from first responder
        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        accessory.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(inputCancelled(_:)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(inputConfirmed(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let textFieldItem = UIBarButtonItem(customView: accessoryTextField)

        accessory.items = [cancelButton, flexSpace, textFieldItem, flexSpace, doneButton]

        return accessory
    }

    override var canBecomeFirstResponder: Bool { true }

    /**
     Convenience getter and setter for the button label.
     */
    var buttonText: String? {
        get { button.titleLabel?.text }
        set { button.setTitle(newValue, for: .normal) }
    }

    var onValueConfirm: ((ConvertibleTimeComponent) -> Void)?


    // MARK: - Outlets

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var button: UIButton!
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
        let nib = UINib(nibName: "CustomValueSetterView", bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true
        addSubview(contentView)

        // Custom initialization logic
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fillSuperview()
    }


    // MARK: - Actions

    @IBAction func buttonTapped(_ sender: UIButton) {
        responsiveInputView.clearInput()

        becomeFirstResponder()
    }

    @IBAction func inputConfirmed(_ sender: UIBarButtonItem) {
        resignFirstResponder()

        onValueConfirm?(responsiveInputView.convertedData)

        let rawString = responsiveInputView.printedRawInput
        buttonText = rawString.contains("?") ? TextParameter.nilPeriod : rawString
    }

    @IBAction func inputCancelled(_ sender: UIBarButtonItem) {
        resignFirstResponder()
    }


    // MARK: - Public

    /**
     Setup method to define initial label texts.

     - Parameter preLabelText: String to be presented before the button
     - Parameter postLabelText: String to be presented after the button
     - Parameter callbackOnConfirm: Function will be called when user confirms his input
     */
    func setup(preLabelText: String? = nil, postLabelText: String? = nil, callbackOnConfirm: ((ConvertibleTimeComponent) -> Void)? = nil) {

        onValueConfirm = callbackOnConfirm

        // Update label texts
        preLabel.text = preLabelText
        postLabel.text = postLabelText

        buttonText = "???" // Unset button label -- to be set from view controller
    }
}
