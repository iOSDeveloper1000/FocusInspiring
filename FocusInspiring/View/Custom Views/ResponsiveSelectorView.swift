//
//  ResponsiveSelectorView.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 26.07.21.
//

import UIKit


// MARK: ResponsiveSelectorView: UIInputView, ResponsiveInputView

class ResponsiveSelectorView: UIInputView, ResponsiveInputView {
    typealias ReturnValue = ConvertibleTimeComponent

    // MARK: - Properties

    override var intrinsicContentSize: CGSize {
        let targetWidth: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

        // For textfield space, height shall be greater than width of view.
        return CGSize(width: targetWidth, height: targetWidth + 44)
    }

    var printedUserInput: String? {
        updateInputFormatting()
        return formattedPeriod?.description
    }

    var convertedData: ConvertibleTimeComponent? {
        updateInputFormatting()
        return formattedPeriod
    }

    // Buffer for pressed buttons
    private var beforeLastDigitEntered: Int?
    private var lastDigitEntered: Int?
    private var timeComponentEntered: Calendar.Component?

    private var formattedPeriod: ConvertibleTimeComponent?


    // MARK: - Outlets

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var textField: UITextField!

    // 1st row of buttons
    @IBOutlet weak var button_7: UIButton!
    @IBOutlet weak var button_8: UIButton!
    @IBOutlet weak var button_9: UIButton!
    @IBOutlet weak var button_year: UIButton!

    // 2nd row of buttons
    @IBOutlet weak var button_4: UIButton!
    @IBOutlet weak var button_5: UIButton!
    @IBOutlet weak var button_6: UIButton!
    @IBOutlet weak var button_month: UIButton!

    // 3rd row of buttons
    @IBOutlet weak var button_1: UIButton!
    @IBOutlet weak var button_2: UIButton!
    @IBOutlet weak var button_3: UIButton!
    @IBOutlet weak var button_week: UIButton!

    // 4th row of buttons
    @IBOutlet weak var button_0: UIButton!
    @IBOutlet weak var button_sec: UIButton!
    @IBOutlet weak var button_min: UIButton!
    @IBOutlet weak var button_day: UIButton!


    // MARK: - Life Cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        initSubviews()
    }

    private func initSubviews() {
        // Standard initialization logic
        let nib = UINib(nibName: "ResponsiveSelectorView", bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = bounds
        contentView.clipsToBounds = true
        addSubview(contentView)

        // Custom initialization logic
        for button in [button_0, button_1, button_2, button_3, button_4, button_5, button_6, button_7, button_8, button_9, button_sec, button_min, button_day, button_week, button_month, button_year] {
            button?.layer.cornerRadius = 8
            button?.clipsToBounds = true
        }

        // Disable "SEC" and "MIN" button in normal (non-testing) mode
        if !(UserDefaults.standard.bool(forKey: UserKey.enableTestMode)) {
            button_sec.isUserInteractionEnabled = false
            button_min.isUserInteractionEnabled = false
            button_sec.setTitle("", for: .normal)
            button_min.setTitle("", for: .normal)
        }
    }


    // MARK: - Actions

    @IBAction func digitButtonTapped(_ sender: UIButton) {
        guard let digit = Int(sender.currentTitle ?? ""), digit >= 0, digit < 10 else {
            return
        }

        beforeLastDigitEntered = lastDigitEntered
        lastDigitEntered = digit

        textField.text = printedUserInput
    }

    @IBAction func secondButtonPressed(_ sender: UIButton) {
        updateComponentSelection(by: .second)
    }
    @IBAction func minuteButtonPressed(_ sender: UIButton) {
        updateComponentSelection(by: .minute)
    }
    @IBAction func dayButtonPressed(_ sender: UIButton) {
        updateComponentSelection(by: .day)
    }
    @IBAction func weekButtonPressed(_ sender: UIButton) {
        updateComponentSelection(by: .weekOfYear)
    }
    @IBAction func monthButtonPressed(_ sender: UIButton) {
        updateComponentSelection(by: .month)
    }
    @IBAction func yearButtonPressed(_ sender: UIButton) {
        updateComponentSelection(by: .year)
    }


    // MARK: - Methods

    func clearInput() {
        textField.text = ""

        beforeLastDigitEntered = nil
        lastDigitEntered = nil
        timeComponentEntered = nil
    }

    private func updateComponentSelection(by component: Calendar.Component) {
        timeComponentEntered = component

        textField.text = printedUserInput
    }

    private func updateInputFormatting() {
        let twoDigitsNumber = 10 * (beforeLastDigitEntered ?? 0) + (lastDigitEntered ?? 0)

        formattedPeriod = ConvertibleTimeComponent(count: twoDigitsNumber, calendarComponent: timeComponentEntered ?? .calendar /*dummy value*/)
    }
}
