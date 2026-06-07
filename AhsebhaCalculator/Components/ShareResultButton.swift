//
//  ShareResultButton.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-13.
//

import SwiftUI
import UIKit

struct ShareResultButton: View {
    let text: String
    let sharedImage: UIImage?

    @State private var showCopiedMessage = false

    init(text: String, sharedImage: UIImage? = nil) {
        self.text = text
        self.sharedImage = sharedImage
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            VStack(spacing: 10) {
                copyButton
                shareTextButton
                shareCardButton
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            )

            if showCopiedMessage {
                copiedMessage
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var copyButton: some View {
        Button {
            copyResult()
        } label: {
            actionLabel(
                icon: "doc.on.doc.fill",
                title: "نسخ النتيجة",
                backgroundColor: AppTheme.buttonOrange,
                foregroundColor: .white
            )
        }
        .buttonStyle(.plain)
    }

    private var shareTextButton: some View {
        ShareLink(item: text) {
            actionLabel(
                icon: "square.and.arrow.up.fill",
                title: "مشاركة نصية",
                backgroundColor: AppTheme.inputBackground,
                foregroundColor: AppTheme.primaryText
            )
        }
    }

    @ViewBuilder
    private var shareCardButton: some View {
        if let sharedImage {
            ShareLink(item: Image(uiImage: sharedImage), preview: SharePreview("بطاقة النتيجة", image: Image(uiImage: sharedImage))) {
                actionLabel(
                    icon: "photo.on.rectangle.angled",
                    title: "مشاركة كبطاقة",
                    backgroundColor: AppTheme.inputBackground,
                    foregroundColor: AppTheme.primaryText
                )
            }
        } else {
            actionLabel(
                icon: "photo.on.rectangle.angled",
                title: "مشاركة كبطاقة",
                backgroundColor: AppTheme.inputBackground.opacity(0.55),
                foregroundColor: AppTheme.secondaryText
            )
            .opacity(0.72)
        }
    }

    private var copiedMessage: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
            Text("تم نسخ النتيجة")
        }
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundColor(.green)
        .frame(maxWidth: .infinity, alignment: .center)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func actionLabel(
        icon: String,
        title: String,
        backgroundColor: Color,
        foregroundColor: Color
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))

            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(foregroundColor)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private func copyResult() {
        UIPasteboard.general.string = text

        withAnimation {
            showCopiedMessage = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedMessage = false
            }
        }
    }
}
