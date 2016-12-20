//
//  RequestWelcome.swift
//  helpbot
//
//  Created by Dave DeLong on 10/15/16.
//  Copyright © 2016 Utah iOS & Mac Developers. All rights reserved.
//

import Foundation
import BotKit

struct RequestWelcome: EventType {
    
    static let userRegex = try! NSRegularExpression(pattern: "<@([^>]+)>", options: [])
    
    let messagePosted: Channel.MessagePosted
    var message: Message { return messagePosted.message }
    let userIDs: Array<Identifier<User>>
    
    init(json: JSON, bot: Bot) throws {
        messagePosted = try Channel.MessagePosted(json: json, bot: bot)
        let text = messagePosted.message.text
        
        let welcomeBits = text.components(separatedBy: "welcome")
        guard welcomeBits.count == 2 else {
            throw JSONError("Not a welcome request")
        }
        
        let people = welcomeBits[1]
        
        var users = Array<String>()
        let nsPeople = people as NSString
        RequestWelcome.userRegex.enumerateMatches(in: people, options: [], range: NSRange(location: 0, length: people.utf16.count)) { (result, flags, stop) in
            guard let result = result else { return }
            let range = result.rangeAt(1)
            let userID = nsPeople.substring(with: range)
            users.append(userID)
        }
        
        guard users.isEmpty == false else {
            throw JSONError("No one being welcomed")
        }
        
        userIDs = users.map { Identifier<User>($0) }
    }
    
}
