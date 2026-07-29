import SwiftUI

/// 아기자기한 파스텔 핑크 테마 🎀
enum Theme {
    static let pink = Color(red: 1.0, green: 0.55, blue: 0.72)
    static let softPink = Color(red: 1.0, green: 0.85, blue: 0.91)
    static let cream = Color(red: 1.0, green: 0.97, blue: 0.93)
    static let lavender = Color(red: 0.87, green: 0.82, blue: 0.98)
    static let mint = Color(red: 0.78, green: 0.94, blue: 0.87)
    static let gold = Color(red: 0.98, green: 0.75, blue: 0.25)
    static let textBrown = Color(red: 0.45, green: 0.31, blue: 0.29)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [softPink, cream, lavender.opacity(0.6)],
            startPoint: .top, endPoint: .bottom
        )
    }
}

/// 둥글둥글 귀여운 카드 스타일
struct CuteCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.85))
                    .shadow(color: Theme.pink.opacity(0.18), radius: 10, y: 4)
            )
    }
}

extension View {
    func cuteCard() -> some View { modifier(CuteCard()) }
}
