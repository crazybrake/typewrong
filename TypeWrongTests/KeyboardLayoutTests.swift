import XCTest

final class KeyboardLayoutTests: XCTestCase {
    func testExamplesFromSpecification() {
        XCTAssertEqual(KeyboardLayout.transliterated("пароль"), "gfhjkm")
        XCTAssertEqual(KeyboardLayout.transliterated("привет"), "ghbdtn")
    }

    func testStandardComputerRussianLetterMappings() {
        let expected: [String: String] = [
            "ё": "`", "й": "q", "ц": "w", "у": "e", "к": "r", "е": "t", "н": "y",
            "г": "u", "ш": "i", "щ": "o", "з": "p", "х": "[", "ъ": "]",
            "ф": "a", "ы": "s", "в": "d", "а": "f", "п": "g", "р": "h", "о": "j",
            "л": "k", "д": "l", "ж": ";", "э": "'",
            "я": "z", "ч": "x", "с": "c", "м": "v", "и": "b", "т": "n", "ь": "m",
            "б": ",", "ю": "."
        ]

        XCTAssertEqual(KeyboardLayout.lowercaseMap, expected)
    }

    func testUppercaseInputProducesUppercaseLatin() {
        XCTAssertEqual(KeyboardLayout.transliterated("Привет"), "Ghbdtn")
        XCTAssertEqual(KeyboardLayout.outputForLetter("ё", uppercase: true), "`")
        XCTAssertEqual(KeyboardLayout.outputForLetter("п", uppercase: true), "G")
    }

    func testNonRussianCharactersPassThrough() {
        XCTAssertEqual(KeyboardLayout.transliterated("123 test!?"), "123 test!?")
    }
}
