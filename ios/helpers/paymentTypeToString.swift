//
//  paymentTypeToString.swift
//  expo-braintree
//
//  Created by Mikhail Chachkouski on 29/11/2024.
//

import Foundation
import PassKit

func paymentTypeToString(_ type: PKPaymentMethodType) -> String {
    switch (type) {
      case .credit: return "credit"
      case .debit: return "debit"
      case .eMoney: return "eMoney"
      case .prepaid: return "prepaid"
      case .store: return "store"
      case .unknown: return "unknown"
      default: return "unknown"
    }
  }
