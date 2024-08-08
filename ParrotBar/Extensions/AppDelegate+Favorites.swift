//
//  AppDelegate+Favorites.swift
//  ParrotBar
//
//  Created by michael on 7/26/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa

// MARK: - Favorites

extension AppDelegate {
    // Populate existing favorites
    internal func addFavoritesToMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        
        for favorite in favorites {
            let favoriteItem = NSMenuItem(title: favorite, action: #selector(selectFavorite(_:)), keyEquivalent: "")
            favoriteItem.representedObject = favorite
            menu.addItem(favoriteItem)
        }
    }
    
    // Add new favorites and register selectors
    @objc internal func addToFavorites() {
        guard let imageSetName = getCurrentImageSetName() else { return }

        if !favorites.contains(imageSetName) {
            favorites.append(imageSetName)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
            
            // Register selector for the new favorite
            let index = favorites.count - 1
            registerFavoriteSelector(for: imageSetName, at: index)
        }
    }
    
    // Load image set upon selection of favorite
    @objc private func selectFavorite(_ sender: NSMenuItem) {
        guard let favorite = sender.representedObject as? String else { return }
        didFallbackToDefaultSet = false
            
        // Load the favorite as a GIF
        loadImageSet(named: favorite, isGIF: true)
        
        // If fallback was used, try loading as non-GIF
        if didFallbackToDefaultSet {
            loadImageSet(named: favorite, isGIF: false)
        }
    }
    
    @objc internal func clearFavorites() {
        favorites.removeAll()
        UserDefaults.standard.removeObject(forKey: favoritesKey)
        
        // Update the favorites menu
        if let favoritesMenu = statusBarItem?.menu?.item(withTitle: "Favorites")?.submenu {
            favoritesMenu.removeAllItems()
        }
    }
    
    private func registerFavoriteSelector(for favorite: String, at index: Int) {
        guard let menu = statusBarItem?.menu?.item(withTitle: "Favorites")?.submenu else { return }

        let selectorName = "selectFavorite:"
        let selector = NSSelectorFromString(selectorName)

        // Add the new menu item for the favorite
        let menuItem = NSMenuItem(title: favorite, action: selector, keyEquivalent: "")
        menuItem.representedObject = favorite // Store the favorite string in representedObject
        menuItem.target = self // Set the target to self so the selector method will be called
        menu.addItem(menuItem)
        #if DEBUG
        logger.debug("Menu item added for: \(favorite)")
        #endif
    }
    
    private func getCurrentImageSetName() -> String? {
        guard let title = currentGIFNameItem?.title else { return nil }
        let components = title.split(separator: ":")
        return components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : nil
    }
}
