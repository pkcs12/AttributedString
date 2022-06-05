import XCTest
@testable import AttributedStringUtils

final class StringsUtilsTests: XCTestCase {

    private let sut = StringUtils(
         """
        Swift is a powerful and intuitive programming language for iOS, iPadOS, macOS, tvOS, and watchOS. \
        Writing Swift code is interactive and fun, the syntax is concise yet expressive, and Swift includes modern features developers love. \
        Swift code is safe by design, yet also produces software that runs lightning-fast.
        """
    )

    func test_nsRange_wholeString() throws {
        let range = sut.nsRange()
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, sut.get.count)
    }

    func test_nsRange_wholeString_explicit() throws {
        let range = sut.nsRange(for: sut.get.startIndex..<sut.get.endIndex)
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, sut.get.count)
    }

    func test_nsRange_forPowerful() throws {
        let range = sut.nsRange(for: sut.get.index(sut.get.startIndex, offsetBy: 11)..<sut.get.index(sut.get.startIndex, offsetBy: 11+8))
        XCTAssertEqual(range.location, 11)
        XCTAssertEqual(range.length, 8)
    }

    func test_range_wholeString() throws {
        let range = sut.range()
        XCTAssertEqual(range.lowerBound, sut.get.startIndex)
        XCTAssertEqual(range.upperBound, sut.get.endIndex)
    }

    func test_range_wholeString_explicit() throws {
        let range = sut.range(for: .init(location: 0, length: sut.get.count))
        XCTAssertEqual(range.lowerBound, sut.get.startIndex)
        XCTAssertEqual(range.upperBound, sut.get.endIndex)
    }

    func test_range_forPowerful() throws {
        let range = sut.range(for: .init(location: 11, length: 8))
        XCTAssertEqual(range.lowerBound, sut.get.index(sut.get.startIndex, offsetBy: 11))
        XCTAssertEqual(range.upperBound, sut.get.index(sut.get.startIndex, offsetBy: 11+8))
    }

    func test_enumerateMatches_caseSensitive_swift() throws {
        var matches: Int = 0
        var ranges: [Range<String.Index>] = []
        sut
            .enumerateMatches(
                of: "swift",
                options: []
            ) { match, range in
                XCTAssertEqual("swift", match)
                XCTAssert(!ranges.contains(range))
                ranges.append(range)
                matches += 1
            }

        XCTAssertEqual(0, matches)
    }

    func test_enumerateMatches_caseInsensitive_swift() throws {
        var matches: Int = 0
        var ranges: [Range<String.Index>] = []
        sut
            .enumerateMatches(
                of: "swift",
                options: [.caseInsensitive]
            ) { match, range in
                XCTAssertEqual("swift", match)
                XCTAssert(!ranges.contains(range))
                ranges.append(range)
                matches += 1
            }

        XCTAssertEqual(4, matches)
    }

    func test_enumerateMatches_regex_caseSensitive_swift() throws {
        var matches: Int = 0
        var ranges: [Range<String.Index>] = []
        sut
            .enumerateMatches(
                of: #"swift i"#,
                options: [.regularExpression]
            ) { match, range in
                XCTAssertEqual("Swift i", String(sut.get[range]))
                XCTAssert(!ranges.contains(range))
                ranges.append(range)
                matches += 1
            }

        XCTAssertEqual(0, matches)
    }

    func test_enumerateMatches_regex_caseInsensitive_swift() throws {
        var matches: Int = 0
        var ranges: [Range<String.Index>] = []
        sut
            .enumerateMatches(
                of: #"swift i"#,
                options: [.caseInsensitive, .regularExpression]
            ) { match, range in
                XCTAssertEqual("Swift i", String(sut.get[range]))
                XCTAssert(!ranges.contains(range))
                ranges.append(range)
                matches += 1
            }

        XCTAssertEqual(2, matches)
    }

    func test_replaceMatches_caseSensitive_swift_to_objc() throws {
        var matches: Int = 0
        var ranges: [Range<String.Index>] = []
        let result = sut
            .replaceMatches(
                of: "swift",
                options: []) { match, range in
                    XCTAssertEqual("swift", match)
                    XCTAssert(!ranges.contains(range))
                    ranges.append(range)
                    matches += 1
                    return "objc"
                }
                .get

        XCTAssertEqual(0, matches)
        XCTAssertEqual(sut.get, result)
    }

    func test_replaceMatches_caseInsensitive_swift_to_objc() throws {
        var matches: Int = 0
        var ranges: [Range<String.Index>] = []
        let result = sut
            .replaceMatches(
                of: "swift",
                options: [.caseInsensitive]) { match, range in
                    XCTAssert(match.caseInsensitiveCompare("swift") == .orderedSame)
                    XCTAssert(!ranges.contains(range))
                    ranges.append(range)
                    matches += 1
                    return "Objc"
                }
                .get

        XCTAssertEqual(4, matches)

        XCTAssertEqual(
            sut.get.replacingOccurrences(
                of: "Swift",
                with: "Objc",
                options: [.caseInsensitive],
                range: nil
            ),
            result
        )
    }
}
