//
//  AppDelegate+Random.swift
//  ParrotBar
//
//  Created by michael on 7/26/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa

// MARK: - Random Image Set

extension AppDelegate {
    // Selects random GIF file from the bundle and starts animation with it
    @objc internal func changeToRandomImageSet() {
        let gifFiles = findGIFFilesInBundle()
        guard !gifFiles.isEmpty else {
            #if DEBUG
            logger.error("No GIF files to choose from")
            #endif
            return
        }

        // Select random GIF file
        let randomIndex = Int(arc4random_uniform(UInt32(gifFiles.count)))
        let randomGIFFile = gifFiles[randomIndex]
        let animationName = randomGIFFile.replacingOccurrences(of: ".gif", with: "")
        
        // Load and start new animation set
        loadImageSet(named: animationName, isGIF: true)
        startAnimation()
    }
    
    // Updates title of random mode menu item
    private func updateRandomModeMenuItem() {
        if let randomModeMenuItem = randomModeMenuItem {
            let status = isRandomModeEnabled ? "On" : "Off"
            randomModeMenuItem.title = "Toggle Random Mode: \(status)"
        }
    }

    // Toggles random mode for selecting image sets (new image set every 30s)
    @objc internal func toggleRandomMode() {
        isRandomModeEnabled.toggle()

        // Clear existing timer if random mode is being disabled
        if !isRandomModeEnabled {
            randomImageSetTimer?.invalidate()
            randomImageSetTimer = nil
            #if DEBUG
            logger.debug("Random mode disabled")
            #endif
            updateRandomModeMenuItem() // Update menu item title
            return
        }

        // Change to random image set and set up new timer if random modes enabled
        changeToRandomImageSet()
        
        // Check if timer already exists
        if randomImageSetTimer == nil {
            randomImageSetTimer = Timer.scheduledTimer(
                timeInterval: 30.0,
                target: self,
                selector: #selector(changeToRandomImageSet),
                userInfo: nil,
                repeats: true
            )
            #if DEBUG
            logger.debug("Random mode enabled, changing every 30 seconds")
            #endif
        }

        updateRandomModeMenuItem() // Update menu item title
    }
}
