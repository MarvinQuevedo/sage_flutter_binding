# Sage Flutter API

Typed Dart API generated from Sage's OpenAPI spec. Every method is
available on `SageClient.api` (see `lib/src/sage_api.g.dart`).

```dart
await SageBinding.init();
final sage = await SageClient.newInstance(dataDir: dir);
final res = await sage.api.generateMnemonic(GenerateMnemonic(use24Words: true));
print(res.mnemonic);
```

**105 endpoints**, 224 models, 12 enums.

## Endpoints

### Addresses

#### `checkAddress`

Validate and check an address

| Field | Type | Required | Description |
|---|---|---|---|
| `address` | `String` | yes | Address to validate |

Returns `CheckAddressResponse`.

#### `getDerivations`

Get address derivation information

| Field | Type | Required | Description |
|---|---|---|---|
| `hardened` | `bool` | no | Whether to retrieve hardened derivations |
| `limit` | `int` | yes | Number of derivations to return |
| `offset` | `int` | yes | Starting offset for pagination |

Returns `GetDerivationsResponse`.

#### `increaseDerivationIndex`

Increase the derivation index to generate more addresses

| Field | Type | Required | Description |
|---|---|---|---|
| `hardened` | `bool` | no | Whether to derive hardened addresses (defaults to true if not specified) |
| `index` | `int` | yes | The target derivation index to increase to |
| `unhardened` | `bool` | no | Whether to derive unhardened addresses (defaults to true if not specified) |

Returns `IncreaseDerivationIndexResponse`.

#### `setChangeAddress`

Set the change address for transactions

| Field | Type | Required | Description |
|---|---|---|---|
| `changeAddress` | `String` | no | Change address (null to use default derivation) |
| `fingerprint` | `int` | yes | Wallet fingerprint |

Returns `EmptyResponse`.

### Assets

#### `isAssetOwned`

Check if an asset is owned

| Field | Type | Required | Description |
|---|---|---|---|
| `assetId` | `String` | yes | Asset ID to check |

Returns `IsAssetOwnedResponse`.

### Authentication & Keys

#### `deleteKey`

Delete a wallet key

| Field | Type | Required | Description |
|---|---|---|---|
| `fingerprint` | `int` | yes | Wallet fingerprint to delete |

Returns `DeleteKeyResponse`.

#### `generateMnemonic`

Generate a new mnemonic phrase for wallet creation

| Field | Type | Required | Description |
|---|---|---|---|
| `use24Words` | `bool` | yes | Whether to generate a 24-word mnemonic instead of 12-word |

Returns `GenerateMnemonicResponse`.

#### `getKey`

Get a specific wallet key

| Field | Type | Required | Description |
|---|---|---|---|
| `fingerprint` | `int` | no | Wallet fingerprint (uses currently logged in if null) |

Returns `GetKeyResponse`.

#### `getKeys`

List all wallet keys

_No request fields._

Returns `GetKeysResponse`.

#### `getSecretKey`

Get wallet secret key

| Field | Type | Required | Description |
|---|---|---|---|
| `fingerprint` | `int` | yes | Wallet fingerprint |

Returns `GetSecretKeyResponse`.

#### `importKey`

Import a wallet key

| Field | Type | Required | Description |
|---|---|---|---|
| `derivationIndex` | `int` | no | Starting derivation index |
| `emoji` | `String` | no | Optional emoji identifier |
| `hardened` | `bool` | no | Optional hardened derivation count |
| `key` | `String` | yes | Mnemonic phrase or private key |
| `login` | `bool` | no | Whether to automatically login after import |
| `name` | `String` | yes | Display name for the wallet |
| `saveSecrets` | `bool` | no | Whether to save secrets to keychain |
| `unhardened` | `bool` | no | Optional unhardened derivation count |

Returns `ImportKeyResponse`.

#### `login`

Login to a wallet using a fingerprint

| Field | Type | Required | Description |
|---|---|---|---|
| `fingerprint` | `int` | yes | The unique fingerprint identifier of the wallet to authenticate with. This is a 32-bit unsigned integer that uniquely identifies each wallet key in the system. |

Returns `LoginResponse`.

#### `logout`

Log out of the current wallet session

_No request fields._

Returns `LogoutResponse`.

#### `renameKey`

Rename a wallet key

| Field | Type | Required | Description |
|---|---|---|---|
| `fingerprint` | `int` | yes | Wallet fingerprint |
| `name` | `String` | yes | New display name |

Returns `RenameKeyResponse`.

#### `setWalletEmoji`

Set wallet emoji

| Field | Type | Required | Description |
|---|---|---|---|
| `emoji` | `String` | no | Emoji character (null to remove) |
| `fingerprint` | `int` | yes | Wallet fingerprint |

Returns `SetWalletEmojiResponse`.

### CAT Tokens

#### `autoCombineCat`

Automatically combine CAT coins

| Field | Type | Required | Description |
|---|---|---|---|
| `assetId` | `String` | yes | Asset ID of the CAT |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `maxCoinAmount` | `BigInt` | no |  |
| `maxCoins` | `int` | yes | Maximum number of coins to combine |

Returns `AutoCombineCatResponse`.

#### `bulkSendCat`

Send CAT tokens to multiple addresses

| Field | Type | Required | Description |
|---|---|---|---|
| `addresses` | `List<String>` | yes | List of recipient addresses |
| `amount` | `BigInt` | yes | Amount to send to each address |
| `assetId` | `String` | yes | Asset ID of the CAT |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `includeHint` | `bool` | no | Whether to include the CAT hint |
| `memos` | `List<String>` | no | Optional memos |

Returns `TransactionResponse`.

#### `getAllCats`

Get all known CAT tokens

_No request fields._

Returns `GetAllCatsResponse`.

#### `getCats`

Get CAT tokens in wallet

_No request fields._

Returns `GetCatsResponse`.

#### `getToken`

Get detailed token information

| Field | Type | Required | Description |
|---|---|---|---|
| `assetId` | `String` | no | Asset ID of the token (null for XCH) |

Returns `GetTokenResponse`.

#### `issueCat`

Issue a new CAT token

| Field | Type | Required | Description |
|---|---|---|---|
| `amount` | `BigInt` | yes | Initial supply amount |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `name` | `String` | yes | Token name |
| `ticker` | `String` | yes | Token ticker symbol |

Returns `TransactionResponse`.

#### `resyncCat`

Resynchronize a `CAT` token's metadata from an external source

| Field | Type | Required | Description |
|---|---|---|---|
| `assetId` | `String` | yes | The asset ID of the `CAT` token to resynchronize |

Returns `ResyncCatResponse`.

#### `sendCat`

Send CAT tokens to an address

| Field | Type | Required | Description |
|---|---|---|---|
| `address` | `String` | yes | Recipient address |
| `amount` | `BigInt` | yes | Amount to send |
| `assetId` | `String` | yes | Asset ID of the CAT |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `clawback` | `int` | no | Optional clawback timestamp |
| `fee` | `BigInt` | yes | Transaction fee |
| `includeHint` | `bool` | no | Whether to include the CAT hint |
| `memos` | `List<String>` | no | Optional memos |

Returns `TransactionResponse`.

#### `updateCat`

Update a `CAT` token's metadata and visibility

| Field | Type | Required | Description |
|---|---|---|---|
| `record` | `TokenRecord` | yes | The token record containing updated metadata |

Returns `UpdateCatResponse`.

### Coins

#### `getAreCoinsSpendable`

Check if specific coins are spendable

| Field | Type | Required | Description |
|---|---|---|---|
| `coinIds` | `List<String>` | yes | List of coin IDs to check |

Returns `GetAreCoinsSpendableResponse`.

#### `getCoins`

List coins with filtering and pagination

| Field | Type | Required | Description |
|---|---|---|---|
| `ascending` | `bool` | no | Sort in ascending order |
| `assetId` | `String` | no | Optional asset ID to filter by |
| `filterMode` | `CoinFilterMode` | no | Filter mode |
| `limit` | `int` | yes | Number of coins to return |
| `offset` | `int` | yes | Starting offset for pagination |
| `sortMode` | `CoinSortMode` | no | Sort mode |

Returns `GetCoinsResponse`.

#### `getCoinsByIds`

Retrieve specific coins by their IDs

| Field | Type | Required | Description |
|---|---|---|---|
| `coinIds` | `List<String>` | yes | List of coin IDs to retrieve |

Returns `GetCoinsByIdsResponse`.

#### `getSpendableCoinCount`

Get the count of spendable coins

| Field | Type | Required | Description |
|---|---|---|---|
| `assetId` | `String` | no | Optional asset ID to filter by (null for XCH) |

Returns `GetSpendableCoinCountResponse`.

### DIDs

#### `createDid`

Create a new DID

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `name` | `String` | yes | DID name |

Returns `TransactionResponse`.

#### `getDids`

List all DIDs in the wallet

_No request fields._

Returns `GetDidsResponse`.

#### `getMinterDidIds`

Get minter DIDs with pagination

| Field | Type | Required | Description |
|---|---|---|---|
| `limit` | `int` | yes | Number of DID IDs to return |
| `offset` | `int` | yes | Starting offset for pagination |

Returns `GetMinterDidIdsResponse`.

#### `normalizeDids`

Normalize DIDs to latest state

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `didIds` | `List<String>` | yes | DID IDs to normalize |
| `fee` | `BigInt` | yes | Transaction fee |

Returns `TransactionResponse`.

#### `transferDids`

Transfer DIDs to a new address

| Field | Type | Required | Description |
|---|---|---|---|
| `address` | `String` | yes | Recipient address |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `clawback` | `int` | no | Optional clawback timestamp |
| `didIds` | `List<String>` | yes | DID IDs to transfer |
| `fee` | `BigInt` | yes | Transaction fee |

Returns `TransactionResponse`.

#### `updateDid`

Update a `DID`'s name and visibility settings

| Field | Type | Required | Description |
|---|---|---|---|
| `didId` | `String` | yes | The `DID` ID to update |
| `name` | `String` | no | Optional new name for the `DID` |
| `visible` | `bool` | yes | Whether the `DID` should be visible in the UI |

Returns `UpdateDidResponse`.

### NFTs

#### `addNftUri`

Add a URI to an NFT

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `kind` | `NftUriKind` | yes | Type of URI |
| `nftId` | `String` | yes | NFT ID |
| `uri` | `String` | yes | URI to add |

Returns `TransactionResponse`.

#### `assignNftsToDid`

Assign NFTs to a DID

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `didId` | `String` | no | DID ID (null to unassign) |
| `fee` | `BigInt` | yes | Transaction fee |
| `nftIds` | `List<String>` | yes | NFT IDs to assign |

Returns `TransactionResponse`.

#### `bulkMintNfts`

Mint multiple NFTs in one transaction

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `didId` | `String` | yes | DID ID for the NFT collection |
| `fee` | `BigInt` | yes | Transaction fee |
| `mints` | `List<NftMint>` | yes | List of NFTs to mint |

Returns `BulkMintNftsResponse`.

#### `getNft`

Get a specific NFT

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | NFT coin ID |

Returns `GetNftResponse`.

#### `getNftCollection`

Get a specific NFT collection

| Field | Type | Required | Description |
|---|---|---|---|
| `collectionId` | `String` | no | Collection ID (null for uncollected NFTs) |

Returns `GetNftCollectionResponse`.

#### `getNftCollections`

List NFT collections

| Field | Type | Required | Description |
|---|---|---|---|
| `includeHidden` | `bool` | yes | Include hidden collections |
| `limit` | `int` | yes | Number of collections to return |
| `offset` | `int` | yes | Starting offset for pagination |

Returns `GetNftCollectionsResponse`.

#### `getNftData`

Get NFT data file

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | NFT coin ID |

Returns `GetNftDataResponse`.

#### `getNftIcon`

Get NFT icon image

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | NFT coin ID |

Returns `GetNftIconResponse`.

#### `getNftThumbnail`

Get NFT thumbnail image

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | NFT coin ID |

Returns `GetNftThumbnailResponse`.

#### `getNfts`

List NFTs with filtering

| Field | Type | Required | Description |
|---|---|---|---|
| `collectionId` | `String` | no | Filter by collection ID |
| `includeHidden` | `bool` | yes | Include hidden NFTs |
| `limit` | `int` | yes | Number of NFTs to return |
| `minterDidId` | `String` | no | Filter by minter DID |
| `name` | `String` | no | Filter by name search |
| `offset` | `int` | yes | Starting offset for pagination |
| `ownerDidId` | `String` | no | Filter by owner DID |
| `sortMode` | `NftSortMode` | yes | Sort mode |

Returns `GetNftsResponse`.

#### `redownloadNft`

Re-download an `NFT`'s data and metadata from its URIs

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | The `NFT` ID to re-download |

Returns `RedownloadNftResponse`.

#### `transferNfts`

Transfer NFTs to a new owner

| Field | Type | Required | Description |
|---|---|---|---|
| `address` | `String` | yes | Recipient address |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `clawback` | `int` | no | Optional clawback timestamp |
| `fee` | `BigInt` | yes | Transaction fee |
| `nftIds` | `List<String>` | yes | NFT IDs to transfer |

Returns `TransactionResponse`.

#### `updateNft`

Update an `NFT`'s visibility settings

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | The `NFT` ID to update |
| `visible` | `bool` | yes | Whether the `NFT` should be visible in the UI |

Returns `UpdateNftResponse`.

#### `updateNftCollection`

Update an `NFT` collection's visibility settings

| Field | Type | Required | Description |
|---|---|---|---|
| `collectionId` | `String` | yes | The collection ID to update |
| `visible` | `bool` | yes | Whether the collection should be visible in the UI |

Returns `UpdateNftCollectionResponse`.

### Network Settings

#### `getNetwork`

Get current network information

_No request fields._

Returns `None`.

#### `getNetworks`

List available networks

_No request fields._

Returns `None`.

#### `setDeltaSync`

Enable or disable delta sync

| Field | Type | Required | Description |
|---|---|---|---|
| `deltaSync` | `bool` | yes | Whether to enable delta sync |

Returns `EmptyResponse`.

#### `setDeltaSyncOverride`

Override delta sync settings for a specific wallet

| Field | Type | Required | Description |
|---|---|---|---|
| `deltaSync` | `bool` | no | Delta sync setting (null to use default) |
| `fingerprint` | `int` | yes | Wallet fingerprint |

Returns `EmptyResponse`.

#### `setNetwork`

Set the active network

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | `String` | yes | Network name to switch to |

Returns `EmptyResponse`.

#### `setNetworkOverride`

Override network settings for a specific wallet

| Field | Type | Required | Description |
|---|---|---|---|
| `fingerprint` | `int` | yes | Wallet fingerprint to override network for |
| `name` | `String` | no | Network name (null to reset to default) |

Returns `EmptyResponse`.

### Offers

#### `cancelOffer`

Cancel an offer on-chain

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `offerId` | `String` | yes | Offer ID to cancel |

Returns `TransactionResponse`.

#### `cancelOffers`

Cancel multiple offers

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `offerIds` | `List<String>` | yes | Offer IDs to cancel |

Returns `TransactionResponse`.

#### `combineOffers`

Combine multiple offers

| Field | Type | Required | Description |
|---|---|---|---|
| `offers` | `List<String>` | yes | Offer strings to combine |

Returns `CombineOffersResponse`.

#### `deleteOffer`

Delete an offer

| Field | Type | Required | Description |
|---|---|---|---|
| `offerId` | `String` | yes | Offer ID to delete |

Returns `DeleteOfferResponse`.

#### `getOffer`

Get a specific offer

| Field | Type | Required | Description |
|---|---|---|---|
| `offerId` | `String` | yes | Offer ID |

Returns `GetOfferResponse`.

#### `getOffers`

List all offers

_No request fields._

Returns `GetOffersResponse`.

#### `getOffersForAsset`

Get offers for a specific asset

| Field | Type | Required | Description |
|---|---|---|---|
| `assetId` | `String` | yes | Asset ID to filter by |

Returns `GetOffersForAssetResponse`.

#### `importOffer`

Import an offer

| Field | Type | Required | Description |
|---|---|---|---|
| `offer` | `String` | yes | Offer string to import |

Returns `ImportOfferResponse`.

#### `makeOffer`

Create a new offer

| Field | Type | Required | Description |
|---|---|---|---|
| `autoImport` | `bool` | no | Whether to automatically import the offer |
| `coinIds` | `List<String>` | no | Optional specific coin IDs to use for the offer instead of auto-selecting |
| `expiresAtSecond` | `int` | no | Optional expiration timestamp |
| `fee` | `BigInt` | yes | Transaction fee |
| `offeredAssets` | `List<OfferAmount>` | yes | Assets offered in exchange |
| `receiveAddress` | `String` | no | Optional receive address |
| `requestedAssets` | `List<OfferAmount>` | yes | Assets requested in the offer |

Returns `MakeOfferResponse`.

#### `takeOffer`

Accept an offer

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `offer` | `String` | yes | Offer string to accept |

Returns `TakeOfferResponse`.

#### `viewOffer`

View an offer without accepting

| Field | Type | Required | Description |
|---|---|---|---|
| `offer` | `String` | yes | Offer string to view |

Returns `ViewOfferResponse`.

### Options

#### `exerciseOptions`

Exercise options

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `optionIds` | `List<String>` | yes | Option IDs to exercise |

Returns `TransactionResponse`.

#### `getOption`

Get a specific option

| Field | Type | Required | Description |
|---|---|---|---|
| `optionId` | `String` | yes | Option ID |

Returns `GetOptionResponse`.

#### `getOptions`

List options with filtering

| Field | Type | Required | Description |
|---|---|---|---|
| `ascending` | `bool` | no | Sort in ascending order |
| `findValue` | `String` | no | Optional search value |
| `includeHidden` | `bool` | no | Include hidden options |
| `limit` | `int` | yes | Number of options to return |
| `offset` | `int` | yes | Starting offset for pagination |
| `sortMode` | `OptionSortMode` | no | Sort mode |

Returns `GetOptionsResponse`.

#### `mintOption`

Mint a new option

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `expirationSeconds` | `int` | yes | Expiration time in seconds |
| `fee` | `BigInt` | yes | Transaction fee |
| `strike` | `OptionAsset` | yes | Strike price asset |
| `underlying` | `OptionAsset` | yes | Underlying asset |

Returns `MintOptionResponse`.

#### `transferOptions`

Transfer options to another address

| Field | Type | Required | Description |
|---|---|---|---|
| `address` | `String` | yes | Recipient address |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `clawback` | `int` | no | Optional clawback timestamp |
| `fee` | `BigInt` | yes | Transaction fee |
| `optionIds` | `List<String>` | yes | Option IDs to transfer |

Returns `TransactionResponse`.

#### `updateOption`

Update an option's visibility settings

| Field | Type | Required | Description |
|---|---|---|---|
| `optionId` | `String` | yes | The option ID to update |
| `visible` | `bool` | yes | Whether the option should be visible in the UI |

Returns `UpdateOptionResponse`.

### Peers

#### `addPeer`

Add a new peer to connect to

| Field | Type | Required | Description |
|---|---|---|---|
| `ip` | `String` | yes | IP address or hostname with port |

Returns `EmptyResponse`.

#### `getPeers`

List all network peers

_No request fields._

Returns `GetPeersResponse`.

#### `removePeer`

Remove a peer from the connection list

| Field | Type | Required | Description |
|---|---|---|---|
| `ban` | `bool` | yes | Whether to ban the peer from reconnecting |
| `ip` | `String` | yes | IP address or hostname of the peer |

Returns `EmptyResponse`.

#### `setDiscoverPeers`

Enable or disable automatic peer discovery

| Field | Type | Required | Description |
|---|---|---|---|
| `discoverPeers` | `bool` | yes | Whether to enable peer discovery |

Returns `EmptyResponse`.

#### `setTargetPeers`

Set target number of peers to maintain

| Field | Type | Required | Description |
|---|---|---|---|
| `targetPeers` | `int` | yes | Target number of peer connections |

Returns `EmptyResponse`.

### System & Sync

#### `deleteDatabase`

Delete a wallet database

| Field | Type | Required | Description |
|---|---|---|---|
| `fingerprint` | `int` | yes | Wallet fingerprint |
| `network` | `String` | yes | Network name |

Returns `DeleteDatabaseResponse`.

#### `getDatabaseStats`

Retrieve database statistics

_No request fields._

Returns `GetDatabaseStatsResponse`.

#### `getSyncStatus`

Get the current synchronization status

_No request fields._

Returns `GetSyncStatusResponse`.

#### `getVersion`

Get the wallet version

_No request fields._

Returns `GetVersionResponse`.

#### `performDatabaseMaintenance`

Perform database maintenance operations

| Field | Type | Required | Description |
|---|---|---|---|
| `forceVacuum` | `bool` | yes | Whether to force a full vacuum (may take longer) |

Returns `PerformDatabaseMaintenanceResponse`.

#### `resync`

Resynchronize wallet data with the blockchain

| Field | Type | Required | Description |
|---|---|---|---|
| `deleteAddresses` | `bool` | no | Delete all address records during resync |
| `deleteAssets` | `bool` | no | Delete all asset records during resync |
| `deleteBlocks` | `bool` | no | Delete all block records during resync |
| `deleteCoins` | `bool` | no | Delete all coin records during resync |
| `deleteFiles` | `bool` | no | Delete all file records during resync |
| `deleteOffers` | `bool` | no | Delete all offer records during resync |
| `fingerprint` | `int` | yes | The fingerprint of the wallet to resync |

Returns `ResyncResponse`.

### Themes

#### `deleteUserTheme`

Delete a theme NFT from the wallet

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | NFT ID of the theme |

Returns `DeleteUserThemeResponse`.

#### `getUserTheme`

Get a specific theme NFT

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | NFT ID of the theme |

Returns `GetUserThemeResponse`.

#### `getUserThemes`

List all custom theme NFTs

_No request fields._

Returns `GetUserThemesResponse`.

#### `saveUserTheme`

Save a theme NFT to the wallet

| Field | Type | Required | Description |
|---|---|---|---|
| `nftId` | `String` | yes | NFT ID of the theme |

Returns `SaveUserThemeResponse`.

### Transactions

#### `createTransaction`

create_transaction

| Field | Type | Required | Description |
|---|---|---|---|
| `actions` | `List<Map<String, dynamic>>` | yes | The list of actions to perform in the transaction |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `selectedCoinIds` | `List<String>` | no | Pre-selected coins to use in the transaction prior to coin selection |

Returns `TransactionResponse`.

#### `getPendingTransactions`

Get pending transactions

_No request fields._

Returns `GetPendingTransactionsResponse`.

#### `getTransaction`

Get a specific transaction by height

| Field | Type | Required | Description |
|---|---|---|---|
| `height` | `int` | yes | Transaction height/ID |

Returns `GetTransactionResponse`.

#### `getTransactions`

List transactions with filtering

| Field | Type | Required | Description |
|---|---|---|---|
| `ascending` | `bool` | yes | Sort in ascending order |
| `findValue` | `String` | no | Optional search value |
| `limit` | `int` | yes | Number of transactions to return |
| `offset` | `int` | yes | Starting offset for pagination |

Returns `GetTransactionsResponse`.

#### `signCoinSpends`

Sign coin spends to create a transaction

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `coinSpends` | `List<CoinSpendJson>` | yes | Coin spends to sign |
| `partial` | `bool` | no | Whether to partially sign (for multi-signature) |

Returns `SignCoinSpendsResponse`.

#### `submitTransaction`

Submit a transaction to the network

| Field | Type | Required | Description |
|---|---|---|---|
| `spendBundle` | `SpendBundleJson` | yes | Spend bundle to submit |

Returns `SubmitTransactionResponse`.

#### `viewCoinSpends`

View coin spends without signing

| Field | Type | Required | Description |
|---|---|---|---|
| `coinSpends` | `List<CoinSpendJson>` | yes | Coin spends to view |

Returns `ViewCoinSpendsResponse`.

### WalletConnect

#### `filterUnlockedCoins`

Filter unlocked coins from a list

| Field | Type | Required | Description |
|---|---|---|---|
| `coinIds` | `List<String>` | yes | Coin IDs to filter |

Returns `FilterUnlockedCoinsResponse`.

#### `getAssetCoins`

Get spendable coins for an asset

| Field | Type | Required | Description |
|---|---|---|---|
| `assetId` | `String` | no | Asset ID to filter by |
| `includedLocked` | `bool` | no | Whether to include locked coins |
| `limit` | `int` | no | Number of results to return |
| `offset` | `int` | no | Pagination offset |
| `type` | `AssetCoinType` | no |  |

Returns `GetAssetCoinsResponse`.

#### `sendTransactionImmediately`

Send a transaction immediately

| Field | Type | Required | Description |
|---|---|---|---|
| `spendBundle` | `SpendBundle` | yes | Spend bundle to send |

Returns `SendTransactionImmediatelyResponse`.

#### `signMessageByAddress`

Sign a message by address

| Field | Type | Required | Description |
|---|---|---|---|
| `address` | `String` | yes | Address whose key to use |
| `message` | `String` | yes | Message to sign |

Returns `SignMessageByAddressResponse`.

#### `signMessageWithPublicKey`

Sign a message with a public key

| Field | Type | Required | Description |
|---|---|---|---|
| `message` | `String` | yes | Message to sign |
| `publicKey` | `String` | yes | Public key to use for signing |

Returns `SignMessageWithPublicKeyResponse`.

### XCH Transactions

#### `autoCombineXch`

Automatically combine XCH coins

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `maxCoinAmount` | `BigInt` | no |  |
| `maxCoins` | `int` | yes | Maximum number of coins to combine |

Returns `AutoCombineXchResponse`.

#### `bulkSendXch`

Send XCH to multiple addresses

| Field | Type | Required | Description |
|---|---|---|---|
| `addresses` | `List<String>` | yes | List of recipient addresses |
| `amount` | `BigInt` | yes | Amount to send to each address |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `memos` | `List<String>` | no | Optional memos |

Returns `TransactionResponse`.

#### `combine`

Combine multiple coins into one

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `coinIds` | `List<String>` | yes | Coin IDs to combine |
| `fee` | `BigInt` | yes | Transaction fee |

Returns `TransactionResponse`.

#### `finalizeClawback`

Send CAT tokens to an address

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `coinIds` | `List<String>` | yes | The coins to finalize the clawback for |
| `fee` | `BigInt` | yes | Transaction fee |

Returns `TransactionResponse`.

#### `multiSend`

Send multiple assets in one transaction

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `fee` | `BigInt` | yes | Transaction fee |
| `payments` | `List<Payment>` | yes | List of payments to make |

Returns `TransactionResponse`.

#### `sendXch`

Send XCH to an address

| Field | Type | Required | Description |
|---|---|---|---|
| `address` | `String` | yes | Recipient address |
| `amount` | `BigInt` | yes | Amount to send |
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `clawback` | `int` | no | Optional clawback timestamp (seconds since epoch) |
| `fee` | `BigInt` | yes | Transaction fee |
| `memos` | `List<String>` | no | Optional memos |

Returns `TransactionResponse`.

#### `split`

Split coins into multiple smaller coins

| Field | Type | Required | Description |
|---|---|---|---|
| `autoSubmit` | `bool` | no | Whether to automatically submit the transaction |
| `coinIds` | `List<String>` | yes | Coin IDs to split |
| `fee` | `BigInt` | yes | Transaction fee |
| `outputCount` | `int` | yes | Number of output coins |

Returns `TransactionResponse`.

