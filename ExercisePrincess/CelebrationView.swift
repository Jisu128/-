import SwiftUI

/// 스테이지 업그레이드 축하 화면 🎉
struct CelebrationView: View {
    @Environment(\.dismiss) private var dismiss
    let stage: Stage

    @State private var bounce = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 18) {
                Text("🎉 이사 축하해요! 🎉")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.pink)

                Text(stage.houseEmoji)
                    .font(.system(size: 100))
                    .scaleEffect(bounce ? 1.08 : 0.95)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: bounce)

                Text(stage.houseName)
                    .font(.title3.bold())
                    .foregroundStyle(Theme.textBrown)

                Text("\(stage.princessEmoji) \(stage.title)")
                    .font(.headline)
                    .foregroundStyle(Theme.pink)

                Text(stage.story)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button {
                    dismiss()
                } label: {
                    Text("좋아요! 계속 달릴게요 💪")
                        .font(.headline)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Theme.pink))
                        .foregroundStyle(.white)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .onAppear { bounce = true }
    }
}

#Preview {
    CelebrationView(stage: Stage.all[4])
}
