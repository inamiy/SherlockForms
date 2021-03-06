import SwiftUI
import SherlockHUD

@main
struct MyApp: App
{
    var body: some Scene
    {
        WindowGroup {
            NavigationView {
                RootView()
            }
            .enableSherlockHUD(true)
        }
    }
}
