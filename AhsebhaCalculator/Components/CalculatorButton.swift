import SwiftUI

struct CalculatorButton: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                backgroundColor.opacity(1.0),
                                backgroundColor.opacity(0.88)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        Color.white.opacity(0.06),
                        lineWidth: 1
                    )

                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 22)

                    Spacer()
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )

                Text(title)
                    .font(
                        .system(
                            size: 28,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: Color.black.opacity(isPressed ? 0.18 : 0.32),
                radius: isPressed ? 4 : 12,
                x: 0,
                y: isPressed ? 2 : 8
            )
            .animation(
                .spring(response: 0.22, dampingFraction: 0.75),
                value: isPressed
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
