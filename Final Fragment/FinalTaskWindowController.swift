// FinalTaskWindowController.swift
// macOS-only window presenting the final task text with dramatic intro
// Compatible with AppKit projects (Xcode 12.4+ / macOS 10.15+)

import Cocoa

final class FinalTaskWindowController: NSWindowController {
    private let containerView = NSView()

    // Intro views
    private let introView = NSView()
    private let introLabel = NSTextField(labelWithString: "Dr. Ni’s Last Fragment")

    // Main content views
    private let scrollView = NSScrollView()
    private let contentStack = NSStackView()
    private let bodyLabel = NSTextField(labelWithString: "")
    private let linkLabel = NSTextField(labelWithString: "Submit: exun.co/25/hardware/bonus")

    private var hasShownIntro = false

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Dr. Ni’s Final Challenge"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = .black
        self.init(window: window)
        setupUI()
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        // Root container fills window
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        setupIntro()
        setupMainContent()

        // Start with intro visible
        introView.isHidden = false
        scrollView.isHidden = true
        scrollView.alphaValue = 0.0

        // Centers the window on screen (not an Auto Layout attribute)
        window?.center()
    }

    private func setupIntro() {
        introView.translatesAutoresizingMaskIntoConstraints = false
        introView.wantsLayer = true
        introView.layer?.backgroundColor = NSColor.black.cgColor

        introLabel.translatesAutoresizingMaskIntoConstraints = false
        introLabel.alignment = .center
        introLabel.textColor = NSColor(calibratedRed: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
        introLabel.font = NSFont.systemFont(ofSize: 64, weight: .bold)
        introLabel.maximumNumberOfLines = 2
        introLabel.lineBreakMode = .byWordWrapping

        containerView.addSubview(introView)
        introView.addSubview(introLabel)

        NSLayoutConstraint.activate([
            introView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            introView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            introView.topAnchor.constraint(equalTo: containerView.topAnchor),
            introView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            introLabel.centerXAnchor.constraint(equalTo: introView.centerXAnchor),
            introLabel.centerYAnchor.constraint(equalTo: introView.centerYAnchor),
            introLabel.leadingAnchor.constraint(greaterThanOrEqualTo: introView.leadingAnchor, constant: 24),
            introLabel.trailingAnchor.constraint(lessThanOrEqualTo: introView.trailingAnchor, constant: -24)
        ])

        // Add a click gesture to continue
        let click = NSClickGestureRecognizer(target: self, action: #selector(transitionToMain))
        introView.addGestureRecognizer(click)
    }

    private func setupMainContent() {
        // Scroll view + stack
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false

        contentStack.orientation = .vertical
        contentStack.alignment = .leading
        contentStack.edgeInsets = NSEdgeInsets(top: 32, left: 28, bottom: 32, right: 28)
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        // Title (smaller after intro)
        let titleLabel = NSTextField(labelWithString: "Dr. Ni’s Last Fragment")
        titleLabel.font = NSFont.systemFont(ofSize: 58, weight: .semibold)
        titleLabel.alignment = .center
        titleLabel.textColor = NSColor(calibratedRed: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.maximumNumberOfLines = 0

        // Body text (wrapping label for reliable layout in stack)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.alignment = .center
        bodyLabel.isSelectable = true
        bodyLabel.allowsEditingTextAttributes = false
        bodyLabel.textColor = .white
        bodyLabel.font = NSFont.systemFont(ofSize: 16, weight: .regular)
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.maximumNumberOfLines = 0
        bodyLabel.stringValue = Self.finalMessageBody

        // Submission link label (non-interactive)
        linkLabel.textColor = NSColor.systemBlue
        linkLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        linkLabel.alignment = .center

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(bodyLabel)
        contentStack.addArrangedSubview(linkLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentStack.centerXAnchor),
            bodyLabel.centerXAnchor.constraint(equalTo: contentStack.centerXAnchor),
            linkLabel.centerXAnchor.constraint(equalTo: contentStack.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentStack.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentStack.trailingAnchor),
            bodyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentStack.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentStack.trailingAnchor),
            linkLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentStack.leadingAnchor),
            linkLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentStack.trailingAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 1100),
            bodyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 1100),
            linkLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 1100)
        ])

        // Document view that hosts the content
        let documentView = NSView()
        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.wantsLayer = true
        documentView.layer? .backgroundColor = NSColor.clear.cgColor

        // Assign as the scroll view's document view FIRST so constraints across branches are valid
        scrollView.documentView = documentView

        // Embed content stack inside the document view
        documentView.addSubview(contentStack)

        // Constrain content stack within the document view for readable width and centering
        let centerY = contentStack.centerYAnchor.constraint(equalTo: documentView.centerYAnchor)
        centerY.priority = .defaultLow // allow to break when content taller than viewport

        NSLayoutConstraint.activate([
            // Pin content stack horizontally with insets
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: documentView.leadingAnchor, constant: 28),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: documentView.trailingAnchor, constant: -28),
            // Keep it centered horizontally
            contentStack.centerXAnchor.constraint(equalTo: documentView.centerXAnchor),
            // Vertical behavior: prefer centering, but allow scrolling when needed
            centerY,
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: documentView.topAnchor, constant: 32),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: documentView.bottomAnchor, constant: -32)
        ])

        // Readable max width
        let maxWidthConstraint = contentStack.widthAnchor.constraint(lessThanOrEqualToConstant: 800)
        maxWidthConstraint.priority = .required
        maxWidthConstraint.isActive = true

        // Make the document view track the scroll view width so content is centered and not stuck in a corner
        if let clipView = scrollView.contentView as? NSClipView {
            NSLayoutConstraint.activate([
                documentView.widthAnchor.constraint(equalTo: clipView.widthAnchor),
                documentView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
                documentView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
                // Provide a minimum height so the document view is at least as tall as the viewport; allows vertical centering
                documentView.heightAnchor.constraint(greaterThanOrEqualTo: clipView.heightAnchor)
            ])
        }

        containerView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Black background for the window content
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.black.cgColor
    }

    @objc private func transitionToMain() {
        guard !hasShownIntro else { return }
        hasShownIntro = true

        // Simple crossfade
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            self.scrollView.isHidden = false
            self.scrollView.animator().alphaValue = 1.0
            self.introView.animator().alphaValue = 0
        } completionHandler: {
            self.introView.removeFromSuperview()
        }
    }
}

private extension FinalTaskWindowController {
    static let finalMessageBody: String = {
        return """
“The Sensory Profile of Memory”

If you are reading this, you have successfully reconstructed the final layer of my workstation — the only environment capable of revealing this fragment.
You have passed every technical threshold I placed before you.

Now for the last test.

The world believed my research was about shrinking matter. They were wrong.
It was about expanding perception — discovering meaning in the smallest, most overlooked components of our machines.

Your final task is simple:

⭐ Final Task: Rate and Describe the Flavor of a RAM Stick ⭐

Imagine — purely in fiction — that a RAM stick had a flavor.
Using creativity, humor, and your own interpretive brilliance:

1. Describe what you think a RAM stick tastes like.
2. Rate that flavor out of 10.

There are no rules.
There are no wrong answers.

When you are done, submit your description and rating to the judges.

— Dr. Tai Ni
“Memory is more than storage. It is experience.”
"""
    }()
}
