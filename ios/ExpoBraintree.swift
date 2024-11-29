//
//  BTPayPalVaultRequest.swift
//  expo-braintree
//
//  Created by Maciej Sasinowski on 28/04/2024.
//

import Braintree
import BraintreeApplePay
import PassKit
import Foundation
import React

enum EXCEPTION_TYPES: String {
  case SWIFT_EXCEPTION = "ReactNativeExpoBraintree:`SwiftException"
  case USER_CANCEL_EXCEPTION = "ReactNativeExpoBraintree:`UserCancelException"
  case TOKENIZE_EXCEPTION = "ReactNativeExpoBraintree:`TokenizeException"
  case PAYPAL_DISABLED_IN_CONFIGURATION =
    "ReactNativeExpoBraintree:`Paypal disabled in configuration"
  case MERCHANT_ID_EXCEPTION = "ReactNativeExpoBraintree:`You must provide merchantId`"
  case MERCHANT_NAME_EXCEPTION = "ReactNativeExpoBraintree:`You must provide merchantName`"
  case APPLE_PAY_SHEET_EXCEPTION = "ReactNativeExpoBraintree:`Cannot present ApplePay sheet`"
  case APPLE_PAY_PAYMENT_EXCEPTION = "ReactNativeExpoBraintree:`You cannot make ApplePay payments`"
  case APPLE_PAY_TOKEN_EXCEPTION = "ReactNativeExpoBraintree:`Cannot tokenize ApplePay payment`"
  case APPLE_PAY_REQUEST_EXCEPTION = "ReactNativeExpoBraintree:`Cannot create a payment request`"
}

enum ERROR_TYPES: String {
  case API_CLIENT_INITIALIZATION_ERROR = "API_CLIENT_INITIALIZATION_ERROR"
  case TOKENIZE_VAULT_PAYMENT_ERROR = "TOKENIZE_VAULT_PAYMENT_ERROR"
  case USER_CANCEL_TRANSACTION_ERROR = "USER_CANCEL_TRANSACTION_ERROR"
  case PAYPAL_DISABLED_IN_CONFIGURATION_ERROR = "PAYPAL_DISABLED_IN_CONFIGURATION_ERROR"
  case DATA_COLLECTOR_ERROR = "DATA_COLLECTOR_ERROR"
  case CARD_TOKENIZATION_ERROR = "CARD_TOKENIZATION_ERROR"
  case MERCHANT_ID_ERROR = "MERCHANT_ID_ERROR"
  case MERCHANT_NAME_ERROR = "MERCHANT_NAME_ERROR"
  case APPLE_PAY_SHEET_ERROR = "APPLE_PAY_SHEET_ERROR"
  case APPLE_PAY_PAYMENT_ERROR = "APPLE_PAY_PAYMENT_ERROR"
  case APPLE_PAY_TOKEN_ERROR = "APPLE_PAY_TOKEN_ERROR"
  case APPLE_PAY_REQUEST_ERROR = "APPLE_PAY_REQUEST_ERROR"
}

@objc(ExpoBraintree)
class ExpoBraintree: NSObject, PKPaymentAuthorizationControllerDelegate {

  let supportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .discover,
    .masterCard,
    .visa,
    .interac,
    .JCB
  ]
  var resolve: RCTPromiseResolveBlock? = nil
  var reject: RCTPromiseRejectBlock? = nil
  var btClient: BTAPIClient? = nil
  var paymentController: PKPaymentAuthorizationController? = nil

  @objc(requestBillingAgreement:withResolver:withRejecter:)
  func requestBillingAgreement(
    options: [String: String], resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let clientToken = options["clientToken"] ?? ""
    // Step 1: Initialize Braintree API Client
    let apiClientOptional = BTAPIClient(authorization: clientToken)
    guard let apiClient = apiClientOptional else {
      return reject(
        EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
        ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue,
        NSError(domain: ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue, code: -1))
    }
    // Step 2: Initialize BPayPal API Client
    let payPalClient = BTPayPalClient(apiClient: apiClient)
    let vaultRequest = prepareBTPayPalVaultRequest(options: options)
    payPalClient.tokenize(vaultRequest) {
      (accountNonce, error) -> Void in
      if let accountNonce = accountNonce {
        // Step 3: Handle Success: Paypal Nonce Created resolved
        return resolve(
          prepareBTPayPalAccountNonceResult(
            accountNonce: accountNonce
          ))
      } else if let error = error as? BTPayPalError {
        // Step 3: Handle Error: Tokenize error
        switch error.errorCode {
        case BTPayPalError.disabled.errorCode:
          return reject(
            EXCEPTION_TYPES.PAYPAL_DISABLED_IN_CONFIGURATION.rawValue,
            ERROR_TYPES.USER_CANCEL_TRANSACTION_ERROR.rawValue,
            NSError(
              domain: ERROR_TYPES.PAYPAL_DISABLED_IN_CONFIGURATION_ERROR.rawValue,
              code: BTPayPalError.disabled.errorCode)
          )
        case BTPayPalError.canceled.errorCode:
          return reject(
            EXCEPTION_TYPES.USER_CANCEL_EXCEPTION.rawValue,
            ERROR_TYPES.USER_CANCEL_TRANSACTION_ERROR.rawValue,
            NSError(
              domain: ERROR_TYPES.USER_CANCEL_TRANSACTION_ERROR.rawValue,
              code: BTPayPalError.canceled.errorCode)
          )
        default:
          return reject(
            EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
            ERROR_TYPES.TOKENIZE_VAULT_PAYMENT_ERROR.rawValue,
            NSError(
              domain: error.localizedDescription,
              code: -1
            )
          )
        }
      }
    }
  }

  @objc(requestOneTimePayment:withResolver:withRejecter:)
  func requestOneTimePayment(
    options: [String: String], resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let clientToken = options["clientToken"] ?? ""
    // Step 1: Initialize Braintree API Client
    let apiClientOptional = BTAPIClient(authorization: clientToken)
    guard let apiClient = apiClientOptional else {
      return reject(
        EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
        ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue,
        NSError(domain: ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue, code: -1))
    }
    // Step 2: Initialize BPayPal API Client
    let payPalClient = BTPayPalClient(apiClient: apiClient)
    let checkoutRequest = prepareBTPayPalCheckoutRequest(options: options)
    payPalClient.tokenize(checkoutRequest) {
      (accountNonce, error) -> Void in
      if let accountNonce = accountNonce {
        // Step 3: Handle Success: Paypal Nonce Created resolved
        return resolve(
          prepareBTPayPalAccountNonceResult(
            accountNonce: accountNonce
          ))
      } else if let error = error as? BTPayPalError {
        // Step 3: Handle Error: Tokenize error
        switch error.errorCode {
        case BTPayPalError.disabled.errorCode:
          return reject(
            EXCEPTION_TYPES.PAYPAL_DISABLED_IN_CONFIGURATION.rawValue,
            ERROR_TYPES.USER_CANCEL_TRANSACTION_ERROR.rawValue,
            NSError(
              domain: ERROR_TYPES.PAYPAL_DISABLED_IN_CONFIGURATION_ERROR.rawValue,
              code: BTPayPalError.disabled.errorCode)
          )
        case BTPayPalError.canceled.errorCode:
          return reject(
            EXCEPTION_TYPES.USER_CANCEL_EXCEPTION.rawValue,
            ERROR_TYPES.USER_CANCEL_TRANSACTION_ERROR.rawValue,
            NSError(
              domain: ERROR_TYPES.USER_CANCEL_TRANSACTION_ERROR.rawValue,
              code: BTPayPalError.canceled.errorCode)
          )
        default:
          return reject(
            EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
            ERROR_TYPES.TOKENIZE_VAULT_PAYMENT_ERROR.rawValue,
            NSError(
              domain: error.localizedDescription,
              code: -1
            )
          )
        }
      }
    }
  }

  @objc(requestApplePayPayment:withResolver:withRejecter:)
    func requestApplePayPayment(
      options: [String: String], resolve: @escaping RCTPromiseResolveBlock,
      reject: @escaping RCTPromiseRejectBlock
    ) {
      let clientToken = options["clientToken"] ?? ""
      let merchantId = options["merchantId"] ?? nil
      let merchantName = options["merchantName"] ?? nil
      let amount: String = options["amount"] as! String

      var countryCode: String = options["countryCode"] ?? "US"
      var currencyCode: String = options["currencyCode"] ?? "USD"

      if (options.value(forKey: "countryCode") != nil) {
        countryCode = options.value(forKey: "countryCode") as! String
      }

      if (options.value(forKey: "currencyCode") != nil) {
        currencyCode = options.value(forKey: "currencyCode") as! String
      }

      if (merchantId == nil) {
        reject(
          EXCEPTION_TYPES.MERCHANT_ID_EXCEPTION.rawValue,
          ERROR_TYPES.MERCHANT_ID_ERROR.rawValue,
          NSError(domain: ERROR_TYPES.MERCHANT_ID_ERROR.rawValue, code: -1)
        )
      }

      if (merchantName == nil) {
        reject(
          EXCEPTION_TYPES.MERCHANT_NAME_EXCEPTION.rawValue,
          ERROR_TYPES.MERCHANT_NAME_ERROR.rawValue,
          NSError(domain: ERROR_TYPES.MERCHANT_NAME_ERROR.rawValue, code: -1)
        )
      }

      self.resolve = resolve
      self.reject = reject

      // Step 1: Initialize Braintree API Client
      self.btClient = BTAPIClient(authorization: clientToken)
      guard let apiClient = self.btClient else {
        return reject(
          EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
          ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue,
          NSError(domain: ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue, code: -1)
        )
      }
      // Step 2: Initialize ApplePay Client and PaymentRequest
      let status = applePayStatus()
      let applePayClient = BTApplePayClient(apiClient: self.btClient)

      if (status.canMakePayments) {
        applePayClient.paymentRequest {(request, error) in
          if (error != nil) {
            reject(
              EXCEPTION_TYPES.APPLE_PAY_REQUEST_EXCEPTION.rawValue,
              ERROR_TYPES.APPLE_PAY_REQUEST_ERROR.rawValue,
              NSError(domain: ERROR_TYPES.APPLE_PAY_REQUEST_ERROR.rawValue, code: -1)
            )
            return
          }

          if #available(iOS 11.0, *) {
            request.requiredBillingContactFields = [.name, .postalAddress]
          }

          let paymentItem = PKPaymentSummaryItem.init(label: merchantName, amount: NSDecimalNumber(string: amount), type: .final)

          request.currencyCode = currencyCode
          request.countryCode = countryCode
          request.merchantIdentifier = merchantId!
          request.merchantCapabilities = PKMerchantCapability.capability3DS
          request.supportedNetworks = self.supportedNetworks
          request.paymentSummaryItems = [paymentItem]

          self.paymentController = PKPaymentAuthorizationController(paymentRequest: request)
          self.paymentController!.delegate = self
          self.paymentController!.present(completion: {(presented: Bool) in
            if (!presented) {
              reject(
                EXCEPTION_TYPES.APPLE_PAY_SHEET_EXCEPTION.rawValue,
                ERROR_TYPES.APPLE_PAY_SHEET_ERROR.rawValue,
                NSError(domain: ERROR_TYPES.APPLE_PAY_SHEET_EXCEPTION.rawValue, code: -1)
              )
            }
          })
        }
      } else {
        reject(
          EXCEPTION_TYPES.APPLE_PAY_PAYMENT_EXCEPTION.rawValue,
          ERROR_TYPES.APPLE_PAY_PAYMENT_ERROR.rawValue,
          NSError(domain: ERROR_TYPES.APPLE_PAY_PAYMENT_ERROR.rawValue, code: -1)
        )
      }
    }

  @objc(getDeviceDataFromDataCollector:withResolver:withRejecter:)
  func getDeviceDataFromDataCollector(
    clientToken: String, resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    // Step 1: Initialize Braintree API Client
    let apiClientOptional = BTAPIClient(authorization: clientToken)
    guard let apiClient = apiClientOptional else {
      return reject(
        EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
        ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue,
        NSError(domain: ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue, code: -1))
    }
    // Step 2: Initialize DataCollerctor
    let dataCollector = BTDataCollector(apiClient: apiClient)
    // Step 3: Try To Collect Device Data and make a corelation Id if that is possible
    dataCollector.collectDeviceData { corelationId, dataCollectorError in
      if let corelationId = corelationId {
        // Step 4: Return corelation id
        return resolve(corelationId)
      } else if let dataCollectorError = dataCollectorError {
        // Step 4: Handle Error: DataCollector error
        return reject(
          EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
          ERROR_TYPES.DATA_COLLECTOR_ERROR.rawValue,
          NSError(
            domain: ERROR_TYPES.DATA_COLLECTOR_ERROR.rawValue,
            code: -1)
        )
      }
    }
  }

  @objc(tokenizeCardData:withResolver:withRejecter:)
  func tokenizeCardData(
    options: [String: String], resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let clientToken = options["clientToken"] ?? ""
    // Step 1: Initialize Braintree API Client
    let apiClientOptional = BTAPIClient(authorization: clientToken)
    guard let apiClient = apiClientOptional else {
      return reject(
        EXCEPTION_TYPES.SWIFT_EXCEPTION.rawValue,
        ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue,
        NSError(domain: ERROR_TYPES.API_CLIENT_INITIALIZATION_ERROR.rawValue, code: -1))
    }
    // Step 2: Initialize DataCollerctor
    let cardClient = BTCardClient(apiClient: apiClient)
    let card = prepareCardData(options: options)
    // Step 3: Try To Collect Device Data and make a corelation Id if that is possible
    cardClient.tokenize(card) {
      (cardNonce, error) -> Void in
      if let cardNonce = cardNonce {
        // Step 4: Return corelation id
        return resolve(prepareBTCardNonceResult(cardNonce: cardNonce))
      } else if let error = error {
        // Step 4: Handle Error: DataCollector error
        return reject(
          EXCEPTION_TYPES.TOKENIZE_EXCEPTION.rawValue,
          ERROR_TYPES.CARD_TOKENIZATION_ERROR.rawValue,
          NSError(
            domain: ERROR_TYPES.CARD_TOKENIZATION_ERROR.rawValue,
            code: -1)
        )
      }
    }
  }

  @objc internal func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    self.btClient!.tokenizeApplePay(payment) { (applePayNonce, error) in
      if (error != nil) {
        self.reject!(
          EXCEPTION_TYPES.APPLE_PAY_TOKEN_EXCEPTION.rawValue,
          ERROR_TYPES.APPLE_PAY_TOKEN_ERROR.rawValue,
          NSError(domain: ERROR_TYPES.APPLE_PAY_TOKEN_ERROR.rawValue, code: -1)
        )
        completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
      } else {
        self.resolve!(["nonce": applePayNonce.nonce])
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
      }
    }

    self.resetPromise()
  }

  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    if (self.paymentController != nil) {
      self.paymentController!.dismiss(completion: nil)
    }

    if (self.reject != nil) {
      self.resolve!(["cancelled": true])
    }

    self.resetPromise()
  }

  private func resetPromise() -> Void {
    self.reject = nil
    self.resolve = nil
  }

  private func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
    return (PKPaymentAuthorizationController.canMakePayments(), PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
  }
}
