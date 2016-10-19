//
//  HelpCommand.swift
//  helpbot
//
//  Created by Dave DeLong on 10/18/16.
//  Copyright © 2016 Utah iOS & Mac Developers. All rights reserved.
//

import Foundation
import botkit

struct HelpCommand: BotCommand {
    
    static var verb: String = "help"
    
    init(with text: String, from bot: Bot) throws {
        guard text.isEmpty else {
            throw JSONError("help does not take any arguments")
        }
    }
}
