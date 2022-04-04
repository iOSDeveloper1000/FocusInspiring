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
        let targetSize: CGFloat = min(UIScreen.lengthShortEdge, LayoutParameter.maxWidthInputView)

        return CGSize(width: targetSize, height: targetSize)
    }

    /**
     User input converted to a readable string.
     */
    var printedRawInput: String {
        updateInput()

        return formattedPeriod.description
    }

    /**
     User input converted to a computable value object.
     */
    var convertedData: ConvertibleTimeComponent {
        updateInput()
        return formattedPeriod
    }

    /**
     Called on every text update in order to print a new text string.
     */
    var updateTextFieldTextBy: ((String) -> Void)?


    // Buffers for pressed buttons

    private var beforeLastDigitEntered: Int?
    private var lastDigitEntered: Int?
    private var timeComponentEntered: Calendar.Component?

    private var formattedPeriod = ConvertibleTimeComponent()


    // MARK: - Outlets

    @IBOutlet var contentView: UIView!

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

        // Set button titles with localization
        button_sec.setTitle("button-sec-title"~, for: .normal)
        button_min.setTitle("button-min-title"~, for: .normal)
        button_day.setTitle("button-day-title"~, for: .normal)
        button_week.setTitle("button-week-title"~, for: .normal)
        button_month.setTitle("button-month-title"~, for: .normal)
        button_year.setTitle("button-year-title"~, for: .normal)

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

        updateTextFieldTextBy?(printedRawInput)
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

    /**
     Clears the complete user input to the input form.
     */
    func clearInput() {
        updateTextFieldTextBy?("")

        beforeLastDigitEntered = nil
        lastDigitEntered = nil
        timeComponentEntered = nil
    }

    private func updateComponentSelection(by component: Calendar.Component) {
        timeComponentEntered = component

        updateTextFieldTextBy?(printedRawInput)
    }

    /**
     Process the previously tapped keys in order to update the internal value.

     The unit is always defined by the last unit key press. The counting number is defined by the last two number key presses, zero otherwise.
     */
    private func updateInput() {
        let doubleDigit = 10 * (beforeLastDigitEntered ?? 0) + (lastDigitEntered ?? 0)

        formattedPeriod = ConvertibleTimeComponent(count: doubleDigit, calendarComponent: timeComponentEntered)
    }
}
