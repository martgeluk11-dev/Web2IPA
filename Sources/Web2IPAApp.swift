import SwiftUI

@main
struct Web2IPAApp: App {
    var body: some Scene {
        WindowGroup {
            WebContainerView()
                .preferredColorScheme(.light)
        }
    }
}
