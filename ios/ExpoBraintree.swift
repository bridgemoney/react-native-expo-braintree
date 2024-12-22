//
//  BTPayPalVaultRequest.swift
//  expo-braintree
//
//  Created by Maciej Sasinowski on 28/04/2024.
//

import Braintree
import Foundation
import PassKit
import React

enum EXCEPTION_TYPES: String {
  case SWIFT_EXCEPTION = "ReactNativeExpoBraintree:`SwiftException"
  case USER_CANCEL_EXCEPTION = "ReactNativeExpoBraintree:`UserCancelException"
  case TOKENIZE_EXCEPTION = "ReactNativeExpoBraintree:`TokenizeException"
  case PAYPAL_DISABLED_IN_CONFIGURATION =
    "ReactNativeExpoBraintree:`Paypal disabled in configuration"
  case MERCHANT_NAME_EXCEPTION = "ReactNativeExpoBraintree:`You must provide merchantName"
  case APPLE_PAY_SHEET_EXCEPTION = "ReactNativeExpoBraintree:`Cannot present ApplePay sheet"
  case APPLE_PAY_PAYMENT_EXCEPTION = "ReactNativeExpoBraintree:`You cannot make ApplePay payments"
  case APPLE_PAY_TOKEN_EXCEPTION = "ReactNativeExpoBraintree:`Cannot tokenize ApplePay payment"
  case APPLE_PAY_REQUEST_EXCEPTION = "ReactNativeExpoBraintree:`Cannot create a payment request"
  case APPLE_PAY_REQUEST_AUTHORIZATION_EXCEPTION =
    "ReactNativeExpoBraintree:`Cannot authroize a payment request"
}
enum ERROR_TYPES: String {
  case API_CLIENT_INITIALIZATION_ERROR = "API_CLIENT_INITIALIZATION_ERROR"
  case TOKENIZE_VAULT_PAYMENT_ERROR = "TOKENIZE_VAULT_PAYMENT_ERROR"
  case USER_CANCEL_TRANSACTION_ERROR = "USER_CANCEL_TRANSACTION_ERROR"
  case PAYPAL_DISABLED_IN_CONFIGURATION_ERROR = "PAYPAL_DISABLED_IN_CONFIGURATION_ERROR"
  case DATA_COLLECTOR_ERROR = "DATA_COLLECTOR_ERROR"
  case CARD_TOKENIZATION_ERROR = "CARD_TOKENIZATION_ERROR"
  case MERCHANT_NAME_ERROR = "MERCHANT_NAME_ERROR"
  case APPLE_PAY_SHEET_ERROR = "APPLE_PAY_SHEET_ERROR"
  case APPLE_PAY_PAYMENT_ERROR = "APPLE_PAY_PAYMENT_ERROR"
  case APPLE_PAY_TOKEN_ERROR = "APPLE_PAY_TOKEN_ERROR"
  case APPLE_PAY_REQUEST_ERROR = "APPLE_PAY_REQUEST_ERROR"
  case APPLE_PAY_REQUEST_AUTHORIZATION_ERROR = "APPLE_PAY_REQUEST_AUTHORIZATION_ERROR"
}
@objc(ExpoBraintree)
class ExpoBraintree: NSObject {

  let supportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .discover,
    .masterCard,
    .visa,
    .interac,
    .JCB,
  ]
  var resolve: RCTPromiseResolveBlock? = nil
  var reject: RCTPromiseRejectBlock? = nil
  var apiClient: BTAPIClient? = nil

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
    options: [String: String],
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let clientToken: String = options["clientToken"] ?? ""
    let merchantName: String? = options["merchantName"] ?? nil
    let amount: String = options["amount"]!
    let countryCode: String = options["countryCode"] ?? "US"
    let currencyCode: String = options["currencyCode"] ?? "USD"

    if merchantName == nil {
      reject(
        EXCEPTION_TYPES.MERCHANT_NAME_EXCEPTION.rawValue,
        ERROR_TYPES.MERCHANT_NAME_ERROR.rawValue,
        NSError(domain: ERROR_TYPES.MERCHANT_NAME_ERROR.rawValue, code: -1)
      )
    }

    self.resolve = resolve
    self.reject = reject

    self.apiClient = BTAPIClient(authorization: clientToken)
    let applePayClient = BTApplePayClient(apiClient: self.apiClient!)

    let status = applePayStatus()

    if status.canMakePayments {
      applePayClient.makePaymentRequest(completion: { (request, error) in
        guard error == nil else {
          reject(
            EXCEPTION_TYPES.APPLE_PAY_REQUEST_EXCEPTION.rawValue,
            ERROR_TYPES.APPLE_PAY_REQUEST_ERROR.rawValue,
            NSError(domain: error!.localizedDescription, code: -1)
          )
          return
        }

        guard let paymentRequest = request else {
          reject(
            EXCEPTION_TYPES.APPLE_PAY_REQUEST_EXCEPTION.rawValue,
            ERROR_TYPES.APPLE_PAY_REQUEST_ERROR.rawValue,
            NSError(domain: ERROR_TYPES.APPLE_PAY_REQUEST_ERROR.rawValue, code: -1)
          )
          return
        }

        let paymentItem = PKPaymentSummaryItem.init(
          label: merchantName!, amount: NSDecimalNumber(string: amount), type: .final)

        paymentRequest.currencyCode = currencyCode
        paymentRequest.countryCode = countryCode
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
        paymentRequest.supportedNetworks = self.supportedNetworks
        paymentRequest.paymentSummaryItems = [paymentItem]
        paymentRequest.requiredBillingContactFields = [PKContactField.postalAddress]

        if let pc = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
          as PKPaymentAuthorizationController?
        {
          pc.delegate = self
          pc.present(completion: { (presented: Bool) in
            if !presented {
              reject(
                EXCEPTION_TYPES.APPLE_PAY_SHEET_EXCEPTION.rawValue,
                ERROR_TYPES.APPLE_PAY_SHEET_ERROR.rawValue,
                NSError(domain: ERROR_TYPES.APPLE_PAY_SHEET_ERROR.rawValue, code: -1)
              )
            }
          })
        } else {
          reject(
            EXCEPTION_TYPES.APPLE_PAY_REQUEST_AUTHORIZATION_EXCEPTION.rawValue,
            ERROR_TYPES.APPLE_PAY_REQUEST_AUTHORIZATION_ERROR.rawValue,
            NSError(domain: ERROR_TYPES.APPLE_PAY_REQUEST_AUTHORIZATION_ERROR.rawValue, code: -1)
          )
        }

      })
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

  private func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
    return (
      PKPaymentAuthorizationController.canMakePayments(),
      PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    )
  }
}

extension ExpoBraintree: Promiseable {
  func resetPromises() {
    self.resolve = nil
    self.reject = nil
  }
}

extension ExpoBraintree: PKPaymentAuthorizationControllerDelegate {
  @objc func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
  ) {
    let applePayClient = BTApplePayClient(apiClient: self.apiClient!)

    applePayClient.tokenize(
      payment,
      completion: { (applePayNonce, error) in
        guard error == nil else {
          self.reject!(
            EXCEPTION_TYPES.APPLE_PAY_TOKEN_EXCEPTION.rawValue,
            ERROR_TYPES.APPLE_PAY_TOKEN_ERROR.rawValue,
            NSError(domain: error!.localizedDescription, code: -1)
          )
          self.resetPromises()
          completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
          return
        }

        guard let appNonce = applePayNonce else {
          self.reject!(
            EXCEPTION_TYPES.APPLE_PAY_TOKEN_EXCEPTION.rawValue,
            ERROR_TYPES.APPLE_PAY_TOKEN_ERROR.rawValue,
            NSError(domain: ERROR_TYPES.APPLE_PAY_TOKEN_ERROR.rawValue, code: -1)
          )
          self.resetPromises()
          completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
          return
        }

        self.resolve!(["nonce": appNonce.nonce])
        self.resetPromises()
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
      })
  }

  func paymentAuthorizationControllerDidFinish(
    _ controller: PKPaymentAuthorizationController
  ) {
    controller.dismiss(completion: nil)

    if self.resolve != nil {
      self.resolve!(["cancelled": true])
    }

    self.resetPromises()
  }
}
