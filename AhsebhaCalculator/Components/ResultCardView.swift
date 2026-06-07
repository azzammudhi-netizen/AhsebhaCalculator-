import SwiftUI
import UIKit

struct ResultCardView: View {
    let calculatorTitle: String
    let rows: [ResultCardRow]

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            header
            resultRows
            footer
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(cardBackground)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var header: some View {
        VStack(alignment: .center, spacing: 10) {
            brandLogo(size: 56)
            
            Text(calculatorTitle)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var resultRows: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                ResultCardRowView(row: row, isCompact: rows.count > 6)

                if index < rows.count - 1 {
                    Divider()
                        .background(AppTheme.border)
                }
            }
        }
        .background(AppTheme.inputBackground.opacity(0.62))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var footer: some View {
        Text("احسبها | Ahsebha.com")
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundColor(AppTheme.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 2)
    }
    
    @ViewBuilder
    private func brandLogo(size: CGFloat) -> some View {
        if let logoImage = ahsebhaLogoImage {
            Image(uiImage: logoImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .stroke(AppTheme.buttonOrange.opacity(0.18), lineWidth: 1)
                )
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .fill(AppTheme.buttonOrange.opacity(0.14))
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                            .stroke(AppTheme.buttonOrange.opacity(0.22), lineWidth: 1)
                    )
                
                Text("احسبها")
                    .font(.system(size: size * 0.22, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
            }
            .frame(width: size, height: size)
        }
    }
    
    private var ahsebhaLogoImage: UIImage? {
        UIImage(named: "AhsebhaShareLogo")
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(AppTheme.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 18, x: 0, y: 10)
    }
}

struct ResultCardRow: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let valueColor: Color?

    init(title: String, value: String, valueColor: Color? = nil) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
}

private struct ResultCardRowView: View {
    let row: ResultCardRow
    let isCompact: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(row.value)
                .font(.system(size: isCompact ? 16 : 17, weight: .bold, design: .rounded))
                .foregroundColor(row.valueColor ?? AppTheme.primaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(row.title)
                .font(.system(size: isCompact ? 14 : 15, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isCompact ? 9 : 12)
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()

        ResultCardView(
            calculatorTitle: "حاسبة التمويل الشخصي",
            rows: [
                ResultCardRow(title: "القسط الشهري", value: "١٬٢٥٠ ر.س", valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "مبلغ القرض", value: "٥٠٬٠٠٠ ر.س"),
                ResultCardRow(title: "نسبة الأرباح", value: "٣٪"),
                ResultCardRow(title: "إجمالي السداد", value: "٥٧٬٥٠٠ ر.س"),
                ResultCardRow(title: "مدة السداد", value: "٦٠ شهر"),
                ResultCardRow(title: "مبلغ الأرباح", value: "٧٬٥٠٠ ر.س"),
                ResultCardRow(title: "تاريخ الحساب", value: "١٤٤٧/١٢/١١")
            ]
        )
        .padding(20)
    }
}
