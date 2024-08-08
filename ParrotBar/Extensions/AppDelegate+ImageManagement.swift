//
//  AppDelegate+ImageManagement.swift
//  ParrotBar
//
//  Created by michael on 7/26/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa

// MARK: - Image Management

extension AppDelegate {
    internal func loadImageSet(named setName: String, isGIF: Bool) {
        let previousAnimatingState = isAnimating
        
        // Clear out existing images for new ones
        imageViews.removeAll()

        // Attempt to load the image set
        imageManager.loadImageSetFromDisk(named: setName, isGIF: isGIF) { images in
            if images.isEmpty {
                #if DEBUG
                self.logger.debug("No images loaded for \(setName). Defaulting to PartyParrot set")
                #endif
                self.didFallbackToDefaultSet = true
                
                // Load default image set if selected set not found
                self.imageManager.loadImageSetFromDisk(named: "parrot", isGIF: false) { defaultImages in
                    // Update UI with default image set
                    self.updateUI(with: defaultImages, fileName: "PartyParrot", previousAnimatingState: previousAnimatingState)
                }
            } else {
                self.didFallbackToDefaultSet = false
                
                // Update UI with images from the selected set
                self.updateUI(with: images, fileName: setName, previousAnimatingState: previousAnimatingState)
            }
        }
    }

    private func updateUI(with images: [NSImage], fileName: String, previousAnimatingState: Bool) {
        // Ensure theres images to display
        guard !images.isEmpty else {
            #if DEBUG
            self.logger.error("No images to display for \(fileName)")
            #endif
            return
        }

        // Resize image to fit UI
        let resizedImages = images.map {
            self.imageManager.resizedImage(
                image: $0, to: NSSize(width: 27, height: 27), fileName: fileName
            ) ?? $0
        }

        // Update UI on main thread
        DispatchQueue.main.async {
            // Set resized images and initialize animation frame
            self.imageViews = resizedImages
            self.currentFrame = 0
            // Set first image as status bar icon
            self.statusBarItem?.button?.image = self.imageViews.first
            
            // Restart animation if previously active
            if previousAnimatingState {
                self.startAnimation()
            }
            // Update menu item to show name of current image set
            self.currentGIFNameItem.title = "Current Image Set: \(fileName)"
        }
    }
    
    // Retrieves all GIF files from app bundle and registers animation sets
    internal func setupDynamicMethods() {
        let gifFiles = findGIFFilesInBundle()
        registerAnimationSets(from: gifFiles)
    }

    // Finds and returns a list of GIF files in the apps resource bundle
    internal func findGIFFilesInBundle() -> [String] {
        var gifFiles: [String] = []
        guard let bundlePath = Bundle.main.resourcePath else {
            #if DEBUG
            logger.error("Resource path not found")
            #endif
            return []
        }

        let fileManager = FileManager.default
        do {
            // Get contents of directory at the bundle path
            let contents = try fileManager.contentsOfDirectory(atPath: bundlePath)
            
            // Filter to only include GIFs
            gifFiles = contents.filter {
                let filePath = (bundlePath as NSString).appendingPathComponent($0)
                let fileURL = URL(fileURLWithPath: filePath)
                return fileURL.pathExtension.lowercased() == "gif"
            }
            #if DEBUG
            logger.debug("GIF files found: \(gifFiles)")
            #endif
        } catch {
            #if DEBUG
            logger.error("Error reading bundle content: \(error)")
            #endif
        }

        return gifFiles
    }
    
    // Registers selectable animation sets for GIF files in the status bar menu
    private func registerAnimationSets(from gifFiles: [String]) {
        // Get submenu for selecting image sets and sort GIFs
        guard let menu = statusBarItem?.menu?.item(withTitle: "Select Image Set")?.submenu else { return }
        let sortedGifFiles = gifFiles.sorted()
        var seperatorAdded = false
        
        for gifFile in sortedGifFiles {
            // Get the animation name
            let animationName = gifFile.replacingOccurrences(of: ".gif", with: "")
            let selectorName = "select\(animationName)Set"
            let selector = NSSelectorFromString(selectorName)
            
            // Create block implementation to load the image set
            let implementation: @convention(block) () -> Void = {
                self.loadImageSet(named: animationName, isGIF: true)
            }
            
            // Add block as method to the AppDelegate class
            let imp = imp_implementationWithBlock(implementation)
            if class_addMethod(AppDelegate.self, selector, imp, "v@:") {
                #if DEBUG
                logger.debug("Method \(selectorName) added successfully")
                #endif
            } else {
                #if DEBUG
                logger.error("Failed addding method: \(selectorName)")
                #endif
            }
            
            // Add seperator after primary (capitalized) selectors
            let isLower = animationName == animationName.lowercased()
            if isLower && !seperatorAdded {
                menu.addItem(NSMenuItem(title: "— More Sets", action: nil, keyEquivalent: ""))
                seperatorAdded = true
            }
            
            // Add menu item for dynamically created selector
            let menuItem = NSMenuItem(title: animationName, action: selector, keyEquivalent: "")
            menu.addItem(menuItem)
            #if DEBUG
            logger.debug("Menu item added for: \(animationName)")
            #endif
        }
    }
}
