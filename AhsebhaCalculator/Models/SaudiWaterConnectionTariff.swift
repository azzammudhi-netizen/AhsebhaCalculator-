import Foundation

enum SaudiWaterConnectionSector: String, CaseIterable, Identifiable {
    case residential = "سكني"
    case nonResidential = "غير سكني"
    case government = "حكومي"

    var id: Self { self }

    var baseAreaM2: Double { 675 }
    
    var maximumCalculatedAreaM2: Double {
        switch self {
        case .residential:
            return 3_000
        case .nonResidential:
            return 2_500
        case .government:
            return 2_000
        }
    }

    var baseWaterFee: Double {
        switch self {
        case .residential:
            return 3_000
        case .nonResidential, .government:
            return 15_000
        }
    }

    var baseSewerFee: Double {
        switch self {
        case .residential:
            return 5_000
        case .nonResidential, .government:
            return 20_000
        }
    }

    var additionalWaterRatePerM2: Double {
        switch self {
        case .residential:
            return 10
        case .nonResidential:
            return 15
        case .government:
            return 20
        }
    }

    var additionalSewerRatePerM2: Double {
        switch self {
        case .residential:
            return 15
        case .nonResidential:
            return 20
        case .government:
            return 30
        }
    }
}

enum SaudiWaterConnectionService: String, CaseIterable, Identifiable {
    case water = "مياه فقط"
    case sewer = "صرف صحي فقط"
    case both = "مياه وصرف صحي"

    var id: Self { self }

    var includesWater: Bool {
        self == .water || self == .both
    }

    var includesSewer: Bool {
        self == .sewer || self == .both
    }
}

struct SaudiWaterConnectionTariff {
    static let vatRate = 0.15
    static let additionalResidentialUnitWaterFee = 1_000.0
    static let additionalResidentialUnitSewerFee = 1_000.0
}
