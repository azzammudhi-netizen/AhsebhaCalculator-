import Foundation

enum ElectricitySector2027: String, CaseIterable, Identifiable {
    case residential = "القطاع السكني"
    case commercialHealthcareEducation = "القطاع التجاري والصحي والتعليمي الأهلي"
    case industrial = "القطاع الصناعي"
    case agriculture = "القطاع الزراعي"
    case charitableOrganizations = "الجمعيات الخيرية"
    case government = "القطاع الحكومي"

    var id: Self { self }

    var firstTierRate: Double {
        switch self {
        case .residential:
            return 0.21
        case .commercialHealthcareEducation:
            return 0.25
        case .industrial:
            return 0.23
        case .agriculture:
            return 0.19
        case .charitableOrganizations:
            return 0.17
        case .government:
            return 0.35
        }
    }

    var secondTierRate: Double {
        switch self {
        case .residential:
            return 0.33
        case .commercialHealthcareEducation:
            return 0.35
        case .industrial:
            return 0.23
        case .agriculture:
            return 0.23
        case .charitableOrganizations:
            return 0.21
        case .government:
            return 0.35
        }
    }

    var fixedChargesByBreakerCategory: [ElectricityBreakerCategory2027: Double] {
        switch self {
        case .residential:
            return [
                .upTo100Amps: 70,
                .from100ToUnder200Amps: 80,
                .from200ToUnder300Amps: 90,
                .atLeast300Amps: 100
            ]
        case .commercialHealthcareEducation, .industrial, .government:
            return [
                .upTo100Amps: 350,
                .from100ToUnder200Amps: 500,
                .from200ToUnder300Amps: 700,
                .atLeast300Amps: 900
            ]
        case .agriculture, .charitableOrganizations:
            return [
                .upTo100Amps: 140,
                .from100ToUnder200Amps: 160,
                .from200ToUnder300Amps: 180,
                .atLeast300Amps: 200
            ]
        }
    }

    func fixedCharge(for breakerCategory: ElectricityBreakerCategory2027) -> Double {
        fixedChargesByBreakerCategory[breakerCategory] ?? 0
    }
}

enum ElectricityBreakerCategory2027: Int, CaseIterable, Identifiable {
    case upTo100Amps = 0
    case from100ToUnder200Amps = 1
    case from200ToUnder300Amps = 2
    case atLeast300Amps = 3

    var id: Self { self }

    var label: String {
        switch self {
        case .upTo100Amps:
            return "20 إلى أقل من 100 أمبير"
        case .from100ToUnder200Amps:
            return "100 إلى أقل من 200 أمبير"
        case .from200ToUnder300Amps:
            return "200 إلى أقل من 300 أمبير"
        case .atLeast300Amps:
            return "300 أمبير فأكثر"
        }
    }
}

struct ElectricityTariff2027 {
    static let firstTierLimitKwh = 6_000.0
    static let vatRate = 0.15

    let sector: ElectricitySector2027
    let firstTierRate: Double
    let secondTierRate: Double
    let fixedChargesByBreakerCategory: [ElectricityBreakerCategory2027: Double]

    init(sector: ElectricitySector2027) {
        self.sector = sector
        self.firstTierRate = sector.firstTierRate
        self.secondTierRate = sector.secondTierRate
        self.fixedChargesByBreakerCategory = sector.fixedChargesByBreakerCategory
    }

    func fixedCharge(for breakerCategory: ElectricityBreakerCategory2027) -> Double {
        fixedChargesByBreakerCategory[breakerCategory] ?? 0
    }

    static func tariff(for sector: ElectricitySector2027) -> Self {
        Self(sector: sector)
    }
}
