//
//  SettingsWindowController.swift
//  ParrotBar
//
//  Created by michael on 8/4/24.
//

import Cocoa
import SwiftUI

class HelpWindowController: NSWindowController {

    init() {
        let helpWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400), // Increased size
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        helpWindow.title = "Settings"
        helpWindow.center()
        super.init(window: helpWindow)
        self.window?.contentViewController = HelpViewController() // Set your view controller here
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let window = self.window {
            window.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
