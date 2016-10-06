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
        
        do {
            let authToken = try String(contentsOf: authTokenFile)
            let trimmed = authToken.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let configuration = Bot.Configuration(authToken: trimmed, dataDirectory: url)
            bot = Bot(configuration: configuration)
        } catch let e {
            fatalError("Unable to read auth token from authToken.txt resource: \(e)")
        }
        
        bot?.on { (e: Channel.Archived, b: Bot) in
            print("Archived: \(e.channel)")
        }
        
        bot?.on { (e: Channel.UserLeft, b: Bot) in
            print("User left \(e.channel): \(e.user)")
        }
        
        bot?.on { (e: Channel.UserJoined, b: Bot) in
            print("User joined \(e.channel): \(e.user)")
        }
        
        bot?.on { (e: Channel.MessagePosted, b: Bot) in
            let s = "In \(e.message.channel), \(e.message.user) said: \(e.message.text)"
            print(s)
        }
        
        bot?.on { (e: Startup, b: Bot) in
            b.execute(action: Emoji.List(), completion: { r in
                print("result: \(r)")
            })
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

