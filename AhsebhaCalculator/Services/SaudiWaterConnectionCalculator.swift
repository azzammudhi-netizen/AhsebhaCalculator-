import Foundation

enum SaudiWaterConnectionCalculationError: Error, Equatable {
    case invalidBuildingArea
    case invalidResidentialUnits
    case calculationOverflow
}

struct SaudiWaterConnectionCalculatedResult: Equatable {
    let status = SaudiWaterConnectionCalculationStatus.calculated
    let waterFee: Double
    let sewerFee: Double
    let additionalWaterFee: Double
    let additionalSewerFee: Double
    let beforeVat: Double
    let vatAmount: Double
    let total: Double
    let requiresActualCost = false
    let message: String?
}

struct SaudiWaterConnectionQuoteResult: Equatable {
    let status = SaudiWaterConnectionCalculationStatus.requiresQuote
    let requiresActualCost = true
    let message: String
}

enum SaudiWaterConnectionCalculationStatus: Equatable {
    case calculated
    case requiresQuote
}

enum SaudiWaterConnectionCalculationResult: Equatable {
    case calculated(SaudiWaterConnectionCalculatedResult)
    case requiresQuote(SaudiWaterConnectionQuoteResult)

    var status: SaudiWaterConnectionCalculationStatus {
        switch self {
        case .calculated(let result):
            return result.status
        case .requiresQuote(let result):
            return result.status
        }
    }

    var requiresActualCost: Bool {
        switch self {
        case .calculated(let result):
            return result.requiresActualCost
        case .requiresQuote(let result):
            return result.requiresActualCost
        }
    }

    var message: String {
        switch self {
        case .calculated(let result):
            return result.message ?? ""
        case .requiresQuote(let result):
            return result.message
        }
    }
}

struct SaudiWaterConnectionCalculator {
    static let requiresQuoteMessage =
        "تتجاوز مساحة البناء الحد المحدد للتسعير المباشر. تُحدد الرسوم وفق تكاليف التنفيذ الفعلية والأحكام التنظيمية ذات العلاقة. يرجى مراجعة مقدم الخدمة للحصول على التكلفة."

    static func calculate(
        sector: SaudiWaterConnectionSector,
        service: SaudiWaterConnectionService,
        buildingAreaM2: Double,
        residentialUnits: Int,
        includeVat: Bool
    ) throws -> SaudiWaterConnectionCalculationResult {
        guard buildingAreaM2.isFinite, buildingAreaM2 > 0 else {
            throw SaudiWaterConnectionCalculationError.invalidBuildingArea
        }

        guard residentialUnits >= 1 else {
            throw SaudiWaterConnectionCalculationError.invalidResidentialUnits
        }

        if buildingAreaM2 > sector.maximumCalculatedAreaM2 {
            return .requiresQuote(
                SaudiWaterConnectionQuoteResult(message: requiresQuoteMessage)
            )
        }

        let additionalArea = max(0, buildingAreaM2 - sector.baseAreaM2)
        let waterFee = service.includesWater
            ? sector.baseWaterFee + additionalArea * sector.additionalWaterRatePerM2
            : 0
        let sewerFee = service.includesSewer
            ? sector.baseSewerFee + additionalArea * sector.additionalSewerRatePerM2
            : 0

        let additionalUnits = Double(residentialUnits - 1)
        let additionalWaterFee: Double
        let additionalSewerFee: Double

        if sector == .residential {
            additionalWaterFee = service.includesWater
                ? additionalUnits * SaudiWaterConnectionTariff.additionalResidentialUnitWaterFee
                : 0
            additionalSewerFee = service.includesSewer
                ? additionalUnits * SaudiWaterConnectionTariff.additionalResidentialUnitSewerFee
                : 0
        } else {
            additionalWaterFee = 0
            additionalSewerFee = 0
        }

        let unroundedBeforeVat =
            waterFee +
            sewerFee +
            additionalWaterFee +
            additionalSewerFee

        guard unroundedBeforeVat.isFinite else {
            throw SaudiWaterConnectionCalculationError.calculationOverflow
        }

        let beforeVat = roundMoney(unroundedBeforeVat)
        let unroundedVatAmount = includeVat
            ? beforeVat * SaudiWaterConnectionTariff.vatRate
            : 0

        guard unroundedVatAmount.isFinite else {
            throw SaudiWaterConnectionCalculationError.calculationOverflow
        }

        let vatAmount = includeVat ? roundMoney(unroundedVatAmount) : 0
        let unroundedTotal = beforeVat + vatAmount

        guard unroundedTotal.isFinite else {
            throw SaudiWaterConnectionCalculationError.calculationOverflow
        }

        return .calculated(
            SaudiWaterConnectionCalculatedResult(
                waterFee: waterFee,
                sewerFee: sewerFee,
                additionalWaterFee: additionalWaterFee,
                additionalSewerFee: additionalSewerFee,
                beforeVat: beforeVat,
                vatAmount: vatAmount,
                total: roundMoney(unroundedTotal),
                message: nil
            )
        )
    }

    private static func roundMoney(_ value: Double) -> Double {
        let tolerance = Double.ulpOfOne * max(1, abs(value))
        return ((value + tolerance) * 100).rounded(.toNearestOrAwayFromZero) / 100
    }
}
