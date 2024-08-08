//
//  ImageManager.swift
//  ParrotBar
//
//  Created by michael on 7/28/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)


import Cocoa
import ImageIO
import os

// Manages image loading, resizing, and caching for the app
class ImageManager {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ImageManager")

    private var noYOffsetFiles: Set<String> = []
    private var reducedYOffsetFiles: Set<String> = []
    private var extraYOffsetFiles: Set<String> = []
    
    // In-memory caches
    private var imageCache = [String: [NSImage]]()
    private var gifCache = [String: [NSImage]]()

    init() {
        loadOffsets()
    }
    
    // Loads offset configs from JSON file
    private func loadOffsets() {
        guard let url = Bundle.main.url(forResource: "Offsets", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]] else {
            #if DEBUG
            logger.error("Failed to load or parse offsets file")
            #endif
            return
        }
    
        noYOffsetFiles = Set(json["noYOffsetFiles"] ?? [])
        reducedYOffsetFiles = Set(json["reducedYOffsetFiles"] ?? [])
        extraYOffsetFiles = Set(json["extraYOffsetFiles"] ?? [])
        #if DEBUG
        logger.debug("Offsets loaded successfully")
        #endif
    }

    // Resizes image
    func resizedImage(image: NSImage, to desiredSize: NSSize, padding: CGFloat = 0.0, fileName: String? = nil) -> NSImage? {
        let imageSize = image.size
        let imageAspectRatio = imageSize.width / imageSize.height
        let desiredAspectRatio = desiredSize.width / desiredSize.height

        var drawSize = desiredSize
        if imageAspectRatio > desiredAspectRatio {
            drawSize.height = desiredSize.width / imageAspectRatio
            drawSize.width = desiredSize.width
        } else {
            drawSize.width = desiredSize.height * imageAspectRatio
            drawSize.height = desiredSize.height
        }

        let baseFileName = fileName?.components(separatedBy: CharacterSet.decimalDigits).first ?? ""
        let yOffset = calculateYOffset(for: baseFileName)
        #if DEBUG
        logger.debug("yOffset for file \(baseFileName): \(yOffset)")
        #endif
    
        let imageRect = NSRect(
            x: (desiredSize.width - drawSize.width) / 2.0,
            y: (desiredSize.height - drawSize.height) / 2.0 + yOffset,
            width: drawSize.width,
            height: drawSize.height
        )

        let resizedImage = NSImage(size: desiredSize)
        resizedImage.lockFocus()

        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: desiredSize)).fill()

        image.draw(
            in: imageRect,
            from: NSRect(origin: .zero, size: image.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        resizedImage.unlockFocus()
        
        #if DEBUG
        logger.debug("Resized image with size \(String(describing: desiredSize)) and yOffset \(yOffset)")
        #endif

        return resizedImage
    }

    // Calculates offset value for file name
    private func calculateYOffset(for fileName: String) -> CGFloat {
        if noYOffsetFiles.contains(fileName) {
            return 0.0
        } else if extraYOffsetFiles.contains(fileName) {
            return 4
        } else if reducedYOffsetFiles.contains(fileName) {
            return 1.6
        } else {
            return 2.8
        }
    }

    // Loads image set from disk, either static images or a GIF
    func loadImageSetFromDisk(named setName: String, isGIF: Bool, completion: @escaping ([NSImage]) -> Void) {
        if isGIF {
            if let cachedImages = gifCache[setName] {
                #if DEBUG
                logger.debug("Loading GIF from cache: \(setName)")
                #endif
                completion(cachedImages)
                return
            }

            guard let gifURL = Bundle.main.url(forResource: setName, withExtension: "gif") else {
                #if DEBUG
                logger.error("Failed to find GIF with name \(setName)")
                #endif
                completion([])
                return
            }
            
            #if DEBUG
            logger.debug("Loading GIF from URL: \(gifURL)")
            #endif
            let images = extractFrames(from: gifURL)
            gifCache[setName] = images
            completion(images)
        } else {
            if let cachedImages = imageCache[setName] {
                #if DEBUG
                logger.debug("Loading static images from cache: \(setName)")
                #endif
                completion(cachedImages)
                return
            }

            let imageNames = (1...10).map { "\(setName)\($0)" }
            #if DEBUG
            logger.debug("Loading static images: \(imageNames.joined(separator: ", "))")
            #endif
            
            let images: [NSImage] = imageNames.compactMap { imageName in
                guard let image = NSImage(named: imageName) else {
                    #if DEBUG
                    logger.error("Failed to load image: \(imageName)")
                    #endif
                    return nil
                }
                let newSize = NSSize(width: 32, height: 32)
                return resizedImage(image: image, to: newSize, padding: 0.0, fileName: imageName)
            }
            
            imageCache[setName] = images
            #if DEBUG
            logger.debug("Loaded \(images.count) static images")
            #endif
            completion(images)
        }
    }

    // Extracts frames from GIF file at the URL
    private func extractFrames(from gifURL: URL) -> [NSImage] {
        var images: [NSImage] = []

        guard let source = CGImageSourceCreateWithURL(gifURL as CFURL, nil) else {
            #if DEBUG
            logger.error("Failed to create image source for \(gifURL)")
            #endif
            return images
        }

        let count = CGImageSourceGetCount(source)
        #if DEBUG
        logger.debug("Extracting \(count) frames from \(gifURL)")
        #endif

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = NSImage(cgImage: cgImage, size: NSZeroSize)
                images.append(image)
            } else {
                #if DEBUG
                logger.error("Failed to create CGImage for \(i)")
                #endif
            }
        }
        
        #if DEBUG
        logger.debug("Extracted \(images.count) frames from GIF")
        #endif
        return images
    }
}
