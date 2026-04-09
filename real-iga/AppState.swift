import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isEnabled: Bool = true
}
