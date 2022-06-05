import Foundation

public struct StringUtils {
    private let string: String

    public init(_ string: String) {
        self.string = string
    }

    public var get: String { string }

    public func nsRange(for range: Range<String.Index>? = .none) -> NSRange {
        range.map {
            NSRange(
                location: string.distance(from: string.startIndex, to: $0.lowerBound),
                length: string.distance(from: $0.lowerBound, to: $0.upperBound)
            )
        } ?? NSRange(
            location: 0,
            length:string.distance(from: string.startIndex, to: string.endIndex)
        )
    }

    public func range(for nsRange: NSRange? = .none) -> Range<String.Index> {
        nsRange.map {
            let lowerBound = string.index(string.startIndex, offsetBy: $0.location, limitedBy: string.endIndex) ?? string.startIndex
            let upperBound = string.index(lowerBound, offsetBy: $0.length, limitedBy: string.endIndex) ?? string.endIndex
            return lowerBound..<upperBound
        } ?? string.startIndex..<string.endIndex
    }

    public func enumerateMatches(
        of string: String,
        options: NSString.CompareOptions = [.backwards, .caseInsensitive, .diacriticInsensitive],
        _ block: (String, Range<String.Index>) -> Void
    ) {
        var searchInRange: Range<String.Index>? = range()
        while searchInRange != nil {
            guard
                let matchedRange = self.string.range(
                    of: string,
                    options: options,
                    range: searchInRange,
                    locale: .none
                )
            else {
                break
            }

            block(string, matchedRange)

            if options.contains(.backwards) {
                searchInRange = searchInRange.unsafelyUnwrapped.lowerBound..<matchedRange.lowerBound
            } else {
                searchInRange = matchedRange.upperBound..<searchInRange.unsafelyUnwrapped.upperBound
            }
        }
    }

    public func replaceMatches(
        of string: String,
        options: NSString.CompareOptions = [.backwards, .caseInsensitive, .diacriticInsensitive],
        _ block: (String, Range<String.Index>) -> String
    ) -> Self {

        var copy = self.string

        // range could change after modification.
        // to avoit out of bounds exception the lookup should start from the end
        var opt = options
        opt.update(with: .backwards)
        enumerateMatches(
            of: string,
            options: opt
        ) { substring, range in
            copy.replaceSubrange(range, with: block(substring, range))
        }

        return .init(copy)
    }
}
