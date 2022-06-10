//
//  StoreProduct+Product.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation
import RevenueCat

extension Product {
    init(rc: StoreProduct) {
        if #available(iOS 12.2, *) {
            self.init(
                productType: ProductType(rc: rc.productType),
                productIdentifier: rc.productIdentifier,
                localizedDescription: rc.localizedDescription,
                localizedTitle: rc.localizedTitle,
                currencyCode: rc.currencyCode,
                price: rc.price,
                subscriptionPeriod: rc._subscriptionPeriod,
                introductoryDiscount: rc.introductoryDiscount,
                discounts: rc.discounts as [ProductDiscount],
                originalEntity: rc
            )
        } else if #available(iOS 11.2, *) {
            self.init(
                productType: ProductType(rc: rc.productType),
                productIdentifier: rc.productIdentifier,
                localizedDescription: rc.localizedDescription,
                localizedTitle: rc.localizedTitle,
                currencyCode: rc.currencyCode,
                price: rc.price,
                subscriptionPeriod: rc._subscriptionPeriod,
                introductoryDiscount: rc.introductoryDiscount,
                originalEntity: rc
            )
        } else {
            self.init(
                productType: ProductType(rc: rc.productType),
                productIdentifier: rc.productIdentifier,
                localizedDescription: rc.localizedDescription,
                localizedTitle: rc.localizedTitle,
                currencyCode: rc.currencyCode,
                price: rc.price,
                originalEntity: rc
            )
        }
    }
    
    var storeProduct: StoreProduct? {
        originalEntity as? StoreProduct
    }
}

@available(iOS 11.2, *)
private extension StoreProduct {
    var _subscriptionPeriod: SubscriptionPeriod? {
        subscriptionPeriod.map {
            SubscriptionPeriod(
                value: $0.value,
                unit: SubscriptionPeriod.Unit(rc: $0.unit)
            )
        }
    }
}

private extension ProductType {
    init(rc: StoreProduct.ProductType) {
        switch rc {
        case .autoRenewableSubscription:
            self = .autoRenewableSubscription
            
        case .consumable:
            self = .consumable
            
        case .nonConsumable:
            self = .nonConsumable
            
        case .nonRenewableSubscription:
            self = .nonRenewableSubscription
        }
    }
}

private extension SubscriptionPeriod.Unit {
    init(rc: RevenueCat.SubscriptionPeriod.Unit) {
        switch rc {
        case .month:
            self = .month
            
        case .year:
            self = .year
            
        case .week:
            self = .week
            
        case .day:
            self = .day
        }
    }
}