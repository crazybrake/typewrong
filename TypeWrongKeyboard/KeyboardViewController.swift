import UIKit

final class KeyboardViewController: UIInputViewController {
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
    private var keyboardMode: KeyboardMode = .letters
    private var shiftState: ShiftState = .off

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        rebuildLetterKeys()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        globeButton.isHidden = !needsInputModeSwitchKey
    }

    private func setupView() {
        view.backgroundColor = UIColor(red: 0.84, green: 0.87, blue: 0.92, alpha: 1.0)

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
    }

    private func rebuildLetterKeys() {
        rootStack.arrangedSubviews.forEach { row in
            rootStack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        keyButtons.removeAll()

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

        let bottomRow = makeBottomRow()
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

        rootStack.addArrangedSubview(bottomRow)
        updateModeButtonTitle()
        updateReturnKeyTitle()
        updateShiftAppearance()
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
            shiftButton.backgroundColor = .systemGray5
            shiftButton.setTitleColor(.label, for: .normal)
            shiftButton.setTitle("⇧", for: .normal)
        case .on:
            shiftButton.backgroundColor = .systemBlue
            shiftButton.setTitleColor(.white, for: .normal)
            shiftButton.setTitle("⇧", for: .normal)
        case .capsLock:
            shiftButton.backgroundColor = .systemBlue
            shiftButton.setTitleColor(.white, for: .normal)
            shiftButton.setTitle("⇪", for: .normal)
        }
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
}
