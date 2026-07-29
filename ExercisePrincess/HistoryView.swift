import SwiftUI

/// 운동 일기: 지금까지의 기록과 통계
struct HistoryView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                if game.records.isEmpty {
                    emptyState
                } else {
                    List {
                        Section {
                            statsRow
                                .listRowBackground(Color.white.opacity(0.85))
                        }

                        Section("기록") {
                            ForEach(game.records) { record in
                                recordRow(record)
                                    .listRowBackground(Color.white.opacity(0.85))
                            }
                            .onDelete { indexSet in
                                let toDelete = indexSet.map { game.records[$0] }
                                toDelete.forEach { game.deleteRecord($0) }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("📖 운동 일기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🌷")
                .font(.system(size: 64))
            Text("아직 기록이 없어요")
                .font(.headline)
                .foregroundStyle(Theme.textBrown)
            Text("첫 운동을 기록하면 공주님의 이야기가 시작돼요!")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var statsRow: some View {
        HStack {
            statItem(emoji: "🏃‍♀️", title: "총 운동", value: "\(game.totalWorkouts)회")
            Divider()
            statItem(emoji: "⏰", title: "총 시간", value: "\(game.totalMinutes)분")
            Divider()
            statItem(emoji: "🔥", title: "연속", value: "\(game.streak)일")
        }
    }

    private func statItem(emoji: String, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.subheadline.bold()).foregroundStyle(Theme.textBrown)
        }
        .frame(maxWidth: .infinity)
    }

    private func recordRow(_ record: WorkoutRecord) -> some View {
        HStack(spacing: 12) {
            Text(record.type.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(record.type.rawValue) · \(record.minutes)분")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textBrown)
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if !record.memo.isEmpty {
                    Text("💭 \(record.memo)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Text("+\(record.goldEarned.goldString)")
                .font(.caption.bold())
                .foregroundStyle(Theme.gold)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    HistoryView()
        .environmentObject(GameState())
}
