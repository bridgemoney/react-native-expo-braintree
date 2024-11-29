export enum EXCEPTION_TYPES {
  SWIFT_EXCEPTION = 'ExpoBraintree:`SwiftException',
  USER_CANCEL_EXCEPTION = 'ExpoBraintree:`UserCancelException',
  PAYPAL_DISABLED_IN_CONFIGURATION = 'ExpoBraintree:`Paypal disabled in configuration',
  TOKENIZE_EXCEPTION = 'ExpoBraintree:`TokenizeException',
  MERCHANT_NAME_EXCEPTION = 'ReactNativeExpoBraintree:`You must provide merchantName',
  APPLE_PAY_SHEET_EXCEPTION = 'ReactNativeExpoBraintree:`Cannot present ApplePay sheet',
  APPLE_PAY_PAYMENT_EXCEPTION = 'ReactNativeExpoBraintree:`You cannot make ApplePay payments',
  APPLE_PAY_TOKEN_EXCEPTION = 'ReactNativeExpoBraintree:`Cannot tokenize ApplePay payment',
  APPLE_PAY_REQUEST_EXCEPTION = 'ReactNativeExpoBraintree:`Cannot create a payment request',
}

export enum ERROR_TYPES {
  API_CLIENT_INITIALIZATION_ERROR = 'API_CLIENT_INITIALIZATION_ERROR',
  TOKENIZE_VAULT_PAYMENT_ERROR = 'TOKENIZE_VAULT_PAYMENT_ERROR',
  USER_CANCEL_TRANSACTION_ERROR = 'USER_CANCEL_TRANSACTION_ERROR',
  PAYPAL_DISABLED_IN_CONFIGURATION_ERROR = 'PAYPAL_DISABLED_IN_CONFIGURATION_ERROR',
  DATA_COLLECTOR_ERROR = 'DATA_COLLECTOR_ERROR',
  CARD_TOKENIZATION_ERROR = 'CARD_TOKENIZATION_ERROR',
  MERCHANT_NAME_ERROR = 'MERCHANT_NAME_ERROR',
  APPLE_PAY_SHEET_ERROR = 'APPLE_PAY_SHEET_ERROR',
  APPLE_PAY_PAYMENT_ERROR = 'APPLE_PAY_PAYMENT_ERROR',
  APPLE_PAY_TOKEN_ERROR = 'APPLE_PAY_TOKEN_ERROR',
  APPLE_PAY_REQUEST_ERROR = 'APPLE_PAY_REQUEST_ERROR',
}

export enum BTPayPalCheckoutIntent {
  authorize = 'authorize',
  order = 'order',
  sale = 'sale',
}
export enum BTPayPalRequestUserAction {
  none = 'none',
  payNow = 'payNow',
}

export enum BoolValue {
  true = 'true',
  false = 'false',
}

export type RequestBillingAgreementOptions = {
  clientToken: string;
  billingAgreementDescription?: string;
  displayName?: string;
  localeCode?: string;
  userAuthenticationEmail?: string;
  offerCredit?: BoolValue;
  isShippingAddressRequired?: BoolValue;
  isShippingAddressEditable?: BoolValue;
  isAccessibilityElement?: BoolValue;
};

export type RequestOneTimePaymentOptions = {
  amount: string;
  intent?: BTPayPalCheckoutIntent;
  userAction?: BTPayPalRequestUserAction;
  offerPayLater?: BoolValue;
  currencyCode?: string;
  requestBillingAgreement?: BoolValue;
  clientToken: string;
};

export type TokenizeCardOptions = {
  number: string;
  expirationMonth: string;
  expirationYear: string;
  cvv: string;
  postalCode?: string;
  clientToken: string;
};

export type BTPayPalAccountNonceAddressResult = {
  recipientName?: string;
  streetAddress?: string;
  extendedAddress?: string;
  locality?: string;
  countryCodeAlpha2?: string;
  postalCode?: string;
  region?: string;
};

export type BTPayPalAccountNonceResult = {
  email?: string;
  payerID?: string;
  nonce: string;
  firstName?: string;
  lastName?: string;
  billingAddress?: BTPayPalAccountNonceAddressResult;
  shippingAddress?: BTPayPalAccountNonceAddressResult;
};

export type BTCardTokenizationNonceResult = {
  nonce: string;
  cardNetwork?: string;
  lastTwo?: string;
  lastFour?: string;
  expirationMonth?: string;
  expirationYear?: string;
};

export type BTPayPalGetDeviceDataResult = string;

export type BTPayPalError = {
  code?: EXCEPTION_TYPES;
  message?: ERROR_TYPES | string;
  domain?: ERROR_TYPES;
};

export type RequestApplePayPaymentOptions = {
  amount: string;
  merchantName: string;
  currencyCode?: string;
  countryCode?: string;
  clientToken: string;
};

export type BTApplePayTokenizationNonceResult = {
  nonce: string;
};
