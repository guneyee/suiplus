
module nft_rental_suiplus::royalty_rule {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::tx_context::TxContext;
    use sui::transfer_policy::{
        Self as policy,
        TransferPolicy,
        TransferPolicyCap,
        TransferRequest
    };
    /// Invalid basis points value (must be between 0 and 10000)
    const EIncorrectArgument: u64 = 0;
    /// Insufficient payment amount for royalty
    const EInsufficientAmount: u64 = 1;
    /// Zero amount payment not allowed
    const EZeroAmount: u64 = 2;
    /// Invalid minimum amount (must be greater than zero)
    const EInvalidMinAmount: u64 = 3;
    /// Payment is required for this transfer
    const ENoPayment: u64 = 4;
    /// Overflow occurred during calculation
    const EOverflow: u64 = 5;
    
    const MAX_BPS: u16 = 10_000;
    /// Rule type for the royalty fee rule
    struct Rule has drop {}

    /// Configuration for the royalty rule
    /// * amount_bp - basis points for the royalty fee (10000 = 100%)
    /// * min_amount - minimum amount of SUI to charge as royalty
    struct Config has store, drop {
        amount_bp: u16,
        min_amount: u64
    }
    /// Adds a royalty rule to the transfer policy
    /// * policy - the transfer policy to add the rule to
    /// * cap - capability required to modify the policy
    /// * amount_bp - basis points for the royalty fee (10000 = 100%)
    /// * min_amount - minimum amount of SUI to charge as royalty
    public fun add<T: key + store>(
        policy: &mut TransferPolicy<T>,
        cap: &TransferPolicyCap<T>,
        amount_bp: u16,
        min_amount: u64
    ) {
        // Check that amount_bp is within valid range (0-10000)
        assert!(amount_bp <= MAX_BPS, EIncorrectArgument);
        
        // Check that min_amount is greater than zero
        assert!(min_amount > 0, EInvalidMinAmount);
        
        policy::add_rule(Rule {}, policy, cap, Config { amount_bp, min_amount })
    }
    /// Pay the royalty fee for a transfer
    /// * policy - the transfer policy containing the royalty rule
    /// * request - the transfer request being processed
    /// * payment - the coin to take the royalty fee from
    /// * ctx - the transaction context
    public fun pay<T: key + store>(
        policy: &mut TransferPolicy<T>,
        request: &mut TransferRequest<T>,
        payment: &mut Coin<SUI>, 
        ctx: &mut TxContext   
    ) {
        // Check that payment coin exists and has non-zero value
        assert!(coin::value(payment) > 0, EZeroAmount);
        
        // Get the paid amount from request
        let paid = policy::paid(request);
        assert!(paid > 0, ENoPayment);
        
        // Calculate fee amount
        let amount = fee_amount(policy, paid);
        
        // Verify sufficient payment
        assert!(coin::value(payment) >= amount, EInsufficientAmount);
        
        // Split payment and add to policy balance
        let fee_coin = coin::split(payment, amount, ctx);
        policy::add_to_balance(Rule {}, policy, fee_coin);
        
        // Add receipt to request
        policy::add_receipt(Rule {}, request)
}

    public fun fee_amount<T: key + store>(policy: &TransferPolicy<T>, paid: u64): u64 {
        let config: &Config = policy::get_rule(Rule {}, policy);
        
        // Convert to u128 for safe multiplication
        let paid_u128 = (paid as u128);
        let amount_bp_u128 = (config.amount_bp as u128);
        
        // Calculate with overflow check
        let calc_u128 = paid_u128 * amount_bp_u128;
        assert!(calc_u128 <= ((MAX_BPS as u128) * (std::u64::MAX as u128)), EOverflow);
        
        let calculated_amount = ((calc_u128 / 10_000) as u64);

        // If the calculated amount is less than the minimum, use the minimum
        if (calculated_amount < config.min_amount) {
            config.min_amount
        } else {
            calculated_amount
        }
    }
}