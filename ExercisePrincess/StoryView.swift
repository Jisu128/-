import SwiftUI

/// 성장 스토리: 전체 스테이지 로드맵을 한눈에 보여줘요.
struct StoryView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(Stage.all) { stage in
                            stageRow(stage)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("✨ 성장 스토리")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func stageRow(_ stage: Stage) -> some View {
        let isCurrent = stage.id == game.stage.id
        let isUnlocked = stage.id <= game.stage.id

        return HStack(spacing: 14) {
            Text(isUnlocked ? stage.houseEmoji : "🔒")
                .font(.system(size: 40))
                .frame(width: 60)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(isUnlocked ? stage.houseName : "???")
                        .font(.subheadline.bold())
                        .foregroundStyle(Theme.textBrown)
                    if isCurrent {
                        Text("지금 여기!")
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Theme.pink))
                            .foregroundStyle(.white)
                    }
                }

                Text(isUnlocked ? "\(stage.princessEmoji) \(stage.title)" : "운동을 계속하면 열려요")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isUnlocked {
                    Text(stage.story)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                if stage.requiredNetWorth != Int.min {
                    Text(stage.requiredNetWorth <= 0
                         ? "빚 \((Stage.startingDebt + stage.requiredNetWorth).goldString) 갚으면 도달"
                         : "자산 \(stage.requiredNetWorth.goldString) 모으면 도달")
                        .font(.caption2)
                        .foregroundStyle(Theme.pink.opacity(0.8))
                }
            }

            Spacer()
        }
        .cuteCard()
        .opacity(isUnlocked ? 1 : 0.6)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isCurrent ? Theme.pink : .clear, lineWidth: 2)
        )
    }
}

#Preview {
    StoryView()
        .environmentObject(GameState())
}
