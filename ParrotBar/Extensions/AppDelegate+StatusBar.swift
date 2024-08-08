//
//  AppDelegate+StatusBar.swift
//  ParrotBar
//
//  Created by michael on 7/26/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa

// MARK: - Status Bar

extension AppDelegate {
    internal func setupStatusBarItem() {
        // Configure status bar
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusBarButton = statusBarItem?.button {
                // Load default image set from disk
                imageManager.loadImageSetFromDisk(named: "parrot", isGIF: false) { images in
                    guard let image = images.first else {
                        #if DEBUG
                        self.logger.error("Failed to load image 'parrot'")
                        #endif
                        return
                    }

                    // Resize the loaded image
                    if let resizedImage = self.imageManager.resizedImage(
                        image: image, to: NSSize(width: 24, height: 24), fileName: "PartyParrot"
                    ) {
                        // Set resized image to status bar button
                        statusBarButton.image = resizedImage
                        #if DEBUG
                        self.logger.debug("Set status bar button with resized image")
                        #endif
                    } else {
                        #if DEBUG
                        self.logger.error("Failed to resize image")
                        #endif
                    }
                }
                
                // Configure status bar button properties
                statusBarButton.image?.isTemplate = true
                statusBarButton.target = self
                statusBarButton.action = #selector(toggleAnimation)
            }
    }

    internal func setupMenu() {
        // Create a new menu instance
        let menu = NSMenu()
        
        // Create header items for the menu
        let headerItem = NSMenuItem()
        let headerTwoItem = NSMenuItem()
        let favoritesHeaderItem = NSMenuItem()
        
        headerItem.view = CustomMenuHeaderView(title: "System Information")
        headerTwoItem.view = CustomMenuHeaderView(title: "Animations")
        favoritesHeaderItem.view = CustomMenuHeaderView(title: "Favorites")
        
        // Create menu items for displaying system info
        residentMemoryUsageItem = NSMenuItem(
            title: "ParrotBar Memory Usage: ", action: nil, keyEquivalent: ""
        )
        
        randomModeMenuItem = NSMenuItem(
            title: "Toggle Random Mode: Off",
            action: #selector(toggleRandomMode),
            keyEquivalent: ""
        )
        
        systemUptimeItem = NSMenuItem(title: "Uptime: ", action: nil, keyEquivalent: "")
        diskUsageItem = NSMenuItem(title: "Disk Usage: ", action: nil, keyEquivalent: "")
        publicNetworkItem = NSMenuItem(title: "Public IP: ", action: nil, keyEquivalent: "")
        
        // Info item with static text
        let infoMenuItem = NSMenuItem(
            title: "Changes every 30 seconds",
            action: nil,
            keyEquivalent: ""
        )
        infoMenuItem.isEnabled = false
        
        // Add first header item to the menu
        menu.addItem(headerItem)
        
        // Add system info menu items
        menu.addItem(systemUptimeItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(residentMemoryUsageItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(diskUsageItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(publicNetworkItem)
        
        // Add header for animations section
        menu.addItem(headerTwoItem)
        menu.addItem(setupImageSetMenu())
        
        // Add menu items for changing image set and displaying current image set
        menu.addItem(
            NSMenuItem(
                title: "Change to Random Image Set",
                action: #selector(changeToRandomImageSet),
                keyEquivalent: ""
            )
        )
        
        currentGIFNameItem = NSMenuItem(title: "Current Image Set: PartyParrot", action: nil, keyEquivalent: "")
        menu.addItem(currentGIFNameItem)
        menu.addItem(NSMenuItem(title: "Add to Favorites", action: #selector(addToFavorites), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Add favorites items
        let favoritesMenuItem = NSMenuItem(title: "Favorites", action: nil, keyEquivalent: "")
        let favoritesMenu = NSMenu()
        favoritesMenuItem.submenu = favoritesMenu
        menu.addItem(favoritesMenuItem)
        menu.addItem(NSMenuItem(
            title: "Clear Favorites",
            action: #selector(clearFavorites),
            keyEquivalent: ""
        ))
        addFavoritesToMenu(favoritesMenu)
        menu.addItem(NSMenuItem.separator())
        
        // Add random mode toggle item and info item
        menu.addItem(randomModeMenuItem!)
        menu.addItem(infoMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        let helpMenuItem = NSMenuItem(
            title: "Help",
            action: #selector(openHelp),
            keyEquivalent: ""
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(helpMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        // Add quit item
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: ""))

        // Set constructed menu as status bar items menu
        statusBarItem?.menu = menu
    }
    
    private func setupImageSetMenu() -> NSMenuItem {
        // Create new submenu for selecting image sets
        let imageSetMenu = NSMenu(title: "Image Set")
        
        // Add default image set menu item
        imageSetMenu.addItem(
            withTitle: "PartyParrot",
            action: #selector(selectPartyParrotSet),
            keyEquivalent: ""
        )
        // Additional menu items are added dynamically
        
        // Create parent menu item for the image set menu
        let imageSetMenuItem = NSMenuItem(title: "Select Image Set", action: nil, keyEquivalent: "")
        imageSetMenuItem.submenu = imageSetMenu
        
        // Return parent menu item including the submenu
        return imageSetMenuItem
    }
    
    @objc private func selectPartyParrotSet() {
        loadImageSet(named: "parrot", isGIF: false)
    }
    
    @objc private func openHelp() {
        if let helpWindow = helpWindowController?.window {
            if helpWindow.isVisible {
                helpWindowController?.close() // Close if already open
            } else {
                helpWindowController?.showWindow(self) // Show help window
            }
        }
    }
}
