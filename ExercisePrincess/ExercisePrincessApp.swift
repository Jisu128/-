import SwiftUI

@main
struct ExercisePrincessApp: App {
    @StateObject private var game = GameState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
        }
    }
}
