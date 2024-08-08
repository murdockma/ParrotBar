//
//  AppDelegate+Animations.swift
//  ParrotBar
//
//  Created by michael on 7/26/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa

// MARK: - Animation Management

extension AppDelegate {
    @objc internal func toggleAnimation() {
        if isAnimating {
            stopAnimation()
        } else {
            isAnimating = true
            startAnimation()
        }
    }
    
    // Starts animation by creating/executing a new thread that cycles through images
    internal func startAnimation() {
        // Cancel any previously running animation thread
        if let workItem = animationWorkItem {
            workItem.cancel()
            #if DEBUG
            logger.debug("Previous animation thread canceled before starting new one")
            #endif
        }

        // Create new work item for animation
        animationWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            while self.isAnimating {
                DispatchQueue.main.async {
                    guard !self.imageViews.isEmpty else { return }
                    // Cycle through image frames
                    self.currentFrame = (self.currentFrame + 1) % self.imageViews.count
                    self.statusBarItem?.button?.image = self.imageViews[self.currentFrame]
                }
                Thread.sleep(forTimeInterval: 0.06)
            }
        }

        animationQueue.async(execute: animationWorkItem!)
        #if DEBUG
        logger.debug("New animation thread started")
        #endif
    }

    // Stops animation by canceling current thread and updating state
    internal func stopAnimation() {
        if let workItem = animationWorkItem {
            workItem.cancel()
            animationWorkItem = nil
        }

        if isAnimating {
            isAnimating = false
        }
    }
}
