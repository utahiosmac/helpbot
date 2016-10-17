//
//  Regex.swift
//  helpbot
//
//  Created by Dave DeLong on 10/15/16.
//  Copyright © 2016 Utah iOS & Mac Developers. All rights reserved.
//

import Foundation

public struct Regex {
    
    private let pattern: NSRegularExpression?
    
    public init(pattern: String, options: NSRegularExpression.Options = []) {
        self.pattern = try? NSRegularExpression(pattern: pattern, options: options)
    }
    
    public func matches(_ string: String) -> Bool  {
        guard let pattern = pattern else { return false }
        
        let range = NSRange(location: 0, length: string.utf16.count)
        return pattern.numberOfMatches(in: string, options: [.withTransparentBounds], range: range) > 0
    }
    
    public func match(_ string: String) -> RegexMatch? {
        guard let pattern = pattern else { return nil }
        
        let range = NSRange(location: 0, length: string.utf16.count)
        guard let match = pattern.firstMatch(in: string, options: [.withTransparentBounds], range: range) else { return nil }
        return RegexMatch(result: match, source: string)
    }
}

extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self.init(pattern: value) }
    public init(extendedGraphemeClusterLiteral value: String) { self.init(pattern: value) }
    public init(unicodeScalarLiteral value: String) { self.init(pattern: value) }
}

public struct RegexMatch {
    private let matches: Array<String>
    
    fileprivate init(result: NSTextCheckingResult, source: String) {
        let nsSource = source as NSString
        
        var matches = Array<String>()
        for i in 0 ..< result.numberOfRanges {
            let r = result.rangeAt(i)
            matches.append(nsSource.substring(with: r))
        }
        
        self.matches = matches
    }
    
    public subscript(index: Int) -> String {
        get {
            return matches[index]
        }
    }
}

public func ~= (left: Regex, right: String) -> Bool {
    return left.matches(right)
}

public func ~= (left: Regex, right: String) -> RegexMatch? {
    return left.match(right)
}
