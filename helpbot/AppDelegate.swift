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
        
        bot = Bot(authorizationToken: "xoxb-3739968338-uZHXmix0jQm2jq2KOMHyFIEa")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

