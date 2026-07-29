import SwiftUI

/// 운동 기록 시트: 종류/시간을 고르면 골드를 받아요.
struct WorkoutLogView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: ExerciseType = .stretching
    @State private var minutes: Int = 20
    @State private var memo: String = ""

    private let minuteOptions = [5, 10, 15, 20, 30, 40, 50, 60, 90, 120]

    private var expectedGold: Int {
        GoldRule.gold(minutes: minutes,
                      isFirstToday: !game.didWorkoutToday,
                      streak: game.streak + (game.didWorkoutToday ? 0 : 1))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        typePicker
                        minutePicker
                        memoField
                        rewardPreview
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("오늘의 운동 🌸")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                        .tint(Theme.pink)
                }
            }
        }
    }

    // MARK: - 운동 종류

    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("어떤 운동을 했나요?")
                .font(.subheadline.bold())
                .foregroundStyle(Theme.textBrown)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                ForEach(ExerciseType.allCases) { type in
                    Button {
                        selectedType = type
                    } label: {
                        VStack(spacing: 4) {
                            Text(type.emoji).font(.title2)
                            Text(type.rawValue)
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedType == type ? Theme.pink.opacity(0.9) : .white.opacity(0.8))
                        )
                        .foregroundStyle(selectedType == type ? .white : Theme.textBrown)
                    }
                }
            }
        }
        .cuteCard()
    }

    // MARK: - 운동 시간

    private var minutePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("얼마나 했나요?")
                .font(.subheadline.bold())
                .foregroundStyle(Theme.textBrown)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(minuteOptions, id: \.self) { m in
                        Button {
                            minutes = m
                        } label: {
                            Text("\(m)분")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(minutes == m ? Theme.pink : .white.opacity(0.8))
                                )
                                .foregroundStyle(minutes == m ? .white : Theme.textBrown)
                        }
                    }
                }
            }
        }
        .cuteCard()
    }

    // MARK: - 메모

    private var memoField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("한 줄 일기 (선택)")
                .font(.subheadline.bold())
                .foregroundStyle(Theme.textBrown)
            TextField("오늘의 기분은 어땠나요?", text: $memo)
                .textFieldStyle(.plain)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.cream)
                )
        }
        .cuteCard()
    }

    // MARK: - 보상 미리보기

    private var rewardPreview: some View {
        VStack(spacing: 6) {
            Text("예상 보상")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("✨ \(expectedGold.goldString) ✨")
                .font(.title2.bold())
                .foregroundStyle(Theme.gold)
                .contentTransition(.numericText())
                .animation(.spring, value: expectedGold)

            if !game.didWorkoutToday {
                Text("오늘 첫 운동 보너스 + 연속 출석 보너스 포함이에요 🎁")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .cuteCard()
    }

    // MARK: - 저장

    private var saveButton: some View {
        Button {
            game.logWorkout(type: selectedType, minutes: minutes, memo: memo)
            dismiss()
        } label: {
            Text("운동 완료! 골드 받기 💰")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Theme.pink)
                        .shadow(color: Theme.pink.opacity(0.4), radius: 8, y: 4)
                )
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    WorkoutLogView()
        .environmentObject(GameState())
}
