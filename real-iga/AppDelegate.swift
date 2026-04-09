import Cocoa
import ApplicationServices
import SwiftUI
import Combine

class IgaDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    var eventTap: CFMachPort?
    var runLoopSource: CFRunLoopSource?
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    @Published var isEnabled: Bool = true {
        didSet {
            syncEventTapState()
            DispatchQueue.main.async { self.updateStatusIcon() }
        }
    }

    @Published private(set) var hasAccessibilityPermission: Bool = false
    @Published private(set) var permissionMessage: String = "접근성 권한을 확인하는 중입니다."

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )

        refreshAccessibilityPermission(prompt: true)
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopKeyListener()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "real-iga 상태")
            button.action = #selector(togglePopover)
            button.target = self
        }

        let pop = NSPopover()
        pop.contentSize = NSSize(width: 260, height: 220)
        pop.behavior = .transient
        pop.contentViewController = NSHostingController(
            rootView: ControlView(delegate: self)
        )
        self.popover = pop
    }

    func updateStatusIcon() {
        let symbolName: String
        let description: String

        if !hasAccessibilityPermission {
            symbolName = "exclamationmark.shield"
            description = "real-iga 접근성 권한 필요"
        } else if isEnabled {
            symbolName = "keyboard.fill"
            description = "real-iga 활성화됨"
        } else {
            symbolName = "keyboard"
            description = "real-iga 비활성화됨"
        }

        statusItem?.button?.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: description)
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

    @objc func handleApplicationDidBecomeActive() {
        refreshAccessibilityPermission(prompt: false)
    }

    func retryAccessibilityPermission() {
        refreshAccessibilityPermission(prompt: true)
    }

    func refreshAccessibilityPermission(prompt: Bool) {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt]
        let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

        hasAccessibilityPermission = isTrusted

        if isTrusted {
            startKeyListenerIfNeeded()
            permissionMessage = isEnabled
                ? "접근성 권한이 활성화되어 있습니다."
                : "접근성 권한은 활성화되어 있고 현재 입력 치환은 꺼져 있습니다."
        } else {
            stopKeyListener()
            permissionMessage = "시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용에서 real-iga를 허용한 뒤 '권한 다시 확인'을 눌러주세요."
        }

        updateStatusIcon()
    }

    func startKeyListenerIfNeeded() {
        guard hasAccessibilityPermission else { return }

        if eventTap != nil {
            syncEventTapState()
            return
        }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon in
                guard type == .keyDown else { return Unmanaged.passUnretained(event) }

                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let delegate = Unmanaged<IgaDelegate>.fromOpaque(refcon).takeUnretainedValue()
                guard delegate.isEnabled, delegate.hasAccessibilityPermission else {
                    return Unmanaged.passUnretained(event)
                }

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
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let tap = eventTap else {
            permissionMessage = "키보드 감시를 시작하지 못했습니다. 권한을 다시 확인해주세요."
            updateStatusIcon()
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        syncEventTapState()
    }

    func stopKeyListener() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        runLoopSource = nil
        eventTap = nil
    }

    func syncEventTapState() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: hasAccessibilityPermission && isEnabled)
    }
}
