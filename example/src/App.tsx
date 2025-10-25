import * as React from 'react';

import {
  ActivityIndicator,
  Button,
  Platform,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import {
  BTVenmoPaymntMethodUsage,
  BoolValue,
  getDeviceDataFromDataCollector,
  requestBillingAgreement,
  requestOneTimePayment,
  requestVenmoNonce,
  tokenizeCardData,
  requestGooglePayPayment,
  requestApplePayPayment,
} from 'react-native-expo-braintree';

export const clientToken = 'sandbox_x62mvdjj_p8ngm2sczm8248vg';
export const merchantAppLink = 'https://braintree-example-app.web.app';

export default function App() {
  const [isLoading, setIsLoading] = React.useState(false);
  const [result, setResult] = React.useState('');

  async function runPayment(payment: () => Promise<any>) {
    try {
      setIsLoading(true);
      const res = await payment();
      setIsLoading(false);
      setResult(JSON.stringify(res));
      console.log(JSON.stringify(res));
    } catch (e) {
      setResult(JSON.stringify(e));
      console.log(JSON.stringify(e));
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <View style={styles.container}>
      <Button
        title="Click Me to request Billing Agreement"
        onPress={async () => {
          await runPayment(() => {
            return requestBillingAgreement({
              clientToken,
              merchantAppLink,
            });
          });
        }}
      />
      <Button
        title="Click Me To Get Device Data"
        onPress={async () => {
          await runPayment(() => {
            return getDeviceDataFromDataCollector(clientToken);
          });
        }}
      />

      <Button
        title="Click Me To request One time Payment"
        onPress={async () => {
          await runPayment(() => {
            return requestOneTimePayment({
              clientToken,
              amount: '5',
              merchantAppLink,
            });
          });
        }}
      />

      <Button
        title="Click Me To Tokenize Card"
        onPress={async () => {
          await runPayment(() => {
            return tokenizeCardData({
              clientToken,
              number: '1111222233334444',
              expirationMonth: '11',
              expirationYear: '24',
              cvv: '123',
              postalCode: '',
            });
          });
        }}
      />

      <Button
        title="Click Me To Request a Venmo nonce"
        onPress={async () => {
          await runPayment(() => {
            return requestVenmoNonce({
              clientToken,
              vault: BoolValue.true,
              paymentMethodUsage: BTVenmoPaymntMethodUsage.multiUse,
              totalAmount: '5',
            });
          });
        }}
      />
      {Platform.OS === 'android' ? (
        <Button
          title="Click Me To request GooglePay Payment"
          onPress={async () => {
            await runPayment(() => {
              return requestGooglePayPayment({
                clientToken,
                amount: '5',
                currencyCode: 'USD',
                isPhoneNumberRequired: false,
                isShippingAddressRequired: false,
                env: 'test',
              });
            });
          }}
        />
      ) : (
        <Button
          title="Click Me To request ApplePay Payment"
          onPress={async () => {
            await runPayment(() => {
              return requestApplePayPayment({
                clientToken,
                amount: '5',
                currencyCode: 'USD',
                countryCode: 'US',
                merchantName: 'BridgeMoney, Inc',
              });
            });
          }}
        />
      )}
      {isLoading && <ActivityIndicator />}
      <Text>{result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    rowGap: 20,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
