import Foundation

enum KeyboardLayout {
    static let letterRows: [[String]] = [
        ["ё", "й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "ъ"],
        ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
        ["я", "ч", "с", "м", "и", "т", "ь", "б", "ю"]
    ]

    static let numberRows: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "₽", "&", "@", "\""],
        [".", ",", "?", "!", "'"]
    ]

    static let symbolRows: [[String]] = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
        [".", ",", "?", "!", "'"]
    ]

    static let lowercaseMap: [String: String] = [
        "ё": "`",
        "й": "q", "ц": "w", "у": "e", "к": "r", "е": "t", "н": "y", "г": "u", "ш": "i", "щ": "o", "з": "p", "х": "[", "ъ": "]",
        "ф": "a", "ы": "s", "в": "d", "а": "f", "п": "g", "р": "h", "о": "j", "л": "k", "д": "l", "ж": ";", "э": "'",
        "я": "z", "ч": "x", "с": "c", "м": "v", "и": "b", "т": "n", "ь": "m", "б": ",", "ю": "."
    ]

    static func outputForLetter(_ key: String, uppercase: Bool) -> String {
        let base = lowercaseMap[key] ?? key
        return uppercase ? base.uppercased() : base
    }

    static func transliterated(_ input: String) -> String {
        input.map { character in
            let string = String(character)
            if let mapped = lowercaseMap[string] {
                return mapped
            }
            let lower = string.lowercased()
            if let mapped = lowercaseMap[lower] {
                return string == lower ? mapped : mapped.uppercased()
            }
            return string
        }
        .joined()
    }
}
