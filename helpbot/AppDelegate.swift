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
        
        do {
            let authToken = try String(contentsOf: authTokenFile)
            let trimmed = authToken.trimmingCharacters(in: .whitespacesAndNewlines)
            bot = Bot(authorizationToken: trimmed)
        } catch let e {
            fatalError("Unable to read auth token from authToken.txt resource: \(e)")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

