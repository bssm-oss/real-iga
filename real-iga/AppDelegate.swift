import Cocoa
import ApplicationServices
import SwiftUI
import Combine

class IgaDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    var eventTap: CFMachPort?
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    @Published var isEnabled: Bool = true {
        didSet {
            guard let tap = eventTap else { return }
            CGEvent.tapEnable(tap: tap, enable: isEnabled)
            DispatchQueue.main.async { self.updateStatusIcon() }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()
        startKeyListener()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: "iga")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        let pop = NSPopover()
        pop.contentSize = NSSize(width: 220, height: 150)
        pop.behavior = .transient
        pop.contentViewController = NSHostingController(
            rootView: ControlView(delegate: self)
        )
        self.popover = pop
    }
    
    func updateStatusIcon() {
        let name = isEnabled ? "keyboard.fill" : "keyboard"
        statusItem?.button?.image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button, let pop = popover else { return }
        if pop.isShown {
            pop.performClose(nil)
        } else {
            pop.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            pop.contentViewController?.view.window?.makeKey()
        }
    }
    
    func startKeyListener() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        guard AXIsProcessTrustedWithOptions(opts as CFDictionary) else {
            print("❌ 접근성 권한 없음"); return
        }
        print("✅ 접근성 권한 확인됨")
        
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon in
                guard type == .keyDown else { return Unmanaged.passRetained(event) }
                
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let delegate = Unmanaged<real_iga.IgaDelegate>.fromOpaque(refcon).takeUnretainedValue()
                guard delegate.isEnabled else { return Unmanaged.passRetained(event) }
                
                var length = 0
                var buffer = [UniChar](repeating: 0, count: 4)
                event.keyboardGetUnicodeString(maxStringLength: 4,
                                               actualStringLength: &length,
                                               unicodeString: &buffer)
                let str = String(utf16CodeUnits: buffer, count: length)
                
                if str == "ㄹ" || str == "f" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        let pb = NSPasteboard.general
                        pb.clearContents()
                        pb.setString("ㄹㅇ이가 ", forType: .string)
                        
                        func post(_ key: CGKeyCode, down: Bool, cmd: Bool = false) {
                            let e = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: down)!
                            if cmd { e.flags = .maskCommand }
                            e.post(tap: .cgAnnotatedSessionEventTap)
                        }
                        post(51, down: true);  post(51, down: false)
                        post(9,  down: true,  cmd: true)
                        post(9,  down: false, cmd: true)
                    }
                    return nil
                }
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        guard let tap = eventTap else { print("❌ eventTap 생성 실패"); return }
        print("✅ eventTap 생성 성공")
        
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        CFRunLoopRun()
    }
}
