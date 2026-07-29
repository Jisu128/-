import Foundation

// MARK: - 운동 종류

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case stretching = "스트레칭"
    case walking = "산책 · 걷기"
    case homeTraining = "홈트레이닝"
    case yoga = "요가 · 필라테스"
    case strength = "근력 운동"
    case running = "달리기"
    case cycling = "자전거"
    case dance = "댄스"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .stretching: return "🙆‍♀️"
        case .walking: return "🚶‍♀️"
        case .homeTraining: return "🤸‍♀️"
        case .yoga: return "🧘‍♀️"
        case .strength: return "🏋️‍♀️"
        case .running: return "🏃‍♀️"
        case .cycling: return "🚴‍♀️"
        case .dance: return "💃"
        }
    }
}

// MARK: - 운동 기록

struct WorkoutRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let type: ExerciseType
    let minutes: Int
    let goldEarned: Int
    let memo: String

    init(date: Date = .now, type: ExerciseType, minutes: Int, goldEarned: Int, memo: String = "") {
        self.id = UUID()
        self.date = date
        self.type = type
        self.minutes = minutes
        self.goldEarned = goldEarned
        self.memo = memo
    }
}

// MARK: - 스테이지 (집 & 공주님의 신분)

struct Stage: Identifiable {
    let id: Int
    /// 이 스테이지가 되기 위해 필요한 순자산 (자산 - 빚)
    let requiredNetWorth: Int
    let houseEmoji: String
    let houseName: String
    let princessEmoji: String
    let title: String
    let story: String

    static let startingDebt = 1_000_000

    static let all: [Stage] = [
        Stage(id: 0, requiredNetWorth: Int.min,
              houseEmoji: "🏚️", houseName: "다 쓰러져가는 오두막",
              princessEmoji: "😢", title: "몰락한 공주",
              story: "왕국이 무너지고 빚더미에 앉은 공주님… 오늘부터 운동으로 재기를 노려요!"),
        Stage(id: 1, requiredNetWorth: -750_000,
              houseEmoji: "🛖", houseName: "비는 안 새는 오두막",
              princessEmoji: "🥺", title: "다시 일어서는 공주",
              story: "지붕을 고쳤어요! 아직 갈 길이 멀지만 시작이 반이에요."),
        Stage(id: 2, requiredNetWorth: -500_000,
              houseEmoji: "🏠", houseName: "아담한 시골집",
              princessEmoji: "🙂", title: "씩씩한 공주",
              story: "빚이 절반으로! 마을 사람들이 공주님의 성실함을 칭찬하기 시작했어요."),
        Stage(id: 3, requiredNetWorth: -250_000,
              houseEmoji: "🏡", houseName: "정원이 있는 집",
              princessEmoji: "😊", title: "소문난 부지런 공주",
              story: "작은 정원에 꽃이 피었어요. 빚 청산이 코앞이에요!"),
        Stage(id: 4, requiredNetWorth: 0,
              houseEmoji: "🏘️", houseName: "마을에서 제일 예쁜 집",
              princessEmoji: "😆", title: "빚 청산 공주",
              story: "드디어 빚을 모두 갚았어요!! 이제부터는 모으는 일만 남았어요."),
        Stage(id: 5, requiredNetWorth: 250_000,
              houseEmoji: "🏛️", houseName: "우아한 저택",
              princessEmoji: "🤗", title: "저택의 안주인",
              story: "저택을 샀어요! 운동으로 다져진 공주님, 기품이 흘러넘쳐요."),
        Stage(id: 6, requiredNetWorth: 500_000,
              houseEmoji: "🏰", houseName: "언덕 위의 성",
              princessEmoji: "😎", title: "성주가 된 공주",
              story: "성을 되찾았어요! 왕국 재건이 눈앞이에요."),
        Stage(id: 7, requiredNetWorth: 1_000_000,
              houseEmoji: "👑🏰", houseName: "찬란한 왕궁",
              princessEmoji: "👸", title: "왕국을 되찾은 여왕님",
              story: "운동으로 왕국을 되찾은 전설의 여왕님! 그래도 운동은 계속됩니다💪"),
    ]

    /// 현재 순자산에 맞는 스테이지
    static func current(netWorth: Int) -> Stage {
        all.last(where: { netWorth >= $0.requiredNetWorth }) ?? all[0]
    }

    /// 다음 스테이지 (마지막이면 nil)
    static func next(after stage: Stage) -> Stage? {
        all.first(where: { $0.id == stage.id + 1 })
    }
}

// MARK: - 골드 계산

enum GoldRule {
    /// 분당 골드
    static let perMinute = 1_000
    /// 하루 첫 운동 보너스
    static let dailyFirstBonus = 10_000
    /// 연속 출석 1일당 보너스
    static let streakBonusPerDay = 1_000
    /// 연속 출석 보너스 상한
    static let streakBonusCap = 30_000
    /// 1회 인정되는 최대 운동 시간(분)
    static let maxMinutesPerWorkout = 120

    static func gold(minutes: Int, isFirstToday: Bool, streak: Int) -> Int {
        let capped = min(minutes, maxMinutesPerWorkout)
        var total = capped * perMinute
        if isFirstToday {
            total += dailyFirstBonus
            total += min(streak * streakBonusPerDay, streakBonusCap)
        }
        return total
    }
}
