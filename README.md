# NFT Rental & Marketplace Smart Contract

A comprehensive Move smart contract for NFT rental and marketplace functionality on the Sui blockchain, built using the Kiosk framework for secure NFT management.

## 🚀 Features

- **NFT Rental System**: Rent NFTs for limited time periods without transferring ownership
- **Marketplace Functionality**: Buy/sell NFTs with full ownership transfer
- **Time-based Expiry**: Automatic rental expiration and NFT return
- **Kiosk Integration**: Secure NFT management using Sui's Kiosk framework
- **Gas Efficient**: Optimized for minimal transaction costs
- **Modular Design**: Clean separation of rental and marketplace logic

## 📋 Project Structure

```
suiplus.move/
├── Move.toml                           # Project configuration
├── sources/
│   ├── nft_rental_marketplace.move    # Main smart contract
│   ├── test_nft_rental_marketplace.move # Test cases
│   └── scripts/
│       ├── create_listing.move        # Listing creation scripts
│       ├── rent_nft.move             # Rental transaction scripts
│       ├── buy_nft.move              # Purchase transaction scripts
│       └── manage_rentals.move       # Rental management scripts
└── README.md                          # This file
```

## 🏗️ Architecture

### Core Components

1. **NFTMarketplace**: Main contract managing all listings and rentals
2. **NFTListing**: Represents an NFT available for rent/sale
3. **RentalAgreement**: Tracks active rental agreements
4. **MarketplaceCap**: Administrative capability for platform management

### Key Data Structures

```move
public struct NFTListing has store {
    id: ID,
    owner: address,
    renter: Option<address>,
    price: u64,                    // Sale price in SUI
    rental_price: u64,           // Daily rental price in SUI
    duration: u64,               // Rental duration in seconds
    start_time: u64,             // When rental started
    status: ListingStatus,
    listing_type: ListingType,
    nft_id: ID,
    kiosk_id: ID,
    created_at: u64,
}
```

## 🔧 Usage

### 1. Initialization

```move
// Initialize the marketplace
let marketplace = nft_rental_marketplace::init(ctx);
```

### 2. Creating Listings

#### For Both Rent and Sale
```move
nft_rental_marketplace::create_listing(
    &mut marketplace,
    &mut kiosk,
    &kiosk_cap,
    nft_id,
    1000,        // 1000 SUI sale price
    10,          // 10 SUI daily rental price
    86400000,    // 1 day duration in milliseconds
    ListingType::Both,
    &clock,
    ctx
);
```

#### For Rental Only
```move
nft_rental_marketplace::create_listing(
    &mut marketplace,
    &mut kiosk,
    &kiosk_cap,
    nft_id,
    0,           // No sale price
    10,          // 10 SUI daily rental price
    86400000,    // 1 day duration
    ListingType::Rental,
    &clock,
    ctx
);
```

#### For Sale Only
```move
nft_rental_marketplace::create_listing(
    &mut marketplace,
    &mut kiosk,
    &kiosk_cap,
    nft_id,
    1000,        // 1000 SUI sale price
    0,           // No rental price
    0,           // No duration
    ListingType::Sale,
    &clock,
    ctx
);
```

### 3. Renting NFTs

```move
// Create payment coin
let payment = coin::mint_for_testing<SUI>(100, ctx);

// Rent the NFT
nft_rental_marketplace::rent_nft(
    &mut marketplace,
    listing_id,
    payment,
    &clock,
    ctx
);
```

### 4. Buying NFTs

```move
// Create payment coin
let payment = coin::mint_for_testing<SUI>(1000, ctx);

// Buy the NFT
nft_rental_marketplace::buy_nft(
    &mut marketplace,
    listing_id,
    payment,
    &mut kiosk,
    &kiosk_cap,
    ctx
);
```

### 5. Managing Rentals

```move
// Check if rental has expired
nft_rental_marketplace::check_rental_expiry(
    &mut marketplace,
    rental_id,
    &clock,
    ctx
);
```

## 🧪 Testing

The contract includes comprehensive test cases covering:

- NFT listing creation (rental, sale, both)
- Rental process with payment validation
- Rental expiry and automatic return
- NFT purchase with ownership transfer
- Error handling and edge cases
- Utility functions

### Running Tests

```bash
# Run all tests
sui move test

# Run specific test
sui move test test_create_rental_listing
```

## 📊 Events

The contract emits events for all major operations:

- `NFTListed`: When an NFT is listed for rent/sale
- `NFTRented`: When an NFT is rented
- `NFTSold`: When an NFT is sold
- `RentalExpired`: When a rental expires
- `ListingCancelled`: When a listing is cancelled

## 🔒 Security Features

1. **Ownership Validation**: Only NFT owners can create listings
2. **Payment Validation**: Ensures sufficient payment before transactions
3. **Time-based Expiry**: Automatic rental expiration
4. **Kiosk Integration**: Secure NFT management
5. **Reentrancy Protection**: Safe against reentrancy attacks
6. **Access Control**: Proper permission checks for all operations

## 💰 Platform Fees

The marketplace includes a configurable platform fee system:

- Default: 5% platform fee
- Configurable by marketplace administrators
- Applied to both rental and sale transactions

## 🚀 Deployment

### Prerequisites

- Sui CLI installed
- Sui network access (testnet/mainnet)

### Build and Deploy

```bash
# Build the contract
sui move build

# Deploy to testnet
sui client publish --gas-budget 100000000

# Deploy to mainnet
sui client publish --gas-budget 100000000 --network mainnet
```

## 🔄 Integration with Frontend

The smart contract is designed for easy integration with TypeScript/React frontends:

### Key Integration Points

1. **Event Listening**: Monitor contract events for real-time updates
2. **Transaction Scripts**: Use provided scripts for common operations
3. **State Management**: Track listings, rentals, and marketplace state
4. **Error Handling**: Implement proper error handling for all operations

### Example Frontend Integration

```typescript
// Listen for events
const unsubscribe = suiClient.subscribeEvent({
  filter: { Package: marketplacePackageId },
  onMessage: (event) => {
    switch (event.type) {
      case 'NFTListed':
        // Update UI with new listing
        break;
      case 'NFTRented':
        // Update rental status
        break;
      case 'RentalExpired':
        // Handle rental expiry
        break;
    }
  }
});
```

## 📈 Future Enhancements

1. **Bulk Operations**: Batch listing, renting, and purchasing
2. **Advanced Pricing**: Dynamic pricing based on demand
3. **Loyalty System**: Rewards for frequent users
4. **Analytics**: Marketplace statistics and insights
5. **Cross-chain**: Support for other blockchains

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For questions and support:

1. Check the documentation
2. Review test cases for examples
3. Open an issue on GitHub
4. Join the Sui developer community

---

**Built with ❤️ for the Sui ecosystem**
