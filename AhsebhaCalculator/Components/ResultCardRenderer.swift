import SwiftUI
import UIKit

@MainActor
struct ResultCardRenderer {
    static func render(
        title: String,
        rows: [ResultCardRow],
        note: String? = nil
    ) -> UIImage? {
        let content = ResultCardRenderContent(
            title: title,
            rows: rows,
            note: note
        )
        .frame(width: 390)

        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale

        return renderer.uiImage
    }
}

private struct ResultCardRenderContent: View {
    let title: String
    let rows: [ResultCardRow]
    let note: String?

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            ResultCardView(
                calculatorTitle: title,
                rows: rows
            )

            if let note, !note.isEmpty {
                Text(note)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 6)
            }
        }
        .padding(18)
        .background(AppTheme.background)
        .environment(\.layoutDirection, .rightToLeft)
    }
}
