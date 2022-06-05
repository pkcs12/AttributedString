
import Foundation
import UIKit

public struct AttributedStringUtils {
    private let mutable: NSMutableAttributedString

    public init(_ string: String) {
        self.mutable = .init(string: string)
    }

    public init(_ attributed: NSAttributedString) {
        self.mutable = .init(attributedString: attributed)
    }

    public var get: NSAttributedString { mutable }

    public enum Match {
        case exact(String)
        case exactCaseInsensitive(String)
        case regex(String)
    }

    public enum Modifier {
        case font(UIFont)
        case foregroundColor(UIColor)
        case backgroundColor(UIColor)
        case paragraphStyle(NSParagraphStyle)
        case textAlignemnt(NSTextAlignment)
        case lineHeight(min: CGFloat, max: CGFloat)
        case lineSpacing(CGFloat)
        case strikethrough(style: NSUnderlineStyle, color: UIColor)
        case underline(style: NSUnderlineStyle, color: UIColor)
        case writingDirection(format: [Int])
        case baseline(offset: CGFloat)
        case link(URL)
        case attachment(NSTextAttachment)
        case kern(CGFloat)
    }
}

// Convenient

public extension AttributedStringUtils {

    func setFont(_ font: UIFont, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)]) { _, _ in [.font(font)] }
    }

    func setForegroundColor(_ color: UIColor, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.foregroundColor(color)] })
    }

    func setBackgroundColor(_ color: UIColor, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.backgroundColor(color)] })
    }

    func setParagraphStyle(_ style: NSParagraphStyle, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.paragraphStyle(style)] })
    }

    func setTextAlignment(_ alignment: NSTextAlignment, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.textAlignemnt(alignment)] })
    }

    func setLineHeight(_ min: CGFloat, _ max: CGFloat, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.lineHeight(min: min, max: max)] })
    }

    func setLineSpacing(_ spacing: CGFloat, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.lineSpacing(spacing)] })
    }

    func setStrikethrough(_ style: NSUnderlineStyle, color: UIColor, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.strikethrough(style: style, color: color)] })
    }

    func setUnderline(_ style: NSUnderlineStyle, color: UIColor, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.underline(style: style, color: color)] })
    }

    func setWritingDirection(_ format: [Int], ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.writingDirection(format: format)] })
    }

    func setBaselineOffset(_ offset: CGFloat, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.baseline(offset: offset)] })
    }

    func setLink(_ url: URL, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.link(url)] })
    }

    func setAttachment(_ attachment: NSTextAttachment, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.attachment(attachment)] })
    }

    func setKerning(_ kern: CGFloat, ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in [.kern(kern)] })
    }

    func set(_ modifiers: [Modifier], ifMatches matches: [Match]? = .none) -> Self {
        formatMatches(matches ?? [.exact(mutable.string)], { _, _ in modifiers })
    }

    func set<T>(
        _ value: T,
        for keyPath: WritableKeyPath<NSMutableParagraphStyle, T>,
        range: Range<String.Index>
    ) -> Self {
        let style = modifyStyle(at: range, set: keyPath, value: value)
        mutable.addAttribute(.paragraphStyle, value: style, range: StringUtils(mutable.string).nsRange(for: range))
        return self
    }
}

// Private

extension AttributedStringUtils {

    private func modifyStyle<T>(
        at range: Range<String.Index>,
        set keyPath: WritableKeyPath<NSMutableParagraphStyle, T>,
        value: T
    ) -> NSMutableParagraphStyle {
        var newValue = NSMutableParagraphStyle()
        if
            let oldValue = mutable.attribute(
                .paragraphStyle,
                at: StringUtils(mutable.string).nsRange(for: range).location,
                effectiveRange: nil
            ) as? NSParagraphStyle
        {
            newValue.setParagraphStyle(oldValue)
        }
        newValue[keyPath: keyPath] = value
        return newValue
    }

    private func apply(
        _ modification: Modifier,
        range: Range<String.Index>,
        string: NSMutableAttributedString
    ) {
        let nsRange = StringUtils(mutable.string).nsRange(for: range)
        switch modification {
        case let .font(font):
            string.addAttribute(.font, value: font, range: nsRange)

        case let .foregroundColor(color):
            string.addAttribute(.foregroundColor, value: color, range: nsRange)

        case let .backgroundColor(color):
            string.addAttribute(.backgroundColor, value: color, range: nsRange)

        case let .paragraphStyle(style):
            string.addAttribute(.paragraphStyle, value: style, range: nsRange)

        case let .textAlignemnt(alignment):
            let newValue = modifyStyle(at: range, set: \.alignment, value: alignment)
            string.addAttribute(.paragraphStyle, value: newValue, range: nsRange)

        case let .lineHeight(min, max):
            let newValue = modifyStyle(at: range, set: \.minimumLineHeight, value: min)
            newValue.maximumLineHeight = max
            string.addAttribute(.paragraphStyle, value: newValue, range: nsRange)

        case let .lineSpacing(spacing):
            let newValue = modifyStyle(at: range, set: \.lineSpacing, value: spacing)
            string.addAttribute(.paragraphStyle, value: newValue, range: nsRange)

        case let .strikethrough(style, color):
            string.addAttribute(.strikethroughStyle, value: NSNumber(value: style.rawValue), range: nsRange)
            string.addAttribute(.strikethroughColor, value: color, range: nsRange)

        case let .underline(style, color):
            string.addAttribute(.underlineStyle, value: NSNumber(value: style.rawValue), range: nsRange)
            string.addAttribute(.underlineColor, value: color, range: nsRange)

        case let .writingDirection(format):
            string.addAttribute(
                .writingDirection,
                value: format.map { NSNumber(value: $0) } as NSArray,
                range: nsRange
            )

        case let .baseline(offset):
            string.addAttribute(.baselineOffset, value: NSNumber(value: offset), range: nsRange)

        case let .link(url):
            string.addAttribute(.link, value: url, range: nsRange)

        case let .attachment(attachment):
            string.addAttribute(.attachment, value: attachment, range: nsRange)

        case let .kern(kern):
            string.addAttribute(.kern, value: NSNumber(value: kern), range: nsRange)
        }
    }

    private func formatMatches(
        _ matches: [Match],
        _ block: (String, Range<String.Index>) -> [Modifier]
    ) -> Self {
        matches
            .forEach { match in
                var options: String.CompareOptions = [.diacriticInsensitive]
                let matchPattern: String
                switch match {
                case let .exact(string):
                    matchPattern = string
                case let .exactCaseInsensitive(string):
                    options.update(with: .caseInsensitive)
                    matchPattern = string
                case let .regex(pattern):
                    options.update(with: .regularExpression)
                    matchPattern = pattern
                }

                StringUtils(mutable.string)
                    .enumerateMatches(of: matchPattern, options: options) { substring, range in
                        block(substring, range)
                            .forEach { apply($0, range: range, string: mutable) }
                    }
            }

        return self
    }
}
