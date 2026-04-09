import SwiftUI

struct ControlView: View {
    @ObservedObject var delegate: IgaDelegate

    var body: some View {
        VStack(spacing: 14) {
            Text("ㄹㅇ이가")
                .font(.headline)

            Label(
                delegate.hasAccessibilityPermission ? "접근성 권한 허용됨" : "접근성 권한 필요",
                systemImage: delegate.hasAccessibilityPermission ? "checkmark.shield" : "exclamationmark.shield"
            )
            .font(.subheadline)
            .foregroundStyle(delegate.hasAccessibilityPermission ? Color.secondary : Color.orange)

            Text(delegate.permissionMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Label(
                delegate.isEnabled ? "입력 치환 켜짐" : "입력 치환 꺼짐",
                systemImage: delegate.isEnabled ? "power.circle.fill" : "power.circle"
            )
            .font(.subheadline)
            .foregroundStyle(delegate.isEnabled ? .secondary : .secondary)

            if !delegate.hasAccessibilityPermission {
                Button("권한 다시 확인") {
                    delegate.retryAccessibilityPermission()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }

            Button(action: {
                delegate.isEnabled.toggle()
            }) {
                Text(delegate.isEnabled ? "ㄹㅇ아니가" : "ㄹㅇ이가")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(delegate.isEnabled ? .orange : .blue)
            .disabled(!delegate.hasAccessibilityPermission)

            Button(action: {
                NSApp.terminate(nil)
            }) {
                Text("ㄹㅇ끝이가")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
            }
            .buttonStyle(.bordered)
        }
        .padding(20)
        .frame(width: 260)
    }
}
