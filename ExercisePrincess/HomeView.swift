import SwiftUI

/// 메인 화면: 공주님의 집, 빚/자산 현황, 오늘의 운동 버튼
struct HomeView: View {
    @EnvironmentObject private var game: GameState
    @State private var showWorkoutSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        houseCard
                        moneyCard
                        streakCard
                        workoutButton
                    }
                    .padding()
                }
            }
            .navigationTitle("🎀 공주핑트")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showWorkoutSheet) {
            WorkoutLogView()
                .presentationDetents([.large])
        }
    }

    // MARK: - 공주님의 집

    private var houseCard: some View {
        VStack(spacing: 10) {
            Text(game.stage.houseEmoji)
                .font(.system(size: 90))
                .padding(.top, 6)

            Text(game.stage.houseName)
                .font(.title3.bold())
                .foregroundStyle(Theme.textBrown)

            HStack(spacing: 6) {
                Text(game.stage.princessEmoji)
                Text(game.stage.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.pink)
            }

            Text(game.stage.story)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if let next = game.nextStage {
                VStack(spacing: 6) {
                    ProgressView(value: game.progressToNextStage)
                        .tint(Theme.pink)
                        .scaleEffect(y: 1.6)

                    HStack {
                        Text("다음 집: \(next.houseEmoji) \(next.houseName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(game.progressToNextStage * 100))%")
                            .font(.caption.bold())
                            .foregroundStyle(Theme.pink)
                    }
                }
                .padding(.top, 8)
            } else {
                Text("최고 등급 달성! 여왕님 만세! 👑")
                    .font(.caption.bold())
                    .foregroundStyle(Theme.gold)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .cuteCard()
    }

    // MARK: - 빚 & 자산

    private var moneyCard: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("💸 남은 빚")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(game.debt.goldString)
                    .font(.headline)
                    .foregroundStyle(game.debt > 0 ? .red : .secondary)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 36)

            VStack(spacing: 4) {
                Text("💰 모은 자산")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(game.savings.goldString)
                    .font(.headline)
                    .foregroundStyle(Theme.gold)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .cuteCard()
        .animation(.spring, value: game.debt)
        .animation(.spring, value: game.savings)
    }

    // MARK: - 스트릭

    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("🔥 연속 \(game.streak)일째 운동 중")
                    .font(.subheadline.bold())
                    .foregroundStyle(Theme.textBrown)
                Text(game.didWorkoutToday
                     ? "오늘의 운동 완료! 정말 대단해요 💕"
                     : "오늘 아직 운동 전이에요. 공주님, 가볍게 시작해볼까요?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(game.didWorkoutToday ? "✅" : "🌸")
                .font(.largeTitle)
        }
        .cuteCard()
    }

    // MARK: - 운동하기 버튼

    private var workoutButton: some View {
        Button {
            showWorkoutSheet = true
        } label: {
            HStack {
                Text("💪")
                Text(game.didWorkoutToday ? "운동 더 하기" : "오늘의 운동 기록하기")
                    .font(.headline)
                Text("🎀")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Theme.pink)
                    .shadow(color: Theme.pink.opacity(0.4), radius: 8, y: 4)
            )
            .foregroundStyle(.white)
        }
        .padding(.top, 4)
    }
}

#Preview {
    HomeView()
        .environmentObject(GameState())
}
