import Foundation

enum ElectricityTariff2027CalculationError: Error, Equatable {
    case invalidConsumption
    case invalidBillingDays
}

struct ElectricityTariff2027CalculationResult: Equatable {
    let firstTierKwh: Double
    let secondTierKwh: Double
    let firstTierCost: Double
    let secondTierCost: Double
    let consumptionCost: Double
    let monthlyFixedTariff: Double
    let fixedTariff: Double
    let beforeVat: Double
    let vatAmount: Double
    let total: Double
}

struct ElectricityTariff2027Calculator {
    static func calculate(
        sector: ElectricitySector2027,
        consumptionKwh: Double,
        breakerCategory: ElectricityBreakerCategory2027,
        billingDays: Int,
        includeVat: Bool
    ) throws -> ElectricityTariff2027CalculationResult {
        guard consumptionKwh.isFinite, consumptionKwh >= 0 else {
            throw ElectricityTariff2027CalculationError.invalidConsumption
        }

        guard (1...365).contains(billingDays) else {
            throw ElectricityTariff2027CalculationError.invalidBillingDays
        }

        let tariff = ElectricityTariff2027.tariff(for: sector)
        let firstTierKwh = min(consumptionKwh, ElectricityTariff2027.firstTierLimitKwh)
        let secondTierKwh = max(consumptionKwh - ElectricityTariff2027.firstTierLimitKwh, 0)

        let firstTierCost = firstTierKwh * tariff.firstTierRate
        let secondTierCost = secondTierKwh * tariff.secondTierRate
        let consumptionCost = firstTierCost + secondTierCost

        let monthlyFixedTariff = tariff.fixedCharge(for: breakerCategory)
        let fixedTariff = monthlyFixedTariff * Double(billingDays) / 30

        let beforeVat = consumptionCost + fixedTariff
        let vatAmount = includeVat ? beforeVat * ElectricityTariff2027.vatRate : 0
        let total = beforeVat + vatAmount

        return ElectricityTariff2027CalculationResult(
            firstTierKwh: firstTierKwh,
            secondTierKwh: secondTierKwh,
            firstTierCost: firstTierCost,
            secondTierCost: secondTierCost,
            consumptionCost: consumptionCost,
            monthlyFixedTariff: monthlyFixedTariff,
            fixedTariff: fixedTariff,
            beforeVat: beforeVat,
            vatAmount: vatAmount,
            total: total
        )
    }
}
