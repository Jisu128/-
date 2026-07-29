import Foundation
import SwiftUI

/// 게임 전체 상태. 운동 기록 → 골드 획득 → 빚 상환 → 자산 축적을 관리해요.
@MainActor
final class GameState: ObservableObject {

    // MARK: - 저장되는 데이터

    struct SaveData: Codable {
        var debt: Int
        var savings: Int
        var records: [WorkoutRecord]
        var startedAt: Date
    }

    @Published private(set) var debt: Int
    @Published private(set) var savings: Int
    @Published private(set) var records: [WorkoutRecord]
    private(set) var startedAt: Date

    /// 방금 스테이지가 올랐을 때 축하 화면을 띄우기 위한 값
    @Published var celebrationStage: Stage?
    /// 방금 획득한 골드 (홈 화면 연출용)
    @Published var lastEarnedGold: Int?

    private static let saveKey = "ExercisePrincess.SaveData.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey),
           let saved = try? JSONDecoder().decode(SaveData.self, from: data) {
            self.debt = saved.debt
            self.savings = saved.savings
            self.records = saved.records
            self.startedAt = saved.startedAt
        } else {
            self.debt = Stage.startingDebt
            self.savings = 0
            self.records = []
            self.startedAt = .now
        }
    }

    // MARK: - 계산 값

    /// 순자산 = 자산 - 빚
    var netWorth: Int { savings - debt }

    var stage: Stage { Stage.current(netWorth: netWorth) }

    var nextStage: Stage? { Stage.next(after: stage) }

    /// 다음 스테이지까지의 진행률 (0.0 ~ 1.0)
    var progressToNextStage: Double {
        guard let next = nextStage else { return 1.0 }
        let from = stage.requiredNetWorth == Int.min ? -Stage.startingDebt : stage.requiredNetWorth
        let span = Double(next.requiredNetWorth - from)
        guard span > 0 else { return 1.0 }
        return min(max(Double(netWorth - from) / span, 0), 1)
    }

    /// 오늘 운동했는지
    var didWorkoutToday: Bool {
        records.contains { Calendar.current.isDateInToday($0.date) }
    }

    /// 연속 출석일. 오늘 운동했다면 오늘 포함, 안 했다면 어제까지의 연속.
    var streak: Int {
        let cal = Calendar.current
        let daysWithWorkout = Set(records.map { cal.startOfDay(for: $0.date) })
        guard !daysWithWorkout.isEmpty else { return 0 }

        var day = cal.startOfDay(for: .now)
        if !daysWithWorkout.contains(day) {
            // 오늘 아직 안 했으면 어제부터 센다
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var count = 0
        while daysWithWorkout.contains(day) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return count
    }

    var totalWorkouts: Int { records.count }

    var totalMinutes: Int { records.reduce(0) { $0 + $1.minutes } }

    // MARK: - 액션

    /// 운동을 기록하고 골드를 받아요. 획득 골드를 반환.
    @discardableResult
    func logWorkout(type: ExerciseType, minutes: Int, memo: String = "") -> Int {
        let stageBefore = stage
        let isFirstToday = !didWorkoutToday
        let gold = GoldRule.gold(minutes: minutes, isFirstToday: isFirstToday, streak: streak + (isFirstToday ? 1 : 0))

        let record = WorkoutRecord(type: type, minutes: minutes, goldEarned: gold, memo: memo)
        records.insert(record, at: 0)
        applyGold(gold)
        lastEarnedGold = gold

        let stageAfter = stage
        if stageAfter.id > stageBefore.id {
            celebrationStage = stageAfter
        }
        save()
        return gold
    }

    /// 골드는 빚부터 갚고, 남으면 자산으로.
    private func applyGold(_ gold: Int) {
        var remaining = gold
        if debt > 0 {
            let repay = min(debt, remaining)
            debt -= repay
            remaining -= repay
        }
        savings += remaining
    }

    func deleteRecord(_ record: WorkoutRecord) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        let gold = records[index].goldEarned
        records.remove(at: index)
        // 골드 회수: 자산에서 먼저 빼고, 모자라면 빚으로 되돌린다
        let fromSavings = min(savings, gold)
        savings -= fromSavings
        debt += gold - fromSavings
        save()
    }

    /// 처음부터 다시 시작 (설정 화면용)
    func resetAll() {
        debt = Stage.startingDebt
        savings = 0
        records = []
        startedAt = .now
        celebrationStage = nil
        lastEarnedGold = nil
        save()
    }

    // MARK: - 저장

    private func save() {
        let data = SaveData(debt: debt, savings: savings, records: records, startedAt: startedAt)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
}

// MARK: - 숫자 포맷 헬퍼

extension Int {
    /// 12,345 형태의 골드 표기
    var goldString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: self)) ?? "\(self)") + "G"
    }
}
