import Foundation

enum SaudiWaterBill2027CalculationError: Error, Equatable {
    case invalidConsumption
    case invalidResidentialUnits
    case calculationOverflow
}

struct SaudiWaterBill2027TierResult: Equatable {
    let tierNumber: Int
    let quantityM3: Double
    let waterRate: Double
    let waterCost: Double
    let sewerCost: Double
}

struct SaudiWaterBill2027CalculationResult: Equatable {
    let tiers: [SaudiWaterBill2027TierResult]
    let waterConsumptionCost: Double
    let sewerConsumptionCost: Double
    let waterFixedFee: Double
    let sewerFixedFee: Double
    let additionalUnitsWaterFee: Double
    let additionalUnitsSewerFee: Double
    let beforeVat: Double
    let vatAmount: Double
    let total: Double
}

struct SaudiWaterBill2027Calculator {
    static func calculate(
        sector: SaudiWaterSector2027,
        consumptionM3: Double,
        meterCategory: SaudiWaterMeterCategory2027,
        residentialUnits: Int,
        hasSewer: Bool,
        includeVat: Bool
    ) throws -> SaudiWaterBill2027CalculationResult {
        guard consumptionM3.isFinite, consumptionM3 >= 0 else {
            throw SaudiWaterBill2027CalculationError.invalidConsumption
        }

        guard residentialUnits >= 1 else {
            throw SaudiWaterBill2027CalculationError.invalidResidentialUnits
        }

        let waterFixedFee = SaudiWaterTariff2027.fixedWaterFee(
            for: sector,
            meterCategory: meterCategory
        )
        let sewerFixedFee = hasSewer
            ? SaudiWaterTariff2027.fixedSewerFee(for: sector, meterCategory: meterCategory)
            : 0

        let tiers: [SaudiWaterBill2027TierResult]
        let additionalUnits = Double(residentialUnits - 1)
        let additionalUnitsWaterFee: Double
        let additionalUnitsSewerFee: Double

        switch sector {
        case .residential:
            let tierSize = SaudiWaterTariff2027.residentialTierSizeM3PerUnit * Double(residentialUnits)
            let tierQuantities = residentialTierQuantities(
                consumptionM3: consumptionM3,
                tierSize: tierSize
            )

            tiers = tierQuantities.enumerated().map { index, quantity in
                let waterRate = SaudiWaterTariff2027.residentialWaterRates[index]
                let waterCost = quantity * waterRate
                let sewerCost = hasSewer ? waterCost * 0.5 : 0

                return SaudiWaterBill2027TierResult(
                    tierNumber: index + 1,
                    quantityM3: quantity,
                    waterRate: waterRate,
                    waterCost: waterCost,
                    sewerCost: sewerCost
                )
            }

            additionalUnitsWaterFee = additionalUnits * SaudiWaterTariff2027.additionalResidentialUnitWaterFee
            additionalUnitsSewerFee = hasSewer
                ? additionalUnits * SaudiWaterTariff2027.additionalResidentialUnitSewerFee
                : 0

        case .nonResidential:
            let waterRate = SaudiWaterTariff2027.nonResidentialWaterRate
            let waterCost = consumptionM3 * waterRate
            let sewerCost = hasSewer ? waterCost * 0.5 : 0

            tiers = [
                SaudiWaterBill2027TierResult(
                    tierNumber: 1,
                    quantityM3: consumptionM3,
                    waterRate: waterRate,
                    waterCost: waterCost,
                    sewerCost: sewerCost
                )
            ]
            additionalUnitsWaterFee = 0
            additionalUnitsSewerFee = 0

        case .government:
            let waterRate = SaudiWaterTariff2027.governmentWaterRate
            let waterCost = consumptionM3 * waterRate
            let sewerCost = hasSewer ? waterCost * 0.5 : 0

            tiers = [
                SaudiWaterBill2027TierResult(
                    tierNumber: 1,
                    quantityM3: consumptionM3,
                    waterRate: waterRate,
                    waterCost: waterCost,
                    sewerCost: sewerCost
                )
            ]
            additionalUnitsWaterFee = 0
            additionalUnitsSewerFee = 0
        }

        let waterConsumptionCost = tiers.reduce(0) { $0 + $1.waterCost }
        let sewerConsumptionCost = tiers.reduce(0) { $0 + $1.sewerCost }

        let unroundedBeforeVat =
            waterConsumptionCost +
            sewerConsumptionCost +
            waterFixedFee +
            sewerFixedFee +
            additionalUnitsWaterFee +
            additionalUnitsSewerFee

        guard unroundedBeforeVat.isFinite else {
            throw SaudiWaterBill2027CalculationError.calculationOverflow
        }

        let beforeVat = roundMoney(unroundedBeforeVat)
        let unroundedVatAmount = includeVat ? beforeVat * SaudiWaterTariff2027.vatRate : 0

        guard unroundedVatAmount.isFinite else {
            throw SaudiWaterBill2027CalculationError.calculationOverflow
        }

        let vatAmount = includeVat ? roundMoney(unroundedVatAmount) : 0
        let unroundedTotal = beforeVat + vatAmount

        guard unroundedTotal.isFinite else {
            throw SaudiWaterBill2027CalculationError.calculationOverflow
        }

        return SaudiWaterBill2027CalculationResult(
            tiers: tiers,
            waterConsumptionCost: waterConsumptionCost,
            sewerConsumptionCost: sewerConsumptionCost,
            waterFixedFee: waterFixedFee,
            sewerFixedFee: sewerFixedFee,
            additionalUnitsWaterFee: additionalUnitsWaterFee,
            additionalUnitsSewerFee: additionalUnitsSewerFee,
            beforeVat: beforeVat,
            vatAmount: vatAmount,
            total: roundMoney(unroundedTotal)
        )
    }

    private static func residentialTierQuantities(
        consumptionM3: Double,
        tierSize: Double
    ) -> [Double] {
        var remaining = consumptionM3

        return (0..<SaudiWaterTariff2027.residentialWaterRates.count).map { index in
            let quantity: Double

            if index == SaudiWaterTariff2027.residentialWaterRates.count - 1 {
                quantity = remaining
            } else {
                quantity = min(remaining, tierSize)
            }

            remaining = max(remaining - quantity, 0)
            return quantity
        }
    }

    private static func roundMoney(_ value: Double) -> Double {
        let tolerance = Double.ulpOfOne * max(1, abs(value))
        return ((value + tolerance) * 100).rounded(.toNearestOrAwayFromZero) / 100
    }
}
