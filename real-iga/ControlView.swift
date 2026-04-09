import SwiftUI

struct ControlView: View {
    @ObservedObject var delegate: IgaDelegate

    var body: some View {
        VStack(spacing: 16) {
            Text("ㄹㅇ이가")
                .font(.headline)

            HStack(spacing: 6) {
                Circle()
                    .fill(delegate.isEnabled ? Color.green : Color.gray)
                    .frame(width: 10, height: 10)
                Text(delegate.isEnabled ? "ㄹㅇ이가" : "ㄹㅇ아니가")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            Button(action: {
                delegate.isEnabled.toggle()
            }) {
                Text(delegate.isEnabled ? "ㄹㅇ아니가" : "ㄹㅇ이가")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(delegate.isEnabled ? .orange : .blue)

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
        .frame(width: 220)
    }
}
