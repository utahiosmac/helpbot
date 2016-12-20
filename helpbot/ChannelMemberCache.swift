//
//  ChannelMemberCache.swift
//  helpbot
//
//  Created by Dave DeLong on 10/13/16.
//  Copyright © 2016 Utah iOS & Mac Developers. All rights reserved.
//

import Foundation
import BotKit

class ChannelMemberCache {
    private let q = DispatchQueue(label: "helpbot.ChannelMemberCache")
    private var caches = Dictionary<String, MemberCache>()
    private let bot: Bot
    
    init(bot: Bot) {
        self.bot = bot
        // todo: list channels, load caches
    }
    
    func add(user: User, to channel: Channel) {
        let c = cache(for: channel)
        c.add(user: user)
    }
    
    func remove(user: User, from channel: Channel) {
        let c = cache(for: channel)
        c.remove(user: user)
    }
    
    func listUsers(in channel: Channel) -> Array<Identifier<User>> {
        let c = cache(for: channel)
        return c.listUsers()
    }
    
    func joined(channel: Channel) {
        // the bot has joined the channel
        // grab the list of all users in the channel and cache it
        _ = cache(for: channel)
    }
    
    func archived(channel: Channel, by: User) {
        // a channel has been archived
        // do we really need to do anything here?
    }
    
    func unarchived(channel: Channel, by: User) -> Array<Identifier<User>> {
        // a channel has been unarchived
        // if we have a list of past users, DM them and invite them to rejoin
        let c = cache(for: channel)
        let pastMembers = c.listUsers()
        let others = pastMembers.filter { $0 != by.identifier }
        
        return others
    }
    
    
    private func cache(for channel: Channel) -> MemberCache {
        var cache: MemberCache?
        let channelID = channel.identifier.value
        q.sync {
            if let c = caches[channelID] {
                cache = c
            } else {
                let c = MemberCache(bot: bot, channel: channelID)
                caches[channelID] = c
                cache = c
            }
        }
        return cache!
    }
}

private class MemberCache {
    private let q: DispatchQueue
    private let bot: Bot
    
    init(bot: Bot, channel: String) {
        q = DispatchQueue(label: "\(channel)-MemberCache")
        self.bot = bot
        
        // todo: load cache
        // list members if channel is unarchived
    }
    
    func add(user: User) {
        
    }
    
    func remove(user: User) {
        
    }
    
    func listUsers() -> Array<Identifier<User>> {
        return []
    }
    
}
