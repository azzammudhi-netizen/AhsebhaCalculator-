import SwiftUI

struct ToolCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let tool: ToolItem
    var isFavorite: Bool = false
    var onToggleFavorite: (() -> Void)? = nil
    var onOpen: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 14) {
            favoriteButton
            
            NavigationLink {
                destinationView
            } label: {
                HStack(spacing: 16) {
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(tool.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text(tool.subtitle)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(tool.color.opacity(0.18))
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: tool.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(tool.color)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onOpen?()
                }
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
                .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
        )
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private var favoriteButton: some View {
        Button {
            onToggleFavorite?()
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isFavorite ? tool.color : tool.color.opacity(0.65))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(favoriteBackground)
                )
                .overlay(
                    Circle()
                        .stroke(favoriteBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .frame(width: 48, height: 72, alignment: .center)
    }
    
    private var cardBackground: Color {
        colorScheme == .light ? .white : AppTheme.secondaryBackground
    }
    
    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : Color.clear
    }
    
    private var cardShadowRadius: CGFloat {
        colorScheme == .light ? 8 : 0
    }
    
    private var cardShadowY: CGFloat {
        colorScheme == .light ? 4 : 0
    }
    
    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : tool.color.opacity(0.18)
    }
    
    private var favoriteBackground: Color {
        tool.color.opacity(colorScheme == .light ? 0.12 : 0.18)
    }
    
    private var favoriteBorder: Color {
        tool.color.opacity(colorScheme == .light ? 0.20 : 0.28)
    }
    
    
    @ViewBuilder
    private var destinationView: some View {
        if tool.title == "حاسبة المعدل التراكمي" {
            GPACalculatorView()
        } else if tool.title == "حاسبة النسبة الموزونة" {
            WeightedPercentageView()
        } else if tool.title == "حاسبة النسبة المئوية" {
            PercentageCalculatorView()
        } else if tool.title == "حاسبة الخصم" {
            DiscountCalculatorView()
        } else if tool.title == "حاسبة الضريبة" {
            VATCalculatorView()
        } else if tool.title == "حاسبة التمويل الشخصي" {
            PersonalLoanCalculatorView()
        } else if tool.title == "حاسبة التمويل العقاري" {
            MortgageCalculatorView()
        } else if tool.title == "حاسبة نهاية الخدمة" {
            EndOfServiceCalculatorView()
        } else if tool.title == "حاسبة التقاعد المدني" {
            CivilRetirementCalculatorView()
        } else if tool.title == "حاسبة التقاعد العسكري" {
            MilitaryRetirementCalculatorView()
        } else if tool.title == "حاسبة العمر" {
            AgeCalculatorView()
        } else if tool.title == "تحويل أسماء الأشهر" {
            MonthNamesConverterView()
        } else if tool.title == "تحويل التاريخ" {
            DateConverterView()
        } else if tool.title == "حاسبة الفرق بين تاريخين" {
            DateDifferenceCalculatorView()
        } else {
            ToolComingSoonView(tool: tool)
        }
    }
}

struct ToolComingSoonView: View {
    let tool: ToolItem
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 18) {
                Image(systemName: tool.icon)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundColor(tool.color)
                
                Text(tool.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                
                Text("سيتم إضافة هذه الحاسبة قريبًا.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(24)
        }
    }
}

#Preview {
    NavigationStack {
        ToolCardView(
            tool: ToolItem(
                title: "حاسبة التقاعد العسكري",
                subtitle: "قدّر المعاش التقاعدي للعسكري",
                icon: "shield.lefthalf.filled",
                color: .red
            ),
            isFavorite: true
        )
        .padding()
        .background(AppTheme.background)
    }
}
