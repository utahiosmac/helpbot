//
//  AppDelegate.swift
//  helpbot
//
//  Created by Dave DeLong on 1/20/16.
//  Copyright © 2016 Utah iOS & Mac Developers. All rights reserved.
//

import Cocoa
import botkit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var bot: Bot?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        guard let authTokenFile = Bundle.main.url(forResource: "authToken", withExtension: "txt") else {
            fatalError("Unable to find authToken.txt resource")
        }
        
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: [.userDomainMask]).first else {
            fatalError("Unable to find caches directory")
        }
        let dataDirectory = url.appendingPathComponent("BotKit", isDirectory: true)
        
        let bot: Bot
        do {
            let authToken = try String(contentsOf: authTokenFile)
            let trimmed = authToken.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let configuration = Bot.Configuration(authToken: trimmed, dataDirectory: dataDirectory)
            bot = Bot(configuration: configuration)
        } catch let e {
            fatalError("Unable to read auth token from authToken.txt resource: \(e)")
        }
        
        bot.on { (e: Startup, b: Bot) in
            b.execute(action: User.MyInfo()) { r in
                b.me = r.value
            }
            
            b.report("I just reconnected", in: "#help-status")
        }
        
        setUpCommands(bot: bot)
        setUpMemberCache(bot: bot)
        setUpSnark(bot: bot)
        
        bot.on("announce new emojis in #lobby") { (e: Emoji.Added, b: Bot) in
            let name = ":" + e.emoji.name + ":"
            let msg = "We have a new emoji! `\(name)` → \(name)"
            b.post(msg, in: "#lobby")
        }
        
        bot.on("ask to be added to newly created channels") { (e: Channel.Created, b: Bot) in
            let name = b.name(for: e.channel)
            
            let message = "Hey, I see you just created #\(name). If you'd like me in there, please `/invite @help`. Thanks!"
            b.send(message, to: e.user) { _ in }
            b.report("new channel: #\(name)", in: "#admins")
        }
        
        bot.on { (e: Channel.Renamed, b: Bot) in
            let name = b.name(for: e.channel)
            b.report("channel renamed to #\(name)", in: "#help-status")
        }
        
        self.bot = bot
        self.bot?.connect()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension AppDelegate {
    
    func setUpMemberCache(bot: Bot) {
        
        let channelMemberCache = ChannelMemberCache(bot: bot)
        
        bot.on { (e: Channel.Archived, b: Bot) in
            channelMemberCache.archived(channel: e.channel, by: e.user)
            
            let name = b.name(for: e.channel)
            let user = b.name(for: e.user)
            b.report("#\(name) archived by @\(user)")
        }
        
        bot.on("invite members to re-join channels they were in when the channel was archived") { (e: Channel.Unarchived, b: Bot) in
            let oldMembers = channelMemberCache.unarchived(channel: e.channel, by: e.user)
            
            let name = b.name(for: e.channel)
            let user = b.name(for: e.user)
            
            b.report("#\(name) unarchived by @\(user)")
            
            
            let message = "You used to be a member of the archived channel #\(name). It has been unarchived, in case you would like to re-join the channel"
            
            oldMembers.forEach {
                b.send(message, to: $0)
            }
        }
        
        bot.on { (e: Channel.Joined, b: Bot) in
            channelMemberCache.joined(channel: e.channel)
            
            let name = b.name(for: e.channel)
            b.report("I just joined #\(name)")
        }
        
        bot.on { (e: Channel.Left, b: Bot) in
            let name = b.name(for: e.channel)
            b.report("I just left #\(name)")
        }
        
        bot.on { (e: Channel.UserJoined, b: Bot) in
            channelMemberCache.add(user: e.user, to: e.channel)
        }
        
        bot.on { (e: Channel.UserLeft, b: Bot) in
            channelMemberCache.remove(user: e.user, from: e.channel)
        }
        
    }
    
    func setUpSnark(bot: Bot) {
        
        // wave back
        bot.on("wave back when people @mention me") { (e: Channel.MessagePosted, b: Bot) in
            guard e.message.user != b.me else { return }
            guard let me = b.me?.identifier.value else { return }
            let mention = "<@\(me)>"
            
            let m = e.message
            let bits = m.text.components(separatedBy: mention)
            
            let mentions = bits.count-1
            guard mentions > 0 else { return }
            switch mentions {
                case 1..<3: b.react(to: m, with: "wave")
                case 3..<5: b.react(to: m, with: "neutral_face")
                case 5..<8: b.react(to: m, with: "thinking_face")
                case 8..<10: b.react(to: m, with: "o_0")
                case 10..<13: b.react(to: m, with: "tearsofblood")
                case 13..<15: b.react(to: m, with: "middle_finger")
                case 15..<18: b.reply(to: m, with: "uhhhhhhh...")
                case 18..<20: b.reply(to: m, with: "get off my lawn")
                default: b.reply(to: m, with: "what do you hope to gain by mentioning me \(mentions) times in a single message?")
            }
        }
    }
    
    func setUpCommands(bot: Bot) {
        bot.on("show this help message") { (e: CommandEvent<HelpCommand>, b: Bot) in
            let helps = b.ruleHelps()
            
            let items = helps.map { "- " + $0 }.joined(separator: "\n")
            let message = "Here's what I can do. I... \n" + items
            
            b.post(message, in: e.message.channel, ephemeral: true)
        }
        
        bot.on("welcome new users to the team") { (e: CommandEvent<WelcomeCommand>, b: Bot) in
            guard let welcomeURL = URL(string: "https://raw.githubusercontent.com/utahiosmac/documents/master/Welcome.txt") else { return }
            guard let welcomeText = try? String(contentsOf: welcomeURL) else { return }
            
            e.command.users.forEach { uID in
                let name = b.name(for: uID)
                b.send("Hello, @\(name)!", to: uID) { _ in
                    b.send(welcomeText, to: uID) { _ in
                        b.report("@\(name) has been welcomed to the team", in: "#admins")
                    }
                }
            }
        }
    }
}
