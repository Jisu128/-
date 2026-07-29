import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("공주님의 집", systemImage: "house.fill") }

            HistoryView()
                .tabItem { Label("운동 일기", systemImage: "book.fill") }

            StoryView()
                .tabItem { Label("성장 스토리", systemImage: "sparkles") }
        }
        .tint(Theme.pink)
        .sheet(item: $game.celebrationStage) { stage in
            CelebrationView(stage: stage)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameState())
}
