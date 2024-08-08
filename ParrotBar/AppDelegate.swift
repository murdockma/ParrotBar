//
//  AppDelegate.swift
//  ParrotBar
//
//  Created by michael on 7/26/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa
import IOKit
import IOKit.ps
import Foundation
import ObjectiveC.runtime
import MachO
import os.log
import Network
import SystemConfiguration

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    internal var statusBarItem: NSStatusItem?
    internal var imageViews: [NSImage] = []
    internal var currentFrame: Int = 0
    internal var isAnimating: Bool = true
    internal let imageManager = ImageManager()
    internal let animationQueue = DispatchQueue(label: "com.example.animationQueue")
    internal var animationWorkItem: DispatchWorkItem?
    internal var didFallbackToDefaultSet = false
    internal var helpWindowController: HelpWindowController?
    
    internal let favoritesKey = "favoritesKey"
    
    // Current list of favorites
    internal var favorites: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: favoritesKey)
        }
    }
    
    // System information labels
    internal var systemUptimeItem: NSMenuItem!
    internal var diskUsageItem: NSMenuItem!
    internal var residentMemoryUsageItem: NSMenuItem!
    internal var publicNetworkItem: NSMenuItem!
    internal var randomModeMenuItem: NSMenuItem!
    internal var currentGIFNameItem: NSMenuItem!
    
    // Logger
    internal let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppDelegate")
    
    // Timer for random image set mode
    internal var randomImageSetTimer: Timer?
    internal var isRandomModeEnabled: Bool = false
    
    // Timer for periodic system info updates
    private var systemInfoUpdateTimer: Timer?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDynamicMethods()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up menu items and load default img set
        setupStatusBarItem()
        setupMenu()
        loadImageSet(named: "parrot", isGIF: false)
        setupDynamicMethods()
        helpWindowController = HelpWindowController()
        
        // Fetch public IP address
        getPublicIPAddress { [weak self] ipAddress in
            DispatchQueue.main.async {
                if let ipAddress = ipAddress {
                    self?.publicNetworkItem.title = "Public IP: \(ipAddress)"
                } else {
                    self?.publicNetworkItem.title = "Public IP: Unknown"
                }
            }
        }
        
        // Update system info
        updateSystemInfo()
        
        // Set up periodic updates for system info
        systemInfoUpdateTimer = Timer.scheduledTimer(
            timeInterval: 300.0,
            target: self,
            selector: #selector(updateSystemInfo),
            userInfo: nil,
            repeats: true
        )
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        stopAnimation()
        randomImageSetTimer?.invalidate() // Stop the timer
        systemInfoUpdateTimer?.invalidate() // Stop the system info update timer
    }
    
    @objc internal func quit() {
        NSApp.terminate(nil)
    }
}
