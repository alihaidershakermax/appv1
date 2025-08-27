import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/subscription.dart';

class StripePaymentService {
  final Dio _dio;
  final String _backendUrl; // Your backend URL for Stripe operations
  
  StripePaymentService({
    required Dio dio,
    required String backendUrl,
  }) : _dio = dio,
       _backendUrl = backendUrl;

  // Initialize Stripe
  static Future<void> initialize({
    required String publishableKey,
  }) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  // Create payment intent for subscription
  Future<Map<String, dynamic>> createPaymentIntent({
    required String customerId,
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    String currency = 'USD',
  }) async {
    try {
      final amount = _getAmountForTier(tier, billingPeriod);
      
      final response = await _dio.post(
        '$_backendUrl/create-payment-intent',
        data: {
          'amount': (amount * 100).round(), // Amount in cents
          'currency': currency.toLowerCase(),
          'customer_id': customerId,
          'metadata': {
            'subscription_tier': tier.name,
            'billing_period': billingPeriod.name,
          },
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to create payment intent: $e');
    }
  }

  // Create Stripe customer
  Future<String> createCustomer({
    required String email,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        '$_backendUrl/create-customer',
        data: {
          'email': email,
          'name': name,
        },
      );

      return response.data['customer_id'] as String;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to create customer: $e');
    }
  }

  // Create subscription
  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String paymentMethodId,
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
  }) async {
    try {
      final priceId = _getPriceIdForTier(tier, billingPeriod);
      
      final response = await _dio.post(
        '$_backendUrl/create-subscription',
        data: {
          'customer_id': customerId,
          'payment_method_id': paymentMethodId,
          'price_id': priceId,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to create subscription: $e');
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription({
    required String subscriptionId,
    bool immediately = false,
  }) async {
    try {
      await _dio.post(
        '$_backendUrl/cancel-subscription',
        data: {
          'subscription_id': subscriptionId,
          'immediately': immediately,
        },
      );
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to cancel subscription: $e');
    }
  }

  // Update subscription
  Future<Map<String, dynamic>> updateSubscription({
    required String subscriptionId,
    required SubscriptionTier newTier,
    required BillingPeriod newBillingPeriod,
  }) async {
    try {
      final newPriceId = _getPriceIdForTier(newTier, newBillingPeriod);
      
      final response = await _dio.post(
        '$_backendUrl/update-subscription',
        data: {
          'subscription_id': subscriptionId,
          'new_price_id': newPriceId,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to update subscription: $e');
    }
  }

  // Process one-time payment
  Future<PaymentIntent> processPayment({
    required String paymentIntentClientSecret,
  }) async {
    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      return paymentIntent;
    } on StripeException catch (e) {
      throw PaymentException('Payment failed: ${e.error.localizedMessage}');
    } catch (e) {
      throw PaymentException('Payment failed: $e');
    }
  }

  // Setup payment method for future payments
  Future<SetupIntent> setupFuturePayments({
    required String customerId,
  }) async {
    try {
      // Create setup intent on backend
      final response = await _dio.post(
        '$_backendUrl/create-setup-intent',
        data: {
          'customer_id': customerId,
        },
      );

      final clientSecret = response.data['client_secret'] as String;

      // Confirm setup intent with Stripe
      final setupIntent = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      return setupIntent;
    } on StripeException catch (e) {
      throw PaymentException('Setup failed: ${e.error.localizedMessage}');
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw PaymentException('Setup failed: $e');
    }
  }

  // Get customer's payment methods
  Future<List<PaymentMethod>> getPaymentMethods({
    required String customerId,
  }) async {
    try {
      final response = await _dio.get(
        '$_backendUrl/payment-methods/$customerId',
      );

      final paymentMethodsData = response.data['payment_methods'] as List;
      return paymentMethodsData
          .map((pm) => PaymentMethod.fromJson(pm))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to get payment methods: $e');
    }
  }

  // Detach payment method
  Future<void> detachPaymentMethod({
    required String paymentMethodId,
  }) async {
    try {
      await _dio.post(
        '$_backendUrl/detach-payment-method',
        data: {
          'payment_method_id': paymentMethodId,
        },
      );
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to detach payment method: $e');
    }
  }

  // Get subscription details from Stripe
  Future<Map<String, dynamic>> getSubscriptionDetails({
    required String subscriptionId,
  }) async {
    try {
      final response = await _dio.get(
        '$_backendUrl/subscription/$subscriptionId',
      );

      return response.data;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to get subscription details: $e');
    }
  }

  // Helper methods
  double _getAmountForTier(SubscriptionTier tier, BillingPeriod billingPeriod) {
    switch (billingPeriod) {
      case BillingPeriod.monthly:
        return tier.monthlyPrice;
      case BillingPeriod.yearly:
        return tier.yearlyPrice;
    }
  }

  String _getPriceIdForTier(SubscriptionTier tier, BillingPeriod billingPeriod) {
    // These should be replaced with actual Stripe Price IDs
    switch (tier) {
      case SubscriptionTier.free:
        return '';
      case SubscriptionTier.premium:
        return billingPeriod == BillingPeriod.monthly
            ? 'price_premium_monthly'
            : 'price_premium_yearly';
      case SubscriptionTier.premiumPlus:
        return billingPeriod == BillingPeriod.monthly
            ? 'price_premium_plus_monthly'
            : 'price_premium_plus_yearly';
    }
  }

  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return 'Invalid request. Please check your payment information.';
      case 401:
        return 'Authentication failed. Please try again.';
      case 402:
        return 'Payment required. Please update your payment method.';
      case 403:
        return 'Access forbidden. Please contact support.';
      case 404:
        return 'Resource not found. Please try again.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}