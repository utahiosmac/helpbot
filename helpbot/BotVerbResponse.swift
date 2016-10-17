//
//  BotVerbEvent.swift
//  helpbot
//
//  Created by Dave DeLong on 10/14/16.
//  Copyright © 2016 Utah iOS & Mac Developers. All rights reserved.
//

import Foundation
import botkit

struct BotCommandEvent<C: BotCommand>: EventType {
    private let command = C()
    
    init(json: JSON, bot: Bot) throws {
        let messageEvent = try Channel.MessagePosted(json: json, bot: bot)
        guard let me = bot.me else { throw JSONError("No bot user") }
        
        let regex = Regex(pattern: "^\\<@\(me.identifier.value)\\>:?\\s+(.+)$")
        let text = messageEvent.message.text
        
        guard let matches = regex.match(text) else { throw JSONError("Not addressed to me") }
        
        let commandText = matches[1]
        
        guard commandText.hasPrefix(command.verb) else { throw JSONError("Event does not have the proper verb") }
    }
    
}

protocol BotCommand {
    
    var verb: String { get }
    init()
    
}
