// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Description:
/// This module defines a Rule which sets the floor price for items of type T.
///
/// Configuration:
/// - floor_price - the floor price in MIST.
///
/// Use cases:
/// - Defining a floor price for all trades of type T.
/// - Prevent trading of locked items with low amounts (e.g. by using purchase_cap).
///
module nft_rental_suiplus::floor_price_rule {
    use sui::transfer_policy::{
        Self as policy,
        TransferPolicy,
        TransferPolicyCap,
        TransferRequest
    };

    /// The price was lower than the floor price.
    const EPriceTooSmall: u64 = 0;
    /// Floor price must be greater than zero.
    const EInvalidFloorPrice: u64 = 1;

    /// The "Rule" witness to authorize the policy.
    struct Rule has drop {}

    /// Configuration for the `Floor Price Rule`.
    /// Holds the minimum price that an item can be sold at.
    /// There can't be any sales with a price < than the floor_price.
    struct Config has store, drop {
        /// Minimum price in MIST
        floor_price: u64
    }

    /// Creator action: Add the Floor Price Rule for the `T`.
    /// Pass in the `TransferPolicy`, `TransferPolicyCap` and `floor_price`.
    /// Checks that floor_price is greater than zero.
    public fun add<T>(
        policy: &mut TransferPolicy<T>,
        cap: &TransferPolicyCap<T>,
        floor_price: u64
    ) {
        // Floor price must be greater than zero
        assert!(floor_price > 0, EInvalidFloorPrice);
        policy::add_rule(Rule {}, policy, cap, Config { floor_price })
    }

    /// Buyer action: Prove that the amount is higher or equal to the floor_price.
    /// Checks that paid amount is not zero and meets the floor price.
    public fun prove<T>(
        policy: &mut TransferPolicy<T>,
        request: &mut TransferRequest<T>
    ) {
        let config: &Config = policy::get_rule(Rule {}, policy);
        let paid = policy::paid(request);
        // Paid amount must be greater than zero
        assert!(paid > 0, EPriceTooSmall);
        // Paid amount must meet or exceed the floor price
        assert!(paid >= config.floor_price, EPriceTooSmall);
        policy::add_receipt(Rule {}, request)
    }
}