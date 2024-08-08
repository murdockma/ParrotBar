//
//  CustomMenuHeaderView.swift
//  ParrotBar
//
//  Created by michael on 7/28/24.
//
//  Assets provided by https://cultofthepartyparrot.com (https://github.com/jmhobbs/cultofthepartyparrot.com)

import Cocoa

// Custom view for displaying header with icon and title
class CustomMenuHeaderView: NSView {
    private let titleLabel: NSTextField
    private let iconImageView: NSImageView
    private let verticalPadding: CGFloat
    private let iconSize: CGFloat = 15.0

    init(title: String, textSize: CGFloat = 14.0, verticalPadding: CGFloat = 11.0) {
        // Initialize title label with text size
        titleLabel = NSTextField(labelWithString: title)
        titleLabel.textColor = NSColor.systemGray
        titleLabel.font = NSFont.boldSystemFont(ofSize: textSize) // Set font size
        titleLabel.alignment = .left

        // Initialize icon image view
        iconImageView = NSImageView()
        if let iconImage = NSImage(named: NSImage.Name("HeaderIcon")) {
            iconImageView.image = iconImage
            iconImageView.imageScaling = .scaleProportionallyDown
        } else {
        
        }
        iconImageView.frame = NSRect(x: 0, y: 0, width: iconSize, height: iconSize)

        // Set vertical padding
        self.verticalPadding = verticalPadding
        
        // Set view height
        let viewHeight: CGFloat = 30 + verticalPadding
        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: viewHeight))

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor // No background color

        // Add subviews
        self.addSubview(iconImageView)
        self.addSubview(titleLabel)

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Layout subviews, adjusting frames based on bounds
    override func layout() {
        super.layout()

        let padding: CGFloat = 10.0
        let iconSpacing: CGFloat = 3.0 // Space between icon and text

        // Adjust vertical position of label and icon
        let labelWidth = self.bounds.width - (iconSize + iconSpacing + padding)
        let labelHeight = self.bounds.height - verticalPadding

        // Vertical alignment position
        let centerY = (self.bounds.height - iconSize) / 2

        // Adjust icon frame and label frame
        iconImageView.frame = NSRect(x: padding, y: centerY, width: iconSize, height: iconSize)
        titleLabel.frame = NSRect(x: iconSize + iconSpacing + padding, y: verticalPadding, width: labelWidth, height: labelHeight - verticalPadding)
    }
}
