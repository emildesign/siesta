//
//  DebugFormatting.swift
//  Siesta
//
//  Created by Paul on 2015/8/18.
//  Copyright © 2015 Bust Out Solutions. All rights reserved.
//


private let whitespacePat = NSRegularExpression.compile("\\s+")

internal func debugStr(
        x: Any?,
        consolidateWhitespace: Bool = false,
        truncate: Int? = 500)
    -> String
    {
    guard let x = x else
        { return "–" }
    
    var s: String
    if let debugPrintable = x as? CustomDebugStringConvertible
        { s = debugPrintable.debugDescription ?? "–" }
    else
        { s = "\(x)" }
    
    if consolidateWhitespace
        { s = s.replaceRegex(whitespacePat, " ") }
    
    if let truncate = truncate where s.characters.count > truncate
        { s = s.substringToIndex(s.startIndex.advancedBy(truncate)) + "…" }
    
    return s
    }

internal func debugStr(
        messageParts: [Any?],
        join: String = " ",
        consolidateWhitespace: Bool = true,
        truncate: Int? = 300)
    -> String
    {
    return messageParts
        .map
            {
            ($0 as? String)
                ?? debugStr($0, consolidateWhitespace: consolidateWhitespace, truncate: truncate)
            }
        .joinWithSeparator(" ")
    }

internal func dumpHeaders(headers: [String:String], indent: String = "") -> String
    {
    var result = "\n" + indent + "headers: (\(headers.count))"
    
    for (k,v) in headers
        { result += "\n" + indent + "  \(k): \(v)" }
    
    return result
    }

extension Response
    {
    internal func dump(indent: String = "") -> String
        {
        switch self
            {
            case .Success(let value): return "\n" + indent + "Success" + value.dump(indent + "  ")
            case .Failure(let value): return "\n" + indent + "Failure" + value.dump(indent + "  ")
            }
        }
    }

extension Entity
    {
    internal func dump(indent: String = "") -> String
        {
        var result =
            "\n" + indent + "contentType: \(contentType)" +
            "\n" + indent + "charset:     \(debugStr(charset))" +
            dumpHeaders(headers, indent: indent) +
            "\n" + indent + "content: (\(content.dynamicType))\n"
        result += debugStr(content, truncate: Int.max)
            .replaceRegex("^|\n", "$0  " + indent)
        return result
        }
    }

extension Error
    {
    internal func dump(indent: String = "") -> String
        {
        var result = "\n" + indent + "userMessage:    \(debugStr(userMessage, consolidateWhitespace: true, truncate: 80))"
        if httpStatusCode != nil
            { result += "\n" + indent + "httpStatusCode: \(debugStr(httpStatusCode))" }
        if nsError != nil
            { result += "\n" + indent + "nsError:        \(debugStr(userMessage, consolidateWhitespace: true))" }
        if let entity = entity
            { result += "\n" + indent + "entity:" + entity.dump(indent + "  ") }
        return result
        }
    }
