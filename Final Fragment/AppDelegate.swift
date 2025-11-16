//
//  AppDelegate.swift
//  Final Fragment
//
//  Created by Aradhya🐉 on 16/11/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var finalTaskWindowController: FinalTaskWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Show the Final Task window on launch
        showFinalTaskWindow()
        // Close any extra windows that may have been created by a nib/storyboard
        for win in NSApp.windows {
            if win !== finalTaskWindowController?.window {
                win.close()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Window Management
    private func showFinalTaskWindow() {
        // Lazily create the controller if needed
        if finalTaskWindowController == nil {
            finalTaskWindowController = FinalTaskWindowController()
        }
        guard let controller = finalTaskWindowController else { return }
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // If there are no visible windows, show our main window
        if !flag {
            showFinalTaskWindow()
        } else {
            // If already visible, just bring to front
            finalTaskWindowController?.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        return true
    }

    // MARK: - Actions
    @IBAction func showFinalTaskWindow(_ sender: Any?) {
        showFinalTaskWindow()
    }
}

