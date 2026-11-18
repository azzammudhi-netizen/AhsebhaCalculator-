import Foundation

enum SaudiWaterSector2027: String, CaseIterable, Identifiable {
    case residential = "سكني"
    case nonResidential = "غير سكني"
    case government = "حكومي"

    var id: Self { self }
}

enum SaudiWaterMeterCategory2027: Int, CaseIterable, Identifiable {
    case upTo20Millimeters = 0
    case from21To40Millimeters = 1
    case from41To65Millimeters = 2
    case from66To100Millimeters = 3
    case over100Millimeters = 4

    var id: Self { self }

    var label: String {
        switch self {
        case .upTo20Millimeters:
            return "0 إلى 20 ملم"
        case .from21To40Millimeters:
            return "21 إلى 40 ملم"
        case .from41To65Millimeters:
            return "41 إلى 65 ملم"
        case .from66To100Millimeters:
            return "66 إلى 100 ملم"
        case .over100Millimeters:
            return "أكثر من 100 ملم"
        }
    }
}

struct SaudiWaterTariff2027 {
    static let effectiveDate = "2027-01-01"
    static let vatRate = 0.15
    static let residentialTierSizeM3PerUnit = 15.0

    static let residentialWaterRates = [1.0, 2.0, 4.0, 6.0]
    static let residentialFixedWaterFees = [20.0, 40.0, 60.0, 80.0, 100.0]
    static let residentialFixedSewerFees = [10.0, 20.0, 30.0, 40.0, 50.0]

    static let nonResidentialWaterRate = 8.0
    static let nonResidentialFixedWaterFees = [40.0, 60.0, 80.0, 100.0, 150.0]
    static let nonResidentialFixedSewerFees = [20.0, 30.0, 40.0, 50.0, 75.0]

    static let governmentWaterRate = 10.0
    static let governmentFixedWaterFee = 1_000.0
    static let governmentFixedSewerFee = 500.0

    static let additionalResidentialUnitWaterFee = 20.0
    static let additionalResidentialUnitSewerFee = 10.0

    static func fixedWaterFee(
        for sector: SaudiWaterSector2027,
        meterCategory: SaudiWaterMeterCategory2027
    ) -> Double {
        switch sector {
        case .residential:
            return residentialFixedWaterFees[meterCategory.rawValue]
        case .nonResidential:
            return nonResidentialFixedWaterFees[meterCategory.rawValue]
        case .government:
            return governmentFixedWaterFee
        }
    }

    static func fixedSewerFee(
        for sector: SaudiWaterSector2027,
        meterCategory: SaudiWaterMeterCategory2027
    ) -> Double {
        switch sector {
        case .residential:
            return residentialFixedSewerFees[meterCategory.rawValue]
        case .nonResidential:
            return nonResidentialFixedSewerFees[meterCategory.rawValue]
        case .government:
            return governmentFixedSewerFee
        }
    }
}
