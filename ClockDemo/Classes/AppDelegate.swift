import AppKit
import ScreenSaver

@NSApplicationMain final class AppDelegate: NSObject {
	
	// MARK: - Properties

	@IBOutlet var window: NSWindow!
	
	let view: ScreenSaverView = {
		let view = MainView(frame: .zero, isPreview: false)!
		view.autoresizingMask = [.width, .height]
		return view
	}()


	// MARK: - Initializers

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - Actions
	
	@IBAction func showPreferences(_ sender: Any?) {
		guard let sheet = view.configureSheet else { return }

		window.beginSheet(sheet) { [weak sheet] _ in
			sheet?.close()
		}
	}
	
	
	// MARK: - Private

	@objc private func preferencesDidChange(_ notification: NSNotification?) {
		let preferences = (notification?.object as? Preferences) ?? Preferences()
		window.title = "Clock.saver — \(preferences.modelName)\(preferences.styleName)"
	}
}


extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		guard let contentView = window.contentView else {
			fatalError("Missing window content view")
		}

		// Add the clock view to the window
		view.frame = contentView.bounds
		contentView.addSubview(view)
		
		// Start animating the clock
		view.startAnimation()
        Timer.scheduledTimer(timeInterval: view.animationTimeInterval, target: view,
                             selector: #selector(ScreenSaverView.animateOneFrame), userInfo: nil, repeats: true)

		NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange),
                                               name: .PreferencesDidChange, object: nil)
		preferencesDidChange(nil)
	}
}


extension AppDelegate: NSWindowDelegate {
	func windowWillClose(_ notification: Notification) {
		// Quit the app if the main window is closed
		NSApplication.shared.terminate(window)
	}
}
