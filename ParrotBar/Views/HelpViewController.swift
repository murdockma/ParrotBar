//
//  SettingsViewController.swift
//  ParrotBar
//
//  Created by michael on 8/4/24.
//

import Cocoa

class HelpViewController: NSViewController {
    
    private let githubURL = "https://github.com/murdockma/ParrotBar"

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        // Explanation
        let explanationText = NSTextField(labelWithString: """
        If you want to contribute to this project, report an issue, or request a feature, please visit the GitHub repository:
        """)
        explanationText.frame = NSRect(x: 20, y: 320, width: 560, height: 40)
        explanationText.textColor = NSColor.labelColor
        explanationText.alignment = .left
        explanationText.lineBreakMode = .byWordWrapping
        explanationText.maximumNumberOfLines = 0
        self.view.addSubview(explanationText)
        
        // GitHub link button
        let githubButton = NSButton(title: "Open GitHub Repository", target: self, action: #selector(openGitHub))
        githubButton.frame = NSRect(x: 20, y: 280, width: 200, height: 30)
        githubButton.bezelStyle = .rounded
        self.view.addSubview(githubButton)
    }

    @objc private func openGitHub() {
        if let url = URL(string: githubURL) {
            NSWorkspace.shared.open(url)
        }
    }
}
