//
//  File.swift
//  helpbot
//
//  Created by Dave DeLong on 10/19/16.
//  Copyright © 2016 Utah iOS & Mac Developers. All rights reserved.
//

import Foundation
import botkit

struct WelcomeCommand: BotCommand {
    static var verb: String = "welcome"
    
    let users: Array<Identifier<User>>
    
    init(with text: String, from bot: Bot) throws {
        let words = text.components(separatedBy: .whitespaces)
        let actualWords = words.filter { $0.isEmpty == false }
        
        // each word needs to be a <@U....> bit
        let r = Regex(pattern: "<@(.+?)>")
        let rawIdentifiers = actualWords.flatMap { w -> String? in
            guard let m = r.match(w) else { return nil }
            return m[1]
        }
        
        guard rawIdentifiers.count == actualWords.count else {
            throw JSONError("Unable to understand welcome command: \(text)")
        }
        
        let uniqueIDs = rawIdentifiers.map { Identifier<User>($0) }.unique()
        if let myID = bot.me?.identifier {
            users = uniqueIDs.filter { $0 != myID }
        } else {
            users = uniqueIDs
        }
    }
}
