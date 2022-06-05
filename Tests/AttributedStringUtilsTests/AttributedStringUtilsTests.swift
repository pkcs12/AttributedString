import XCTest
@testable import AttributedStringUtils

final class AttributedStringUtilsTests: XCTestCase {

    private let sut = AttributedStringUtils(
        """
        Swift is a powerful and intuitive programming language for iOS, iPadOS, macOS, tvOS, and watchOS. \
        Writing Swift code is interactive and fun, the syntax is concise yet expressive, and Swift includes modern features developers love. \
        Swift code is safe by design, yet also produces software that runs lightning-fast.
        """
    )

    func test_setFont_exactRange() throws {
        let result = sut
            .setFont(.systemFont(ofSize: 18.0, weight: .regular))
            .setFont(.systemFont(ofSize: 20.0, weight: .bold), ifMatches: [.exact("is")])
            .setFont(.systemFont(ofSize: 22.0, weight: .heavy), ifMatches: [.exact("intuitive programming language")])
            .get

        var font = try XCTUnwrap(result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)
        XCTAssertEqual(font, .systemFont(ofSize: 18.0, weight: .regular))

        var range = try XCTUnwrap(result.string.range(of: "is", options: [], range: nil, locale: nil))
        font = try XCTUnwrap(result.attribute(.font, at: StringUtils(result.string).nsRange(for: range).location, effectiveRange: nil) as? UIFont)
        XCTAssertEqual(.systemFont(ofSize: 20.0, weight: .bold), font)

        range = try XCTUnwrap(result.string.range(of: "intuitive programming language", options: [], range: nil, locale: nil))
        font = try XCTUnwrap(result.attribute(.font, at: StringUtils(result.string).nsRange(for: range).location, effectiveRange: nil) as? UIFont)
        XCTAssertEqual(.systemFont(ofSize: 22.0, weight: .heavy), font)
    }

    func test_setFont_regexRange() throws {
        let result = sut
            .setFont(.systemFont(ofSize: 18.0, weight: .regular))
            .setFont(.systemFont(ofSize: 22.0, weight: .heavy), ifMatches: [.regex("intuitive programming language")])
            .get

        var font = try XCTUnwrap(result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)
        XCTAssertEqual(font, .systemFont(ofSize: 18.0, weight: .regular))

        let range = try XCTUnwrap(result.string.range(of: "intuitive programming language", options: [], range: nil, locale: nil))
        font = try XCTUnwrap(result.attribute(.font, at: StringUtils(result.string).nsRange(for: range).location, effectiveRange: nil) as? UIFont)
        XCTAssertEqual(.systemFont(ofSize: 22.0, weight: .heavy), font)
    }

    func test_setFont_setForegroundColor_exactRange() throws {
        let result = sut
            .setFont(.systemFont(ofSize: 18.0, weight: .regular))
            .setForegroundColor(.red)
            .get

        let font = try XCTUnwrap(result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)
        XCTAssertEqual(font, .systemFont(ofSize: 18.0, weight: .regular))

        let color = try XCTUnwrap(result.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor)
        XCTAssertEqual(color, .red)
    }

    func test_setTextAlignment_exactRange() throws {
        let result = sut
            .setTextAlignment(.center)
            .get

        let style = try XCTUnwrap(result.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)
        XCTAssertEqual(style.alignment, .center)
    }

    func test_setTextAlignment_setParagraphStyle_setLineHeight_exactRange() throws {
        let style = NSMutableParagraphStyle()
        style.setParagraphStyle(.default)
        style.maximumLineHeight = 32
        style.minimumLineHeight = 22
        style.alignment = .natural

        let result = sut
            .setTextAlignment(.center)      // centering text
            .setParagraphStyle(style)       // overriding centering to natural
            .setLineHeight(18, 20)          // overriding line height to 18
            .get

        let modifiedStyle = try XCTUnwrap(result.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)
        XCTAssertEqual(modifiedStyle.alignment, .natural)
        XCTAssertEqual(modifiedStyle.maximumLineHeight, 20)
        XCTAssertEqual(modifiedStyle.minimumLineHeight, 18)
    }

    func test_set_backgroundColor_font_textAlignment() throws {

        let result = sut
            .set(
                [
                    .backgroundColor(.white),
                    .font(.systemFont(ofSize: 18, weight: .regular)),
                    .textAlignemnt(.justified)
                ]
            )
            .get

        let font = try XCTUnwrap(result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)
        XCTAssertEqual(font, .systemFont(ofSize: 18, weight: .regular))
        let style = try XCTUnwrap(result.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)
        XCTAssertEqual(style.alignment, .justified)
        let color = try XCTUnwrap(result.attribute(.backgroundColor, at: 0, effectiveRange: nil) as? UIColor)
        XCTAssertEqual(color, .white)
    }
}
