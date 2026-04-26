import UIKit

final class KeyboardViewController: UIInputViewController {
    private struct Theme {
        let keyboardBackground: UIColor
        let letterKeyBackground: UIColor
        let letterKeyText: UIColor
        let utilityKeyBackground: UIColor
        let utilityKeyText: UIColor
        let actionKeyBackground: UIColor
        let actionKeyText: UIColor
        let shadowColor: UIColor
    }

    private enum KeyboardMode {
        case letters
        case numbers
        case symbols
    }

    private enum ShiftState {
        case off
        case on
        case capsLock
    }

    private let rootStack = UIStackView()
    private let shiftButton = KeyboardButton(title: "⇧", backgroundColor: .systemGray5)
    private let backspaceButton = KeyboardButton(title: "⌫", backgroundColor: .systemGray5)
    private let globeButton = KeyboardButton(title: "🌐", backgroundColor: .systemGray5)
    private let modeButton = KeyboardButton(title: "123", backgroundColor: .systemGray5)
    private let spaceButton = KeyboardButton(title: "пробел", backgroundColor: .white)
    private let returnButton = KeyboardButton(title: "Ввод", backgroundColor: .systemBlue, titleColor: .white)
    private var keyButtons: [KeyboardButton] = []
    private var dynamicUtilityButtons: [KeyboardButton] = []
    private var keyboardMode: KeyboardMode = .letters
    private var shiftState: ShiftState = .off

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupControlActions()
        rebuildLetterKeys()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        globeButton.isHidden = !needsInputModeSwitchKey
    }

    private func setupView() {
        rootStack.axis = .vertical
        rootStack.spacing = 8
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        applyTheme()
    }

    private func rebuildLetterKeys() {
        rootStack.arrangedSubviews.forEach { row in
            rootStack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        keyButtons.removeAll()
        dynamicUtilityButtons.removeAll()

        switch keyboardMode {
        case .letters:
            rootStack.addArrangedSubview(makeLetterRow(keys: KeyboardLayout.letterRows[0], leadingInset: 0, trailingInset: 0))
            rootStack.addArrangedSubview(makeLetterRow(keys: KeyboardLayout.letterRows[1], leadingInset: 18, trailingInset: 18))
            rootStack.addArrangedSubview(makeLetterThirdRow())
        case .numbers:
            rootStack.addArrangedSubview(makeLetterRow(keys: KeyboardLayout.numberRows[0], leadingInset: 6, trailingInset: 6))
            rootStack.addArrangedSubview(makeLetterRow(keys: KeyboardLayout.numberRows[1], leadingInset: 14, trailingInset: 14))
            rootStack.addArrangedSubview(makeSymbolThirdRow(keys: KeyboardLayout.numberRows[2], leadingTitle: "#+=", trailingTitle: "⌫"))
        case .symbols:
            rootStack.addArrangedSubview(makeLetterRow(keys: KeyboardLayout.symbolRows[0], leadingInset: 6, trailingInset: 6))
            rootStack.addArrangedSubview(makeLetterRow(keys: KeyboardLayout.symbolRows[1], leadingInset: 14, trailingInset: 14))
            rootStack.addArrangedSubview(makeSymbolThirdRow(keys: KeyboardLayout.symbolRows[2], leadingTitle: "123", trailingTitle: "⌫"))
        }

        rootStack.addArrangedSubview(makeBottomRow())
        updateModeButtonTitle()
        updateReturnKeyTitle()
        updateShiftAppearance()
        applyTheme()
    }

    private func setupControlActions() {
        globeButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        globeButton.addAction(UIAction { [weak self] _ in
            self?.advanceToNextInputMode()
        }, for: .touchUpInside)
        modeButton.addAction(UIAction { [weak self] _ in
            self?.toggleMode()
        }, for: .touchUpInside)
        spaceButton.addAction(UIAction { [weak self] _ in
            self?.textDocumentProxy.insertText(" ")
        }, for: .touchUpInside)
        returnButton.addAction(UIAction { [weak self] _ in
            self?.textDocumentProxy.insertText("\n")
        }, for: .touchUpInside)
        shiftButton.addAction(UIAction { [weak self] _ in
            self?.toggleShift()
        }, for: .touchUpInside)
        backspaceButton.addAction(UIAction { [weak self] _ in
            self?.textDocumentProxy.deleteBackward()
        }, for: .touchUpInside)
    }

    private func makeRowStack(distribution: UIStackView.Distribution = .fillEqually) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = distribution
        return stack
    }

    private func makeLetterRow(keys: [String], leadingInset: CGFloat, trailingInset: CGFloat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let rowStack = makeRowStack()
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: container.topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leadingInset),
            rowStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -trailingInset),
            rowStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        for key in keys {
            let button = makeLetterButton(for: key)
            rowStack.addArrangedSubview(button)
        }

        return container
    }

    private func makeLetterThirdRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let outerStack = makeRowStack(distribution: .fill)
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(outerStack)

        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: container.topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            outerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let lettersStack = makeRowStack()
        lettersStack.translatesAutoresizingMaskIntoConstraints = false

        outerStack.addArrangedSubview(shiftButton)
        outerStack.addArrangedSubview(lettersStack)
        outerStack.addArrangedSubview(backspaceButton)

        shiftButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backspaceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        for key in KeyboardLayout.letterRows[2] {
            lettersStack.addArrangedSubview(makeLetterButton(for: key))
        }

        return container
    }

    private func makeSymbolThirdRow(keys: [String], leadingTitle: String, trailingTitle: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let outerStack = makeRowStack(distribution: .fill)
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(outerStack)

        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: container.topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            outerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let leadingButton = KeyboardButton(title: leadingTitle, backgroundColor: .systemGray5)
        leadingButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        leadingButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.keyboardMode = leadingTitle == "#+=" ? .symbols : .numbers
            self.rebuildLetterKeys()
        }, for: .touchUpInside)
        dynamicUtilityButtons.append(leadingButton)

        let lettersStack = makeRowStack()
        lettersStack.translatesAutoresizingMaskIntoConstraints = false
        for key in keys {
            lettersStack.addArrangedSubview(makeLetterButton(for: key))
        }

        let trailingButton = KeyboardButton(title: trailingTitle, backgroundColor: .systemGray5)
        trailingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        trailingButton.addAction(UIAction { [weak self] _ in
            self?.textDocumentProxy.deleteBackward()
        }, for: .touchUpInside)
        dynamicUtilityButtons.append(trailingButton)

        outerStack.addArrangedSubview(leadingButton)
        outerStack.addArrangedSubview(lettersStack)
        outerStack.addArrangedSubview(trailingButton)
        return container
    }

    private func makeBottomRow() -> UIStackView {
        let row = makeRowStack(distribution: .fill)

        let leadingButton = keyboardMode == .letters ? modeButton : KeyboardButton(title: "АБВ", backgroundColor: .systemGray5)
        leadingButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        if leadingButton !== modeButton {
            leadingButton.addAction(UIAction { [weak self] _ in
                self?.keyboardMode = .letters
                self?.rebuildLetterKeys()
            }, for: .touchUpInside)
            dynamicUtilityButtons.append(leadingButton)
        }

        if needsInputModeSwitchKey {
            globeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            row.addArrangedSubview(globeButton)
        } else {
            row.addArrangedSubview(leadingButton)
        }

        if needsInputModeSwitchKey {
            row.addArrangedSubview(leadingButton)
        }
        row.addArrangedSubview(spaceButton)
        row.addArrangedSubview(returnButton)
        returnButton.widthAnchor.constraint(equalToConstant: 92).isActive = true
        return row
    }

    private func makeLetterButton(for key: String) -> KeyboardButton {
        let title: String
        switch keyboardMode {
        case .letters:
            title = isLetterUppercase ? key.uppercased() : key
        case .numbers, .symbols:
            title = key
        }

        let button = KeyboardButton(title: title)
        button.addAction(UIAction { [weak self] _ in
            self?.insertCharacter(for: key)
        }, for: .touchUpInside)
        keyButtons.append(button)
        return button
    }

    private func insertCharacter(for key: String) {
        let output: String
        if keyboardMode == .letters {
            output = KeyboardLayout.outputForLetter(key, uppercase: isLetterUppercase)
        } else {
            output = key
        }
        textDocumentProxy.insertText(output)

        if shiftState == .on {
            shiftState = .off
            refreshKeyTitles()
        }
    }

    private func toggleShift() {
        switch shiftState {
        case .off:
            shiftState = .on
        case .on:
            shiftState = .capsLock
        case .capsLock:
            shiftState = .off
        }
        refreshKeyTitles()
    }

    private func refreshKeyTitles() {
        for button in keyButtons {
            guard let current = button.title(for: .normal) else { continue }
            let lowercased = current.lowercased()
            if keyboardMode == .letters {
                button.setTitle(isLetterUppercase ? lowercased.uppercased() : lowercased, for: .normal)
            }
        }
        updateShiftAppearance()
    }

    private func updateShiftAppearance() {
        switch shiftState {
        case .off:
            shiftButton.setTitle("⇧", for: .normal)
        case .on:
            shiftButton.setTitle("⇧", for: .normal)
        case .capsLock:
            shiftButton.setTitle("⇪", for: .normal)
        }
        applyTheme()
    }

    private var isLetterUppercase: Bool {
        shiftState != .off
    }

    private func toggleMode() {
        switch keyboardMode {
        case .letters:
            keyboardMode = .numbers
        case .numbers, .symbols:
            keyboardMode = .letters
        }
        shiftState = .off
        rebuildLetterKeys()
    }

    private func updateModeButtonTitle() {
        modeButton.setTitle("123", for: .normal)
    }

    private func updateReturnKeyTitle() {
        let title: String
        switch textDocumentProxy.returnKeyType {
        case .done:
            title = "Готово"
        case .go:
            title = "Перейти"
        case .join:
            title = "Join"
        case .next:
            title = "Далее"
        case .search:
            title = "Поиск"
        case .send:
            title = "Отпр."
        case .route:
            title = "Route"
        case .yahoo:
            title = "Yahoo"
        case .google:
            title = "Google"
        case .emergencyCall:
            title = "SOS"
        case .continue:
            title = "Прод."
        default:
            title = "Ввод"
        }
        returnButton.setTitle(title, for: .normal)
    }

    private var currentTheme: Theme {
        let isDark: Bool
        switch textDocumentProxy.keyboardAppearance {
        case .dark:
            isDark = true
        case .light:
            isDark = false
        default:
            isDark = traitCollection.userInterfaceStyle == .dark
        }

        if isDark {
            return Theme(
                keyboardBackground: UIColor(red: 0.73, green: 0.75, blue: 0.80, alpha: 1.0),
                letterKeyBackground: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0),
                letterKeyText: UIColor(red: 0.09, green: 0.10, blue: 0.12, alpha: 1.0),
                utilityKeyBackground: UIColor(red: 0.34, green: 0.35, blue: 0.39, alpha: 1.0),
                utilityKeyText: UIColor.white,
                actionKeyBackground: UIColor(red: 0.21, green: 0.52, blue: 0.96, alpha: 1.0),
                actionKeyText: UIColor.white,
                shadowColor: UIColor.black.withAlphaComponent(0.18)
            )
        }

        return Theme(
            keyboardBackground: UIColor(red: 0.84, green: 0.87, blue: 0.92, alpha: 1.0),
            letterKeyBackground: UIColor.white,
            letterKeyText: UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1.0),
            utilityKeyBackground: UIColor(red: 0.67, green: 0.70, blue: 0.75, alpha: 1.0),
            utilityKeyText: UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1.0),
            actionKeyBackground: UIColor(red: 0.21, green: 0.52, blue: 0.96, alpha: 1.0),
            actionKeyText: UIColor.white,
            shadowColor: UIColor.black.withAlphaComponent(0.12)
        )
    }

    private func applyTheme() {
        let theme = currentTheme
        view.backgroundColor = theme.keyboardBackground

        for button in keyButtons {
            button.applyColors(
                backgroundColor: theme.letterKeyBackground,
                titleColor: theme.letterKeyText,
                shadowColor: theme.shadowColor
            )
        }

        let utilityButtons = [modeButton, globeButton, backspaceButton] + dynamicUtilityButtons
        for button in utilityButtons {
            button.applyColors(
                backgroundColor: theme.utilityKeyBackground,
                titleColor: theme.utilityKeyText,
                shadowColor: theme.shadowColor
            )
        }

        if keyboardMode == .letters {
            switch shiftState {
            case .off:
                shiftButton.applyColors(
                    backgroundColor: theme.utilityKeyBackground,
                    titleColor: theme.utilityKeyText,
                    shadowColor: theme.shadowColor
                )
            case .on, .capsLock:
                shiftButton.applyColors(
                    backgroundColor: theme.actionKeyBackground,
                    titleColor: theme.actionKeyText,
                    shadowColor: theme.shadowColor
                )
            }
        } else {
            shiftButton.applyColors(
                backgroundColor: theme.utilityKeyBackground,
                titleColor: theme.utilityKeyText,
                shadowColor: theme.shadowColor
            )
        }

        returnButton.applyColors(
            backgroundColor: theme.actionKeyBackground,
            titleColor: theme.actionKeyText,
            shadowColor: theme.shadowColor
        )

        spaceButton.applyColors(
            backgroundColor: theme.letterKeyBackground,
            titleColor: theme.letterKeyText,
            shadowColor: theme.shadowColor
        )
    }
}
