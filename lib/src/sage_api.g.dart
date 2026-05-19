// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: tool/generate_api.sh
// Source: Sage OpenAPI spec (vendored Sage @ 0.12.10).
// ignore_for_file: type=lint, unused_element, prefer_const_constructors

import 'rust/api/sage_client.dart';
import 'sage_client_ext.dart';

enum AddressKind {
  own('own'),
  burn('burn'),
  launcher('launcher'),
  offer('offer'),
  external_('external'),
  unknown('unknown');

  const AddressKind(this.value);
  final String value;

  factory AddressKind.fromJson(String v) =>
      AddressKind.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum AssetKind {
  token('token'),
  nft('nft'),
  did('did'),
  option('option');

  const AssetKind(this.value);
  final String value;

  factory AssetKind.fromJson(String v) =>
      AssetKind.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum CoinFilterMode {
  all('all'),
  selectable('selectable'),
  owned('owned'),
  spent('spent'),
  clawback('clawback');

  const CoinFilterMode(this.value);
  final String value;

  factory CoinFilterMode.fromJson(String v) =>
      CoinFilterMode.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum CoinSortMode {
  coinId('coin_id'),
  amount('amount'),
  createdHeight('created_height'),
  spentHeight('spent_height'),
  clawbackTimestamp('clawback_timestamp');

  const CoinSortMode(this.value);
  final String value;

  factory CoinSortMode.fromJson(String v) =>
      CoinSortMode.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum KeyKind {
  bls('bls');

  const KeyKind(this.value);
  final String value;

  factory KeyKind.fromJson(String v) =>
      KeyKind.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum NetworkKind {
  mainnet('mainnet'),
  testnet('testnet'),
  unknown('unknown');

  const NetworkKind(this.value);
  final String value;

  factory NetworkKind.fromJson(String v) =>
      NetworkKind.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum NftSortMode {
  name('name'),
  recent('recent');

  const NftSortMode(this.value);
  final String value;

  factory NftSortMode.fromJson(String v) =>
      NftSortMode.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum NftSpecialUseType {
  none('none'),
  theme('theme');

  const NftSpecialUseType(this.value);
  final String value;

  factory NftSpecialUseType.fromJson(String v) =>
      NftSpecialUseType.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum NftUriKind {
  data('data'),
  metadata('metadata'),
  license('license');

  const NftUriKind(this.value);
  final String value;

  factory NftUriKind.fromJson(String v) =>
      NftUriKind.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum OfferRecordStatus {
  pending('pending'),
  active('active'),
  completed('completed'),
  cancelled('cancelled'),
  expired('expired');

  const OfferRecordStatus(this.value);
  final String value;

  factory OfferRecordStatus.fromJson(String v) =>
      OfferRecordStatus.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

enum OptionSortMode {
  name('name'),
  createdHeight('created_height'),
  expirationSeconds('expiration_seconds');

  const OptionSortMode(this.value);
  final String value;

  factory OptionSortMode.fromJson(String v) =>
      OptionSortMode.values.firstWhere((e) => e.value == v);
  String toJson() => value;
}

/// Add a URI to an NFT
class AddNftUri {
  AddNftUri({
    this.autoSubmit,
    required this.fee,
    required this.kind,
    required this.nftId,
    required this.uri,
  });

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Type of URI
  final NftUriKind kind;

  /// NFT ID
  final String nftId;

  /// URI to add
  final String uri;

  factory AddNftUri.fromJson(Map<String, dynamic> json) => AddNftUri(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    kind: NftUriKind.fromJson(json['kind'] as String),
    nftId: json['nft_id'] as String,
    uri: json['uri'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'kind': kind.toJson(),
    'nft_id': nftId,
    'uri': uri,
  };
}

/// Add a new peer to connect to
class AddPeer {
  AddPeer({required this.ip});

  /// IP address or hostname with port
  final String ip;

  factory AddPeer.fromJson(Map<String, dynamic> json) =>
      AddPeer(ip: json['ip'] as String);

  Map<String, dynamic> toJson() => {'ip': ip};
}

class Asset {
  Asset({
    this.assetId,
    this.description,
    this.iconUrl,
    required this.isSensitiveContent,
    required this.isVisible,
    required this.kind,
    this.name,
    required this.precision,
    this.revocationAddress,
    this.ticker,
  });

  final String? assetId;

  final String? description;

  final String? iconUrl;

  final bool isSensitiveContent;

  final bool isVisible;

  final AssetKind kind;

  final String? name;

  final int precision;

  final String? revocationAddress;

  final String? ticker;

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
    description: json['description'] == null
        ? null
        : (json['description'] as String),
    iconUrl: json['icon_url'] == null ? null : (json['icon_url'] as String),
    isSensitiveContent: json['is_sensitive_content'] as bool,
    isVisible: json['is_visible'] as bool,
    kind: AssetKind.fromJson(json['kind'] as String),
    name: json['name'] == null ? null : (json['name'] as String),
    precision: json['precision'] as int,
    revocationAddress: json['revocation_address'] == null
        ? null
        : (json['revocation_address'] as String),
    ticker: json['ticker'] == null ? null : (json['ticker'] as String),
  );

  Map<String, dynamic> toJson() => {
    if (assetId != null) 'asset_id': assetId,
    if (description != null) 'description': description,
    if (iconUrl != null) 'icon_url': iconUrl,
    'is_sensitive_content': isSensitiveContent,
    'is_visible': isVisible,
    'kind': kind.toJson(),
    if (name != null) 'name': name,
    'precision': precision,
    if (revocationAddress != null) 'revocation_address': revocationAddress,
    if (ticker != null) 'ticker': ticker,
  };
}

/// Assign NFTs to a DID
class AssignNftsToDid {
  AssignNftsToDid({
    this.autoSubmit,
    this.didId,
    required this.fee,
    required this.nftIds,
  });

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// DID ID (null to unassign)
  final String? didId;

  /// Transaction fee
  final BigInt fee;

  /// NFT IDs to assign
  final List<String> nftIds;

  factory AssignNftsToDid.fromJson(Map<String, dynamic> json) =>
      AssignNftsToDid(
        autoSubmit: json['auto_submit'] == null
            ? null
            : (json['auto_submit'] as bool),
        didId: json['did_id'] == null ? null : (json['did_id'] as String),
        fee: ((json['fee']) is String
            ? BigInt.parse(json['fee'] as String)
            : BigInt.from((json['fee'] as num).toInt())),
        nftIds: ((json['nft_ids']) as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    if (didId != null) 'did_id': didId,
    'fee': fee.toString(),
    'nft_ids': nftIds,
  };
}

/// Automatically combine CAT coins
class AutoCombineCat {
  AutoCombineCat({
    required this.assetId,
    this.autoSubmit,
    required this.fee,
    this.maxCoinAmount,
    required this.maxCoins,
  });

  /// Asset ID of the CAT
  final String assetId;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  final BigInt? maxCoinAmount;

  /// Maximum number of coins to combine
  final int maxCoins;

  factory AutoCombineCat.fromJson(Map<String, dynamic> json) => AutoCombineCat(
    assetId: json['asset_id'] as String,
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    maxCoinAmount: json['max_coin_amount'] == null
        ? null
        : (((json['max_coin_amount']) is String
              ? BigInt.parse(json['max_coin_amount'] as String)
              : BigInt.from((json['max_coin_amount'] as num).toInt()))),
    maxCoins: json['max_coins'] as int,
  );

  Map<String, dynamic> toJson() => {
    'asset_id': assetId,
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    if (maxCoinAmount != null) 'max_coin_amount': maxCoinAmount!.toString(),
    'max_coins': maxCoins,
  };
}

/// Response for auto-combine CAT
class AutoCombineCatResponse {
  AutoCombineCatResponse({
    required this.coinIds,
    required this.coinSpends,
    required this.summary,
  });

  /// Combined coin IDs
  final List<String> coinIds;

  /// Coin spends in the transaction
  final List<CoinSpendJson> coinSpends;

  /// Transaction summary
  final TransactionSummary summary;

  factory AutoCombineCatResponse.fromJson(Map<String, dynamic> json) =>
      AutoCombineCatResponse(
        coinIds: ((json['coin_ids']) as List).cast<String>(),
        coinSpends: ((json['coin_spends']) as List)
            .map(
              (e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
        summary: TransactionSummary.fromJson(
          (json['summary'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {
    'coin_ids': coinIds,
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
  };
}

/// Automatically combine XCH coins
class AutoCombineXch {
  AutoCombineXch({
    this.autoSubmit,
    required this.fee,
    this.maxCoinAmount,
    required this.maxCoins,
  });

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  final BigInt? maxCoinAmount;

  /// Maximum number of coins to combine
  final int maxCoins;

  factory AutoCombineXch.fromJson(Map<String, dynamic> json) => AutoCombineXch(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    maxCoinAmount: json['max_coin_amount'] == null
        ? null
        : (((json['max_coin_amount']) is String
              ? BigInt.parse(json['max_coin_amount'] as String)
              : BigInt.from((json['max_coin_amount'] as num).toInt()))),
    maxCoins: json['max_coins'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    if (maxCoinAmount != null) 'max_coin_amount': maxCoinAmount!.toString(),
    'max_coins': maxCoins,
  };
}

/// Response for auto-combine XCH
class AutoCombineXchResponse {
  AutoCombineXchResponse({
    required this.coinIds,
    required this.coinSpends,
    required this.summary,
  });

  /// Combined coin IDs
  final List<String> coinIds;

  /// Coin spends in the transaction
  final List<CoinSpendJson> coinSpends;

  /// Transaction summary
  final TransactionSummary summary;

  factory AutoCombineXchResponse.fromJson(Map<String, dynamic> json) =>
      AutoCombineXchResponse(
        coinIds: ((json['coin_ids']) as List).cast<String>(),
        coinSpends: ((json['coin_spends']) as List)
            .map(
              (e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
        summary: TransactionSummary.fromJson(
          (json['summary'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {
    'coin_ids': coinIds,
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
  };
}

/// Mint multiple NFTs in one transaction
class BulkMintNfts {
  BulkMintNfts({
    this.autoSubmit,
    required this.didId,
    required this.fee,
    required this.mints,
  });

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// DID ID for the NFT collection
  final String didId;

  /// Transaction fee
  final BigInt fee;

  /// List of NFTs to mint
  final List<NftMint> mints;

  factory BulkMintNfts.fromJson(Map<String, dynamic> json) => BulkMintNfts(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    didId: json['did_id'] as String,
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    mints: ((json['mints']) as List)
        .map((e) => NftMint.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'did_id': didId,
    'fee': fee.toString(),
    'mints': mints.map((e) => e.toJson()).toList(),
  };
}

/// Response for bulk NFT minting
class BulkMintNftsResponse {
  BulkMintNftsResponse({
    required this.coinSpends,
    required this.nftIds,
    required this.summary,
  });

  /// Coin spends in the transaction
  final List<CoinSpendJson> coinSpends;

  /// List of minted NFT IDs
  final List<String> nftIds;

  /// Transaction summary
  final TransactionSummary summary;

  factory BulkMintNftsResponse.fromJson(Map<String, dynamic> json) =>
      BulkMintNftsResponse(
        coinSpends: ((json['coin_spends']) as List)
            .map(
              (e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
        nftIds: ((json['nft_ids']) as List).cast<String>(),
        summary: TransactionSummary.fromJson(
          (json['summary'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
    'nft_ids': nftIds,
    'summary': summary.toJson(),
  };
}

/// Send CAT tokens to multiple addresses
class BulkSendCat {
  BulkSendCat({
    required this.addresses,
    required this.amount,
    required this.assetId,
    this.autoSubmit,
    required this.fee,
    this.includeHint,
    this.memos,
  });

  /// List of recipient addresses
  final List<String> addresses;

  /// Amount to send to each address
  final BigInt amount;

  /// Asset ID of the CAT
  final String assetId;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Whether to include the CAT hint
  final bool? includeHint;

  /// Optional memos
  final List<String>? memos;

  factory BulkSendCat.fromJson(Map<String, dynamic> json) => BulkSendCat(
    addresses: ((json['addresses']) as List).cast<String>(),
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    assetId: json['asset_id'] as String,
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    includeHint: json['include_hint'] == null
        ? null
        : (json['include_hint'] as bool),
    memos: json['memos'] == null
        ? null
        : (((json['memos']) as List).cast<String>()),
  );

  Map<String, dynamic> toJson() => {
    'addresses': addresses,
    'amount': amount.toString(),
    'asset_id': assetId,
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    if (includeHint != null) 'include_hint': includeHint,
    if (memos != null) 'memos': memos,
  };
}

/// Send XCH to multiple addresses
class BulkSendXch {
  BulkSendXch({
    required this.addresses,
    required this.amount,
    this.autoSubmit,
    required this.fee,
    this.memos,
  });

  /// List of recipient addresses
  final List<String> addresses;

  /// Amount to send to each address
  final BigInt amount;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Optional memos
  final List<String>? memos;

  factory BulkSendXch.fromJson(Map<String, dynamic> json) => BulkSendXch(
    addresses: ((json['addresses']) as List).cast<String>(),
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    memos: json['memos'] == null
        ? null
        : (((json['memos']) as List).cast<String>()),
  );

  Map<String, dynamic> toJson() => {
    'addresses': addresses,
    'amount': amount.toString(),
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    if (memos != null) 'memos': memos,
  };
}

/// Cancel an offer on-chain
class CancelOffer {
  CancelOffer({this.autoSubmit, required this.fee, required this.offerId});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Offer ID to cancel
  final String offerId;

  factory CancelOffer.fromJson(Map<String, dynamic> json) => CancelOffer(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    offerId: json['offer_id'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'offer_id': offerId,
  };
}

/// Cancel multiple offers
class CancelOffers {
  CancelOffers({this.autoSubmit, required this.fee, required this.offerIds});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Offer IDs to cancel
  final List<String> offerIds;

  factory CancelOffers.fromJson(Map<String, dynamic> json) => CancelOffers(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    offerIds: ((json['offer_ids']) as List).cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'offer_ids': offerIds,
  };
}

/// Validate and check an address
class CheckAddress {
  CheckAddress({required this.address});

  /// Address to validate
  final String address;

  factory CheckAddress.fromJson(Map<String, dynamic> json) =>
      CheckAddress(address: json['address'] as String);

  Map<String, dynamic> toJson() => {'address': address};
}

/// Response with address validation result
class CheckAddressResponse {
  CheckAddressResponse({required this.valid});

  /// Whether the address is valid and belongs to this wallet
  final bool valid;

  factory CheckAddressResponse.fromJson(Map<String, dynamic> json) =>
      CheckAddressResponse(valid: json['valid'] as bool);

  Map<String, dynamic> toJson() => {'valid': valid};
}

class CoinJson {
  CoinJson({
    required this.amount,
    required this.parentCoinInfo,
    required this.puzzleHash,
  });

  final BigInt amount;

  final String parentCoinInfo;

  final String puzzleHash;

  factory CoinJson.fromJson(Map<String, dynamic> json) => CoinJson(
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    parentCoinInfo: json['parent_coin_info'] as String,
    puzzleHash: json['puzzle_hash'] as String,
  );

  Map<String, dynamic> toJson() => {
    'amount': amount.toString(),
    'parent_coin_info': parentCoinInfo,
    'puzzle_hash': puzzleHash,
  };
}

class CoinRecord {
  CoinRecord({
    required this.address,
    required this.amount,
    this.clawbackTimestamp,
    required this.coinId,
    this.createdHeight,
    this.createdTimestamp,
    this.offerId,
    this.spentHeight,
    this.spentTimestamp,
    this.transactionId,
  });

  final String address;

  final BigInt amount;

  final int? clawbackTimestamp;

  final String coinId;

  final int? createdHeight;

  final int? createdTimestamp;

  final String? offerId;

  final int? spentHeight;

  final int? spentTimestamp;

  final String? transactionId;

  factory CoinRecord.fromJson(Map<String, dynamic> json) => CoinRecord(
    address: json['address'] as String,
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    clawbackTimestamp: json['clawback_timestamp'] == null
        ? null
        : (json['clawback_timestamp'] as int),
    coinId: json['coin_id'] as String,
    createdHeight: json['created_height'] == null
        ? null
        : (json['created_height'] as int),
    createdTimestamp: json['created_timestamp'] == null
        ? null
        : (json['created_timestamp'] as int),
    offerId: json['offer_id'] == null ? null : (json['offer_id'] as String),
    spentHeight: json['spent_height'] == null
        ? null
        : (json['spent_height'] as int),
    spentTimestamp: json['spent_timestamp'] == null
        ? null
        : (json['spent_timestamp'] as int),
    transactionId: json['transaction_id'] == null
        ? null
        : (json['transaction_id'] as String),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    if (clawbackTimestamp != null) 'clawback_timestamp': clawbackTimestamp,
    'coin_id': coinId,
    if (createdHeight != null) 'created_height': createdHeight,
    if (createdTimestamp != null) 'created_timestamp': createdTimestamp,
    if (offerId != null) 'offer_id': offerId,
    if (spentHeight != null) 'spent_height': spentHeight,
    if (spentTimestamp != null) 'spent_timestamp': spentTimestamp,
    if (transactionId != null) 'transaction_id': transactionId,
  };
}

class CoinSpendJson {
  CoinSpendJson({
    required this.coin,
    required this.puzzleReveal,
    required this.solution,
  });

  final CoinJson coin;

  final String puzzleReveal;

  final String solution;

  factory CoinSpendJson.fromJson(Map<String, dynamic> json) => CoinSpendJson(
    coin: CoinJson.fromJson((json['coin'] as Map).cast<String, dynamic>()),
    puzzleReveal: json['puzzle_reveal'] as String,
    solution: json['solution'] as String,
  );

  Map<String, dynamic> toJson() => {
    'coin': coin.toJson(),
    'puzzle_reveal': puzzleReveal,
    'solution': solution,
  };
}

/// Combine multiple coins into one
class Combine {
  Combine({this.autoSubmit, required this.coinIds, required this.fee});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Coin IDs to combine
  final List<String> coinIds;

  /// Transaction fee
  final BigInt fee;

  factory Combine.fromJson(Map<String, dynamic> json) => Combine(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    coinIds: ((json['coin_ids']) as List).cast<String>(),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'coin_ids': coinIds,
    'fee': fee.toString(),
  };
}

/// Combine multiple offers
class CombineOffers {
  CombineOffers({required this.offers});

  /// Offer strings to combine
  final List<String> offers;

  factory CombineOffers.fromJson(Map<String, dynamic> json) =>
      CombineOffers(offers: ((json['offers']) as List).cast<String>());

  Map<String, dynamic> toJson() => {'offers': offers};
}

/// Response with combined offer
class CombineOffersResponse {
  CombineOffersResponse({required this.offer});

  /// Combined offer string
  final String offer;

  factory CombineOffersResponse.fromJson(Map<String, dynamic> json) =>
      CombineOffersResponse(offer: json['offer'] as String);

  Map<String, dynamic> toJson() => {'offer': offer};
}

/// Create a new DID
class CreateDid {
  CreateDid({this.autoSubmit, required this.fee, required this.name});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// DID name
  final String name;

  factory CreateDid.fromJson(Map<String, dynamic> json) => CreateDid(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'name': name,
  };
}

class CreateTransaction {
  CreateTransaction({
    required this.actions,
    this.autoSubmit,
    this.selectedCoinIds,
  });

  /// The list of actions to perform in the transaction
  final List<Map<String, dynamic>> actions;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Pre-selected coins to use in the transaction prior to coin selection
  final List<String>? selectedCoinIds;

  factory CreateTransaction.fromJson(Map<String, dynamic> json) =>
      CreateTransaction(
        actions: ((json['actions']) as List)
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
        autoSubmit: json['auto_submit'] == null
            ? null
            : (json['auto_submit'] as bool),
        selectedCoinIds: json['selected_coin_ids'] == null
            ? null
            : (((json['selected_coin_ids']) as List).cast<String>()),
      );

  Map<String, dynamic> toJson() => {
    'actions': actions,
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    if (selectedCoinIds != null) 'selected_coin_ids': selectedCoinIds,
  };
}

/// Delete a wallet database
class DeleteDatabase {
  DeleteDatabase({required this.fingerprint, required this.network});

  /// Wallet fingerprint
  final int fingerprint;

  /// Network name
  final String network;

  factory DeleteDatabase.fromJson(Map<String, dynamic> json) => DeleteDatabase(
    fingerprint: json['fingerprint'] as int,
    network: json['network'] as String,
  );

  Map<String, dynamic> toJson() => {
    'fingerprint': fingerprint,
    'network': network,
  };
}

/// Response for database deletion
class DeleteDatabaseResponse {
  const DeleteDatabaseResponse();

  factory DeleteDatabaseResponse.fromJson(Map<String, dynamic> json) =>
      DeleteDatabaseResponse();

  Map<String, dynamic> toJson() => {};
}

/// Delete a wallet key
class DeleteKey {
  DeleteKey({required this.fingerprint});

  /// Wallet fingerprint to delete
  final int fingerprint;

  factory DeleteKey.fromJson(Map<String, dynamic> json) =>
      DeleteKey(fingerprint: json['fingerprint'] as int);

  Map<String, dynamic> toJson() => {'fingerprint': fingerprint};
}

/// Response for key deletion
class DeleteKeyResponse {
  const DeleteKeyResponse();

  factory DeleteKeyResponse.fromJson(Map<String, dynamic> json) =>
      DeleteKeyResponse();

  Map<String, dynamic> toJson() => {};
}

/// Delete an offer
class DeleteOffer {
  DeleteOffer({required this.offerId});

  /// Offer ID to delete
  final String offerId;

  factory DeleteOffer.fromJson(Map<String, dynamic> json) =>
      DeleteOffer(offerId: json['offer_id'] as String);

  Map<String, dynamic> toJson() => {'offer_id': offerId};
}

/// Response for offer deletion
class DeleteOfferResponse {
  const DeleteOfferResponse();

  factory DeleteOfferResponse.fromJson(Map<String, dynamic> json) =>
      DeleteOfferResponse();

  Map<String, dynamic> toJson() => {};
}

/// Delete a theme NFT from the wallet
class DeleteUserTheme {
  DeleteUserTheme({required this.nftId});

  /// NFT ID of the theme
  final String nftId;

  factory DeleteUserTheme.fromJson(Map<String, dynamic> json) =>
      DeleteUserTheme(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

class DeleteUserThemeResponse {
  const DeleteUserThemeResponse();

  factory DeleteUserThemeResponse.fromJson(Map<String, dynamic> json) =>
      DeleteUserThemeResponse();

  Map<String, dynamic> toJson() => {};
}

class DerivationRecord {
  DerivationRecord({
    required this.address,
    required this.index,
    required this.publicKey,
  });

  final String address;

  final int index;

  final String publicKey;

  factory DerivationRecord.fromJson(Map<String, dynamic> json) =>
      DerivationRecord(
        address: json['address'] as String,
        index: json['index'] as int,
        publicKey: json['public_key'] as String,
      );

  Map<String, dynamic> toJson() => {
    'address': address,
    'index': index,
    'public_key': publicKey,
  };
}

class DidRecord {
  DidRecord({
    required this.address,
    required this.amount,
    required this.coinId,
    this.createdHeight,
    required this.launcherId,
    this.name,
    this.recoveryHash,
    required this.visible,
  });

  final String address;

  final BigInt amount;

  final String coinId;

  final int? createdHeight;

  final String launcherId;

  final String? name;

  final String? recoveryHash;

  final bool visible;

  factory DidRecord.fromJson(Map<String, dynamic> json) => DidRecord(
    address: json['address'] as String,
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    coinId: json['coin_id'] as String,
    createdHeight: json['created_height'] == null
        ? null
        : (json['created_height'] as int),
    launcherId: json['launcher_id'] as String,
    name: json['name'] == null ? null : (json['name'] as String),
    recoveryHash: json['recovery_hash'] == null
        ? null
        : (json['recovery_hash'] as String),
    visible: json['visible'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    'coin_id': coinId,
    if (createdHeight != null) 'created_height': createdHeight,
    'launcher_id': launcherId,
    if (name != null) 'name': name,
    if (recoveryHash != null) 'recovery_hash': recoveryHash,
    'visible': visible,
  };
}

class EmptyResponse {
  const EmptyResponse();

  factory EmptyResponse.fromJson(Map<String, dynamic> json) => EmptyResponse();

  Map<String, dynamic> toJson() => {};
}

class Error {
  Error({required this.error});

  /// Error message describing what went wrong
  final String error;

  factory Error.fromJson(Map<String, dynamic> json) =>
      Error(error: json['error'] as String);

  Map<String, dynamic> toJson() => {'error': error};
}

/// Exercise options
class ExerciseOptions {
  ExerciseOptions({
    this.autoSubmit,
    required this.fee,
    required this.optionIds,
  });

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Option IDs to exercise
  final List<String> optionIds;

  factory ExerciseOptions.fromJson(Map<String, dynamic> json) =>
      ExerciseOptions(
        autoSubmit: json['auto_submit'] == null
            ? null
            : (json['auto_submit'] as bool),
        fee: ((json['fee']) is String
            ? BigInt.parse(json['fee'] as String)
            : BigInt.from((json['fee'] as num).toInt())),
        optionIds: ((json['option_ids']) as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'option_ids': optionIds,
  };
}

class FeeAction {
  FeeAction({required this.amount});

  /// The fee amount, in mojos
  final BigInt amount;

  factory FeeAction.fromJson(Map<String, dynamic> json) => FeeAction(
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
  );

  Map<String, dynamic> toJson() => {'amount': amount.toString()};
}

/// Filter unlocked coins from a list
class FilterUnlockedCoins {
  FilterUnlockedCoins({required this.coinIds});

  /// Coin IDs to filter
  final List<String> coinIds;

  factory FilterUnlockedCoins.fromJson(Map<String, dynamic> json) =>
      FilterUnlockedCoins(coinIds: ((json['coin_ids']) as List).cast<String>());

  Map<String, dynamic> toJson() => {'coin_ids': coinIds};
}

/// Response with unlocked coin IDs
class FilterUnlockedCoinsResponse {
  FilterUnlockedCoinsResponse({required this.coinIds});

  /// List of unlocked coin IDs
  final List<String> coinIds;

  factory FilterUnlockedCoinsResponse.fromJson(Map<String, dynamic> json) =>
      FilterUnlockedCoinsResponse(
        coinIds: ((json['coin_ids']) as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {'coin_ids': coinIds};
}

/// Send CAT tokens to an address
class FinalizeClawback {
  FinalizeClawback({this.autoSubmit, required this.coinIds, required this.fee});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// The coins to finalize the clawback for
  final List<String> coinIds;

  /// Transaction fee
  final BigInt fee;

  factory FinalizeClawback.fromJson(Map<String, dynamic> json) =>
      FinalizeClawback(
        autoSubmit: json['auto_submit'] == null
            ? null
            : (json['auto_submit'] as bool),
        coinIds: ((json['coin_ids']) as List).cast<String>(),
        fee: ((json['fee']) is String
            ? BigInt.parse(json['fee'] as String)
            : BigInt.from((json['fee'] as num).toInt())),
      );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'coin_ids': coinIds,
    'fee': fee.toString(),
  };
}

/// Generate a new mnemonic phrase for wallet creation
class GenerateMnemonic {
  GenerateMnemonic({required this.use24Words});

  /// Whether to generate a 24-word mnemonic instead of 12-word
  final bool use24Words;

  factory GenerateMnemonic.fromJson(Map<String, dynamic> json) =>
      GenerateMnemonic(use24Words: json['use_24_words'] as bool);

  Map<String, dynamic> toJson() => {'use_24_words': use24Words};
}

/// Response containing the generated mnemonic phrase
class GenerateMnemonicResponse {
  GenerateMnemonicResponse({required this.mnemonic});

  /// The generated BIP-39 mnemonic phrase
  final String mnemonic;

  factory GenerateMnemonicResponse.fromJson(Map<String, dynamic> json) =>
      GenerateMnemonicResponse(mnemonic: json['mnemonic'] as String);

  Map<String, dynamic> toJson() => {'mnemonic': mnemonic};
}

/// Get all known CAT tokens
class GetAllCats {
  const GetAllCats();

  factory GetAllCats.fromJson(Map<String, dynamic> json) => GetAllCats();

  Map<String, dynamic> toJson() => {};
}

/// Response with all known CAT tokens
class GetAllCatsResponse {
  GetAllCatsResponse({required this.cats});

  /// List of all CAT tokens
  final List<TokenRecord> cats;

  factory GetAllCatsResponse.fromJson(Map<String, dynamic> json) =>
      GetAllCatsResponse(
        cats: ((json['cats']) as List)
            .map(
              (e) => TokenRecord.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'cats': cats.map((e) => e.toJson()).toList(),
  };
}

/// Check if specific coins are spendable
class GetAreCoinsSpendable {
  GetAreCoinsSpendable({required this.coinIds});

  /// List of coin IDs to check
  final List<String> coinIds;

  factory GetAreCoinsSpendable.fromJson(Map<String, dynamic> json) =>
      GetAreCoinsSpendable(
        coinIds: ((json['coin_ids']) as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {'coin_ids': coinIds};
}

/// Response with spendability status
class GetAreCoinsSpendableResponse {
  GetAreCoinsSpendableResponse({required this.spendable});

  /// Whether all coins are spendable
  final bool spendable;

  factory GetAreCoinsSpendableResponse.fromJson(Map<String, dynamic> json) =>
      GetAreCoinsSpendableResponse(spendable: json['spendable'] as bool);

  Map<String, dynamic> toJson() => {'spendable': spendable};
}

/// Get spendable coins for an asset
class GetAssetCoins {
  GetAssetCoins({
    this.assetId,
    this.includedLocked,
    this.limit,
    this.offset,
    this.type,
  });

  /// Asset ID to filter by
  final String? assetId;

  /// Whether to include locked coins
  final bool? includedLocked;

  /// Number of results to return
  final int? limit;

  /// Pagination offset
  final int? offset;

  final AssetCoinType? type;

  factory GetAssetCoins.fromJson(Map<String, dynamic> json) => GetAssetCoins(
    assetId: json['assetId'] == null ? null : (json['assetId'] as String),
    includedLocked: json['includedLocked'] == null
        ? null
        : (json['includedLocked'] as bool),
    limit: json['limit'] == null ? null : (json['limit'] as int),
    offset: json['offset'] == null ? null : (json['offset'] as int),
    type: json['type'] == null
        ? null
        : (AssetCoinType.fromJson(
            (json['type'] as Map).cast<String, dynamic>(),
          )),
  );

  Map<String, dynamic> toJson() => {
    if (assetId != null) 'assetId': assetId,
    if (includedLocked != null) 'includedLocked': includedLocked,
    if (limit != null) 'limit': limit,
    if (offset != null) 'offset': offset,
    if (type != null) 'type': type!.toJson(),
  };
}

/// Get CAT tokens in wallet
class GetCats {
  const GetCats();

  factory GetCats.fromJson(Map<String, dynamic> json) => GetCats();

  Map<String, dynamic> toJson() => {};
}

/// Response with CAT tokens
class GetCatsResponse {
  GetCatsResponse({required this.cats});

  final List<TokenRecord> cats;

  factory GetCatsResponse.fromJson(Map<String, dynamic> json) =>
      GetCatsResponse(
        cats: ((json['cats']) as List)
            .map(
              (e) => TokenRecord.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'cats': cats.map((e) => e.toJson()).toList(),
  };
}

/// List coins with filtering and pagination
class GetCoins {
  GetCoins({
    this.ascending,
    this.assetId,
    this.filterMode,
    required this.limit,
    required this.offset,
    this.sortMode,
  });

  /// Sort in ascending order
  final bool? ascending;

  /// Optional asset ID to filter by
  final String? assetId;

  /// Filter mode
  final CoinFilterMode? filterMode;

  /// Number of coins to return
  final int limit;

  /// Starting offset for pagination
  final int offset;

  /// Sort mode
  final CoinSortMode? sortMode;

  factory GetCoins.fromJson(Map<String, dynamic> json) => GetCoins(
    ascending: json['ascending'] == null ? null : (json['ascending'] as bool),
    assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
    filterMode: json['filter_mode'] == null
        ? null
        : (CoinFilterMode.fromJson(json['filter_mode'] as String)),
    limit: json['limit'] as int,
    offset: json['offset'] as int,
    sortMode: json['sort_mode'] == null
        ? null
        : (CoinSortMode.fromJson(json['sort_mode'] as String)),
  );

  Map<String, dynamic> toJson() => {
    if (ascending != null) 'ascending': ascending,
    if (assetId != null) 'asset_id': assetId,
    if (filterMode != null) 'filter_mode': filterMode!.toJson(),
    'limit': limit,
    'offset': offset,
    if (sortMode != null) 'sort_mode': sortMode!.toJson(),
  };
}

/// Retrieve specific coins by their IDs
class GetCoinsByIds {
  GetCoinsByIds({required this.coinIds});

  /// List of coin IDs to retrieve
  final List<String> coinIds;

  factory GetCoinsByIds.fromJson(Map<String, dynamic> json) =>
      GetCoinsByIds(coinIds: ((json['coin_ids']) as List).cast<String>());

  Map<String, dynamic> toJson() => {'coin_ids': coinIds};
}

/// Response with requested coins
class GetCoinsByIdsResponse {
  GetCoinsByIdsResponse({required this.coins});

  /// List of coins matching the requested IDs
  final List<CoinRecord> coins;

  factory GetCoinsByIdsResponse.fromJson(Map<String, dynamic> json) =>
      GetCoinsByIdsResponse(
        coins: ((json['coins']) as List)
            .map((e) => CoinRecord.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'coins': coins.map((e) => e.toJson()).toList(),
  };
}

/// Response with coin list
class GetCoinsResponse {
  GetCoinsResponse({required this.coins, required this.total});

  /// List of coins
  final List<CoinRecord> coins;

  /// Total number of coins available
  final int total;

  factory GetCoinsResponse.fromJson(Map<String, dynamic> json) =>
      GetCoinsResponse(
        coins: ((json['coins']) as List)
            .map((e) => CoinRecord.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        total: json['total'] as int,
      );

  Map<String, dynamic> toJson() => {
    'coins': coins.map((e) => e.toJson()).toList(),
    'total': total,
  };
}

/// Retrieve database statistics
class GetDatabaseStats {
  const GetDatabaseStats();

  factory GetDatabaseStats.fromJson(Map<String, dynamic> json) =>
      GetDatabaseStats();

  Map<String, dynamic> toJson() => {};
}

/// Response with database statistics
class GetDatabaseStatsResponse {
  GetDatabaseStatsResponse({
    required this.databaseSizeBytes,
    required this.freePages,
    required this.freePercentage,
    required this.freeSpaceBytes,
    required this.pageSize,
    required this.totalPages,
    required this.walPages,
  });

  /// Total database size in bytes
  final int databaseSizeBytes;

  /// Number of free pages
  final int freePages;

  /// Percentage of free space
  final double freePercentage;

  /// Free space in bytes
  final int freeSpaceBytes;

  /// Size of each page in bytes
  final int pageSize;

  /// Total pages in database
  final int totalPages;

  /// Number of WAL pages
  final int walPages;

  factory GetDatabaseStatsResponse.fromJson(Map<String, dynamic> json) =>
      GetDatabaseStatsResponse(
        databaseSizeBytes: json['database_size_bytes'] as int,
        freePages: json['free_pages'] as int,
        freePercentage: (json['free_percentage'] as num).toDouble(),
        freeSpaceBytes: json['free_space_bytes'] as int,
        pageSize: json['page_size'] as int,
        totalPages: json['total_pages'] as int,
        walPages: json['wal_pages'] as int,
      );

  Map<String, dynamic> toJson() => {
    'database_size_bytes': databaseSizeBytes,
    'free_pages': freePages,
    'free_percentage': freePercentage,
    'free_space_bytes': freeSpaceBytes,
    'page_size': pageSize,
    'total_pages': totalPages,
    'wal_pages': walPages,
  };
}

/// Get address derivation information
class GetDerivations {
  GetDerivations({this.hardened, required this.limit, required this.offset});

  /// Whether to retrieve hardened derivations
  final bool? hardened;

  /// Number of derivations to return
  final int limit;

  /// Starting offset for pagination
  final int offset;

  factory GetDerivations.fromJson(Map<String, dynamic> json) => GetDerivations(
    hardened: json['hardened'] == null ? null : (json['hardened'] as bool),
    limit: json['limit'] as int,
    offset: json['offset'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (hardened != null) 'hardened': hardened,
    'limit': limit,
    'offset': offset,
  };
}

/// Response with derivation records
class GetDerivationsResponse {
  GetDerivationsResponse({required this.derivations, required this.total});

  /// List of address derivations
  final List<DerivationRecord> derivations;

  /// Total number of derivations available
  final int total;

  factory GetDerivationsResponse.fromJson(Map<String, dynamic> json) =>
      GetDerivationsResponse(
        derivations: ((json['derivations']) as List)
            .map(
              (e) =>
                  DerivationRecord.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
        total: json['total'] as int,
      );

  Map<String, dynamic> toJson() => {
    'derivations': derivations.map((e) => e.toJson()).toList(),
    'total': total,
  };
}

/// List all DIDs in the wallet
class GetDids {
  const GetDids();

  factory GetDids.fromJson(Map<String, dynamic> json) => GetDids();

  Map<String, dynamic> toJson() => {};
}

/// Response with DID list
class GetDidsResponse {
  GetDidsResponse({required this.dids});

  /// List of DIDs
  final List<DidRecord> dids;

  factory GetDidsResponse.fromJson(Map<String, dynamic> json) =>
      GetDidsResponse(
        dids: ((json['dids']) as List)
            .map((e) => DidRecord.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'dids': dids.map((e) => e.toJson()).toList(),
  };
}

/// Get a specific wallet key
class GetKey {
  GetKey({this.fingerprint});

  /// Wallet fingerprint (uses currently logged in if null)
  final int? fingerprint;

  factory GetKey.fromJson(Map<String, dynamic> json) => GetKey(
    fingerprint: json['fingerprint'] == null
        ? null
        : (json['fingerprint'] as int),
  );

  Map<String, dynamic> toJson() => {
    if (fingerprint != null) 'fingerprint': fingerprint,
  };
}

/// Response with key information
class GetKeyResponse {
  GetKeyResponse({this.key});

  final KeyInfo? key;

  factory GetKeyResponse.fromJson(Map<String, dynamic> json) => GetKeyResponse(
    key: json['key'] == null
        ? null
        : (KeyInfo.fromJson((json['key'] as Map).cast<String, dynamic>())),
  );

  Map<String, dynamic> toJson() => {if (key != null) 'key': key!.toJson()};
}

/// List all wallet keys
class GetKeys {
  const GetKeys();

  factory GetKeys.fromJson(Map<String, dynamic> json) => GetKeys();

  Map<String, dynamic> toJson() => {};
}

/// Response with all wallet keys
class GetKeysResponse {
  GetKeysResponse({required this.keys});

  /// List of wallet keys
  final List<KeyInfo> keys;

  factory GetKeysResponse.fromJson(Map<String, dynamic> json) =>
      GetKeysResponse(
        keys: ((json['keys']) as List)
            .map((e) => KeyInfo.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'keys': keys.map((e) => e.toJson()).toList(),
  };
}

/// Get minter DIDs with pagination
class GetMinterDidIds {
  GetMinterDidIds({required this.limit, required this.offset});

  /// Number of DID IDs to return
  final int limit;

  /// Starting offset for pagination
  final int offset;

  factory GetMinterDidIds.fromJson(Map<String, dynamic> json) =>
      GetMinterDidIds(
        limit: json['limit'] as int,
        offset: json['offset'] as int,
      );

  Map<String, dynamic> toJson() => {'limit': limit, 'offset': offset};
}

/// Response with minter DID IDs
class GetMinterDidIdsResponse {
  GetMinterDidIdsResponse({required this.didIds, required this.total});

  /// List of minter DID IDs
  final List<String> didIds;

  /// Total number of minter DIDs
  final int total;

  factory GetMinterDidIdsResponse.fromJson(Map<String, dynamic> json) =>
      GetMinterDidIdsResponse(
        didIds: ((json['did_ids']) as List).cast<String>(),
        total: json['total'] as int,
      );

  Map<String, dynamic> toJson() => {'did_ids': didIds, 'total': total};
}

/// Get current network information
class GetNetwork {
  const GetNetwork();

  factory GetNetwork.fromJson(Map<String, dynamic> json) => GetNetwork();

  Map<String, dynamic> toJson() => {};
}

/// List available networks
class GetNetworks {
  const GetNetworks();

  factory GetNetworks.fromJson(Map<String, dynamic> json) => GetNetworks();

  Map<String, dynamic> toJson() => {};
}

/// Get a specific NFT
class GetNft {
  GetNft({required this.nftId});

  /// NFT coin ID
  final String nftId;

  factory GetNft.fromJson(Map<String, dynamic> json) =>
      GetNft(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

/// Get a specific NFT collection
class GetNftCollection {
  GetNftCollection({this.collectionId});

  /// Collection ID (null for uncollected NFTs)
  final String? collectionId;

  factory GetNftCollection.fromJson(Map<String, dynamic> json) =>
      GetNftCollection(
        collectionId: json['collection_id'] == null
            ? null
            : (json['collection_id'] as String),
      );

  Map<String, dynamic> toJson() => {
    if (collectionId != null) 'collection_id': collectionId,
  };
}

/// Response with NFT collection details
class GetNftCollectionResponse {
  GetNftCollectionResponse({this.collection});

  final NftCollectionRecord? collection;

  factory GetNftCollectionResponse.fromJson(Map<String, dynamic> json) =>
      GetNftCollectionResponse(
        collection: json['collection'] == null
            ? null
            : (NftCollectionRecord.fromJson(
                (json['collection'] as Map).cast<String, dynamic>(),
              )),
      );

  Map<String, dynamic> toJson() => {
    if (collection != null) 'collection': collection!.toJson(),
  };
}

/// List NFT collections
class GetNftCollections {
  GetNftCollections({
    required this.includeHidden,
    required this.limit,
    required this.offset,
  });

  /// Include hidden collections
  final bool includeHidden;

  /// Number of collections to return
  final int limit;

  /// Starting offset for pagination
  final int offset;

  factory GetNftCollections.fromJson(Map<String, dynamic> json) =>
      GetNftCollections(
        includeHidden: json['include_hidden'] as bool,
        limit: json['limit'] as int,
        offset: json['offset'] as int,
      );

  Map<String, dynamic> toJson() => {
    'include_hidden': includeHidden,
    'limit': limit,
    'offset': offset,
  };
}

/// Response with NFT collections
class GetNftCollectionsResponse {
  GetNftCollectionsResponse({required this.collections, required this.total});

  /// List of NFT collections
  final List<NftCollectionRecord> collections;

  /// Total number of collections
  final int total;

  factory GetNftCollectionsResponse.fromJson(Map<String, dynamic> json) =>
      GetNftCollectionsResponse(
        collections: ((json['collections']) as List)
            .map(
              (e) => NftCollectionRecord.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
        total: json['total'] as int,
      );

  Map<String, dynamic> toJson() => {
    'collections': collections.map((e) => e.toJson()).toList(),
    'total': total,
  };
}

/// Get NFT data file
class GetNftData {
  GetNftData({required this.nftId});

  /// NFT coin ID
  final String nftId;

  factory GetNftData.fromJson(Map<String, dynamic> json) =>
      GetNftData(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

/// Response with NFT data
class GetNftDataResponse {
  GetNftDataResponse({this.data});

  final NftData? data;

  factory GetNftDataResponse.fromJson(Map<String, dynamic> json) =>
      GetNftDataResponse(
        data: json['data'] == null
            ? null
            : (NftData.fromJson((json['data'] as Map).cast<String, dynamic>())),
      );

  Map<String, dynamic> toJson() => {if (data != null) 'data': data!.toJson()};
}

/// Get NFT icon image
class GetNftIcon {
  GetNftIcon({required this.nftId});

  /// NFT coin ID
  final String nftId;

  factory GetNftIcon.fromJson(Map<String, dynamic> json) =>
      GetNftIcon(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

/// Response with NFT icon
class GetNftIconResponse {
  GetNftIconResponse({this.icon});

  /// Base64-encoded icon image
  final String? icon;

  factory GetNftIconResponse.fromJson(Map<String, dynamic> json) =>
      GetNftIconResponse(
        icon: json['icon'] == null ? null : (json['icon'] as String),
      );

  Map<String, dynamic> toJson() => {if (icon != null) 'icon': icon};
}

/// Response with NFT details
class GetNftResponse {
  GetNftResponse({this.nft});

  final NftRecord? nft;

  factory GetNftResponse.fromJson(Map<String, dynamic> json) => GetNftResponse(
    nft: json['nft'] == null
        ? null
        : (NftRecord.fromJson((json['nft'] as Map).cast<String, dynamic>())),
  );

  Map<String, dynamic> toJson() => {if (nft != null) 'nft': nft!.toJson()};
}

/// Get NFT thumbnail image
class GetNftThumbnail {
  GetNftThumbnail({required this.nftId});

  /// NFT coin ID
  final String nftId;

  factory GetNftThumbnail.fromJson(Map<String, dynamic> json) =>
      GetNftThumbnail(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

/// Response with NFT thumbnail
class GetNftThumbnailResponse {
  GetNftThumbnailResponse({this.thumbnail});

  /// Base64-encoded thumbnail image
  final String? thumbnail;

  factory GetNftThumbnailResponse.fromJson(Map<String, dynamic> json) =>
      GetNftThumbnailResponse(
        thumbnail: json['thumbnail'] == null
            ? null
            : (json['thumbnail'] as String),
      );

  Map<String, dynamic> toJson() => {
    if (thumbnail != null) 'thumbnail': thumbnail,
  };
}

/// List NFTs with filtering
class GetNfts {
  GetNfts({
    this.collectionId,
    required this.includeHidden,
    required this.limit,
    this.minterDidId,
    this.name,
    required this.offset,
    this.ownerDidId,
    required this.sortMode,
  });

  /// Filter by collection ID
  final String? collectionId;

  /// Include hidden NFTs
  final bool includeHidden;

  /// Number of NFTs to return
  final int limit;

  /// Filter by minter DID
  final String? minterDidId;

  /// Filter by name search
  final String? name;

  /// Starting offset for pagination
  final int offset;

  /// Filter by owner DID
  final String? ownerDidId;

  /// Sort mode
  final NftSortMode sortMode;

  factory GetNfts.fromJson(Map<String, dynamic> json) => GetNfts(
    collectionId: json['collection_id'] == null
        ? null
        : (json['collection_id'] as String),
    includeHidden: json['include_hidden'] as bool,
    limit: json['limit'] as int,
    minterDidId: json['minter_did_id'] == null
        ? null
        : (json['minter_did_id'] as String),
    name: json['name'] == null ? null : (json['name'] as String),
    offset: json['offset'] as int,
    ownerDidId: json['owner_did_id'] == null
        ? null
        : (json['owner_did_id'] as String),
    sortMode: NftSortMode.fromJson(json['sort_mode'] as String),
  );

  Map<String, dynamic> toJson() => {
    if (collectionId != null) 'collection_id': collectionId,
    'include_hidden': includeHidden,
    'limit': limit,
    if (minterDidId != null) 'minter_did_id': minterDidId,
    if (name != null) 'name': name,
    'offset': offset,
    if (ownerDidId != null) 'owner_did_id': ownerDidId,
    'sort_mode': sortMode.toJson(),
  };
}

/// Response with NFTs list
class GetNftsResponse {
  GetNftsResponse({required this.nfts, required this.total});

  /// List of NFTs
  final List<NftRecord> nfts;

  /// Total number of NFTs
  final int total;

  factory GetNftsResponse.fromJson(Map<String, dynamic> json) =>
      GetNftsResponse(
        nfts: ((json['nfts']) as List)
            .map((e) => NftRecord.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        total: json['total'] as int,
      );

  Map<String, dynamic> toJson() => {
    'nfts': nfts.map((e) => e.toJson()).toList(),
    'total': total,
  };
}

/// Get a specific offer
class GetOffer {
  GetOffer({required this.offerId});

  /// Offer ID
  final String offerId;

  factory GetOffer.fromJson(Map<String, dynamic> json) =>
      GetOffer(offerId: json['offer_id'] as String);

  Map<String, dynamic> toJson() => {'offer_id': offerId};
}

/// Response with offer details
class GetOfferResponse {
  GetOfferResponse({required this.offer});

  /// Offer details
  final OfferRecord offer;

  factory GetOfferResponse.fromJson(Map<String, dynamic> json) =>
      GetOfferResponse(
        offer: OfferRecord.fromJson(
          (json['offer'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {'offer': offer.toJson()};
}

/// List all offers
class GetOffers {
  const GetOffers();

  factory GetOffers.fromJson(Map<String, dynamic> json) => GetOffers();

  Map<String, dynamic> toJson() => {};
}

/// Get offers for a specific asset
class GetOffersForAsset {
  GetOffersForAsset({required this.assetId});

  /// Asset ID to filter by
  final String assetId;

  factory GetOffersForAsset.fromJson(Map<String, dynamic> json) =>
      GetOffersForAsset(assetId: json['asset_id'] as String);

  Map<String, dynamic> toJson() => {'asset_id': assetId};
}

/// Response with offers for asset
class GetOffersForAssetResponse {
  GetOffersForAssetResponse({required this.offers});

  /// List of offers involving the asset
  final List<OfferRecord> offers;

  factory GetOffersForAssetResponse.fromJson(Map<String, dynamic> json) =>
      GetOffersForAssetResponse(
        offers: ((json['offers']) as List)
            .map(
              (e) => OfferRecord.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'offers': offers.map((e) => e.toJson()).toList(),
  };
}

/// Response with list of offers
class GetOffersResponse {
  GetOffersResponse({required this.offers});

  /// List of offers
  final List<OfferRecord> offers;

  factory GetOffersResponse.fromJson(Map<String, dynamic> json) =>
      GetOffersResponse(
        offers: ((json['offers']) as List)
            .map(
              (e) => OfferRecord.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'offers': offers.map((e) => e.toJson()).toList(),
  };
}

/// Get a specific option
class GetOption {
  GetOption({required this.optionId});

  /// Option ID
  final String optionId;

  factory GetOption.fromJson(Map<String, dynamic> json) =>
      GetOption(optionId: json['option_id'] as String);

  Map<String, dynamic> toJson() => {'option_id': optionId};
}

/// Response with option details
class GetOptionResponse {
  GetOptionResponse({this.option});

  final OptionRecord? option;

  factory GetOptionResponse.fromJson(Map<String, dynamic> json) =>
      GetOptionResponse(
        option: json['option'] == null
            ? null
            : (OptionRecord.fromJson(
                (json['option'] as Map).cast<String, dynamic>(),
              )),
      );

  Map<String, dynamic> toJson() => {
    if (option != null) 'option': option!.toJson(),
  };
}

/// List options with filtering
class GetOptions {
  GetOptions({
    this.ascending,
    this.findValue,
    this.includeHidden,
    required this.limit,
    required this.offset,
    this.sortMode,
  });

  /// Sort in ascending order
  final bool? ascending;

  /// Optional search value
  final String? findValue;

  /// Include hidden options
  final bool? includeHidden;

  /// Number of options to return
  final int limit;

  /// Starting offset for pagination
  final int offset;

  /// Sort mode
  final OptionSortMode? sortMode;

  factory GetOptions.fromJson(Map<String, dynamic> json) => GetOptions(
    ascending: json['ascending'] == null ? null : (json['ascending'] as bool),
    findValue: json['find_value'] == null
        ? null
        : (json['find_value'] as String),
    includeHidden: json['include_hidden'] == null
        ? null
        : (json['include_hidden'] as bool),
    limit: json['limit'] as int,
    offset: json['offset'] as int,
    sortMode: json['sort_mode'] == null
        ? null
        : (OptionSortMode.fromJson(json['sort_mode'] as String)),
  );

  Map<String, dynamic> toJson() => {
    if (ascending != null) 'ascending': ascending,
    if (findValue != null) 'find_value': findValue,
    if (includeHidden != null) 'include_hidden': includeHidden,
    'limit': limit,
    'offset': offset,
    if (sortMode != null) 'sort_mode': sortMode!.toJson(),
  };
}

/// Response with options list
class GetOptionsResponse {
  GetOptionsResponse({required this.options, required this.total});

  /// List of options
  final List<OptionRecord> options;

  /// Total number of options
  final int total;

  factory GetOptionsResponse.fromJson(Map<String, dynamic> json) =>
      GetOptionsResponse(
        options: ((json['options']) as List)
            .map(
              (e) => OptionRecord.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
        total: json['total'] as int,
      );

  Map<String, dynamic> toJson() => {
    'options': options.map((e) => e.toJson()).toList(),
    'total': total,
  };
}

/// List all network peers
class GetPeers {
  const GetPeers();

  factory GetPeers.fromJson(Map<String, dynamic> json) => GetPeers();

  Map<String, dynamic> toJson() => {};
}

/// Response containing peer list
class GetPeersResponse {
  GetPeersResponse({required this.peers});

  /// List of connected peers
  final List<PeerRecord> peers;

  factory GetPeersResponse.fromJson(Map<String, dynamic> json) =>
      GetPeersResponse(
        peers: ((json['peers']) as List)
            .map((e) => PeerRecord.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'peers': peers.map((e) => e.toJson()).toList(),
  };
}

/// Get pending transactions
class GetPendingTransactions {
  const GetPendingTransactions();

  factory GetPendingTransactions.fromJson(Map<String, dynamic> json) =>
      GetPendingTransactions();

  Map<String, dynamic> toJson() => {};
}

/// Response with pending transactions
class GetPendingTransactionsResponse {
  GetPendingTransactionsResponse({required this.transactions});

  /// List of pending transactions
  final List<PendingTransactionRecord> transactions;

  factory GetPendingTransactionsResponse.fromJson(Map<String, dynamic> json) =>
      GetPendingTransactionsResponse(
        transactions: ((json['transactions']) as List)
            .map(
              (e) => PendingTransactionRecord.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// Get wallet secret key
class GetSecretKey {
  GetSecretKey({required this.fingerprint});

  /// Wallet fingerprint
  final int fingerprint;

  factory GetSecretKey.fromJson(Map<String, dynamic> json) =>
      GetSecretKey(fingerprint: json['fingerprint'] as int);

  Map<String, dynamic> toJson() => {'fingerprint': fingerprint};
}

/// Response with secret key information
class GetSecretKeyResponse {
  GetSecretKeyResponse({this.secrets});

  final SecretKeyInfo? secrets;

  factory GetSecretKeyResponse.fromJson(Map<String, dynamic> json) =>
      GetSecretKeyResponse(
        secrets: json['secrets'] == null
            ? null
            : (SecretKeyInfo.fromJson(
                (json['secrets'] as Map).cast<String, dynamic>(),
              )),
      );

  Map<String, dynamic> toJson() => {
    if (secrets != null) 'secrets': secrets!.toJson(),
  };
}

/// Get the count of spendable coins
class GetSpendableCoinCount {
  GetSpendableCoinCount({this.assetId});

  /// Optional asset ID to filter by (null for XCH)
  final String? assetId;

  factory GetSpendableCoinCount.fromJson(Map<String, dynamic> json) =>
      GetSpendableCoinCount(
        assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
      );

  Map<String, dynamic> toJson() => {if (assetId != null) 'asset_id': assetId};
}

/// Response with coin count
class GetSpendableCoinCountResponse {
  GetSpendableCoinCountResponse({required this.count});

  /// Number of spendable coins
  final int count;

  factory GetSpendableCoinCountResponse.fromJson(Map<String, dynamic> json) =>
      GetSpendableCoinCountResponse(count: json['count'] as int);

  Map<String, dynamic> toJson() => {'count': count};
}

/// Get the current synchronization status
class GetSyncStatus {
  const GetSyncStatus();

  factory GetSyncStatus.fromJson(Map<String, dynamic> json) => GetSyncStatus();

  Map<String, dynamic> toJson() => {};
}

/// Response with detailed sync status
class GetSyncStatusResponse {
  GetSyncStatusResponse({
    required this.burnAddress,
    required this.checkedFiles,
    required this.databaseSize,
    required this.hardenedDerivationIndex,
    required this.receiveAddress,
    required this.selectableBalance,
    required this.syncedCoins,
    required this.totalCoins,
    required this.totalFiles,
    required this.unhardenedDerivationIndex,
    required this.unit,
  });

  /// Burn address for the wallet
  final String burnAddress;

  /// Number of NFT files checked
  final int checkedFiles;

  /// Database size in bytes
  final int databaseSize;

  /// Hardened derivation index
  final int hardenedDerivationIndex;

  /// Current receive address
  final String receiveAddress;

  /// Current wallet selectable balance
  final BigInt selectableBalance;

  /// Number of coins synced
  final int syncedCoins;

  /// Total coins to sync
  final int totalCoins;

  /// Total NFT files to check
  final int totalFiles;

  /// Unhardened derivation index
  final int unhardenedDerivationIndex;

  /// Unit for balance display
  final Unit unit;

  factory GetSyncStatusResponse.fromJson(Map<String, dynamic> json) =>
      GetSyncStatusResponse(
        burnAddress: json['burn_address'] as String,
        checkedFiles: json['checked_files'] as int,
        databaseSize: json['database_size'] as int,
        hardenedDerivationIndex: json['hardened_derivation_index'] as int,
        receiveAddress: json['receive_address'] as String,
        selectableBalance: ((json['selectable_balance']) is String
            ? BigInt.parse(json['selectable_balance'] as String)
            : BigInt.from((json['selectable_balance'] as num).toInt())),
        syncedCoins: json['synced_coins'] as int,
        totalCoins: json['total_coins'] as int,
        totalFiles: json['total_files'] as int,
        unhardenedDerivationIndex: json['unhardened_derivation_index'] as int,
        unit: Unit.fromJson((json['unit'] as Map).cast<String, dynamic>()),
      );

  Map<String, dynamic> toJson() => {
    'burn_address': burnAddress,
    'checked_files': checkedFiles,
    'database_size': databaseSize,
    'hardened_derivation_index': hardenedDerivationIndex,
    'receive_address': receiveAddress,
    'selectable_balance': selectableBalance.toString(),
    'synced_coins': syncedCoins,
    'total_coins': totalCoins,
    'total_files': totalFiles,
    'unhardened_derivation_index': unhardenedDerivationIndex,
    'unit': unit.toJson(),
  };
}

/// Get detailed token information
class GetToken {
  GetToken({this.assetId});

  /// Asset ID of the token (null for XCH)
  final String? assetId;

  factory GetToken.fromJson(Map<String, dynamic> json) => GetToken(
    assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
  );

  Map<String, dynamic> toJson() => {if (assetId != null) 'asset_id': assetId};
}

/// Response with token details
class GetTokenResponse {
  GetTokenResponse({this.token});

  final TokenRecord? token;

  factory GetTokenResponse.fromJson(Map<String, dynamic> json) =>
      GetTokenResponse(
        token: json['token'] == null
            ? null
            : (TokenRecord.fromJson(
                (json['token'] as Map).cast<String, dynamic>(),
              )),
      );

  Map<String, dynamic> toJson() => {
    if (token != null) 'token': token!.toJson(),
  };
}

/// Get a specific transaction by height
class GetTransaction {
  GetTransaction({required this.height});

  /// Transaction height/ID
  final int height;

  factory GetTransaction.fromJson(Map<String, dynamic> json) =>
      GetTransaction(height: json['height'] as int);

  Map<String, dynamic> toJson() => {'height': height};
}

/// Response with transaction details
class GetTransactionResponse {
  GetTransactionResponse({this.transaction});

  final TransactionRecord? transaction;

  factory GetTransactionResponse.fromJson(Map<String, dynamic> json) =>
      GetTransactionResponse(
        transaction: json['transaction'] == null
            ? null
            : (TransactionRecord.fromJson(
                (json['transaction'] as Map).cast<String, dynamic>(),
              )),
      );

  Map<String, dynamic> toJson() => {
    if (transaction != null) 'transaction': transaction!.toJson(),
  };
}

/// List transactions with filtering
class GetTransactions {
  GetTransactions({
    required this.ascending,
    this.findValue,
    required this.limit,
    required this.offset,
  });

  /// Sort in ascending order
  final bool ascending;

  /// Optional search value
  final String? findValue;

  /// Number of transactions to return
  final int limit;

  /// Starting offset for pagination
  final int offset;

  factory GetTransactions.fromJson(Map<String, dynamic> json) =>
      GetTransactions(
        ascending: json['ascending'] as bool,
        findValue: json['find_value'] == null
            ? null
            : (json['find_value'] as String),
        limit: json['limit'] as int,
        offset: json['offset'] as int,
      );

  Map<String, dynamic> toJson() => {
    'ascending': ascending,
    if (findValue != null) 'find_value': findValue,
    'limit': limit,
    'offset': offset,
  };
}

/// Response with transactions list
class GetTransactionsResponse {
  GetTransactionsResponse({required this.total, required this.transactions});

  /// Total number of transactions
  final int total;

  /// List of transactions
  final List<TransactionRecord> transactions;

  factory GetTransactionsResponse.fromJson(Map<String, dynamic> json) =>
      GetTransactionsResponse(
        total: json['total'] as int,
        transactions: ((json['transactions']) as List)
            .map(
              (e) => TransactionRecord.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'total': total,
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// Get a specific theme NFT
class GetUserTheme {
  GetUserTheme({required this.nftId});

  /// NFT ID of the theme
  final String nftId;

  factory GetUserTheme.fromJson(Map<String, dynamic> json) =>
      GetUserTheme(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

class GetUserThemeResponse {
  GetUserThemeResponse({this.theme});

  /// Theme data if found
  final String? theme;

  factory GetUserThemeResponse.fromJson(Map<String, dynamic> json) =>
      GetUserThemeResponse(
        theme: json['theme'] == null ? null : (json['theme'] as String),
      );

  Map<String, dynamic> toJson() => {if (theme != null) 'theme': theme};
}

/// List all custom theme NFTs
class GetUserThemes {
  const GetUserThemes();

  factory GetUserThemes.fromJson(Map<String, dynamic> json) => GetUserThemes();

  Map<String, dynamic> toJson() => {};
}

class GetUserThemesResponse {
  GetUserThemesResponse({required this.themes});

  /// List of theme NFT IDs
  final List<String> themes;

  factory GetUserThemesResponse.fromJson(Map<String, dynamic> json) =>
      GetUserThemesResponse(themes: ((json['themes']) as List).cast<String>());

  Map<String, dynamic> toJson() => {'themes': themes};
}

/// Get the wallet version
class GetVersion {
  const GetVersion();

  factory GetVersion.fromJson(Map<String, dynamic> json) => GetVersion();

  Map<String, dynamic> toJson() => {};
}

/// Response with version information
class GetVersionResponse {
  GetVersionResponse({required this.version});

  /// Semantic version string
  final String version;

  factory GetVersionResponse.fromJson(Map<String, dynamic> json) =>
      GetVersionResponse(version: json['version'] as String);

  Map<String, dynamic> toJson() => {'version': version};
}

/// Import a wallet key
class ImportKey {
  ImportKey({
    this.derivationIndex,
    this.emoji,
    this.hardened,
    required this.key,
    this.login,
    required this.name,
    this.saveSecrets,
    this.unhardened,
  });

  /// Starting derivation index
  final int? derivationIndex;

  /// Optional emoji identifier
  final String? emoji;

  /// Optional hardened derivation count
  final bool? hardened;

  /// Mnemonic phrase or private key
  final String key;

  /// Whether to automatically login after import
  final bool? login;

  /// Display name for the wallet
  final String name;

  /// Whether to save secrets to keychain
  final bool? saveSecrets;

  /// Optional unhardened derivation count
  final bool? unhardened;

  factory ImportKey.fromJson(Map<String, dynamic> json) => ImportKey(
    derivationIndex: json['derivation_index'] == null
        ? null
        : (json['derivation_index'] as int),
    emoji: json['emoji'] == null ? null : (json['emoji'] as String),
    hardened: json['hardened'] == null ? null : (json['hardened'] as bool),
    key: json['key'] as String,
    login: json['login'] == null ? null : (json['login'] as bool),
    name: json['name'] as String,
    saveSecrets: json['save_secrets'] == null
        ? null
        : (json['save_secrets'] as bool),
    unhardened: json['unhardened'] == null
        ? null
        : (json['unhardened'] as bool),
  );

  Map<String, dynamic> toJson() => {
    if (derivationIndex != null) 'derivation_index': derivationIndex,
    if (emoji != null) 'emoji': emoji,
    if (hardened != null) 'hardened': hardened,
    'key': key,
    if (login != null) 'login': login,
    'name': name,
    if (saveSecrets != null) 'save_secrets': saveSecrets,
    if (unhardened != null) 'unhardened': unhardened,
  };
}

/// Response with imported key fingerprint
class ImportKeyResponse {
  ImportKeyResponse({required this.fingerprint});

  /// Fingerprint of the imported key
  final int fingerprint;

  factory ImportKeyResponse.fromJson(Map<String, dynamic> json) =>
      ImportKeyResponse(fingerprint: json['fingerprint'] as int);

  Map<String, dynamic> toJson() => {'fingerprint': fingerprint};
}

/// Import an offer
class ImportOffer {
  ImportOffer({required this.offer});

  /// Offer string to import
  final String offer;

  factory ImportOffer.fromJson(Map<String, dynamic> json) =>
      ImportOffer(offer: json['offer'] as String);

  Map<String, dynamic> toJson() => {'offer': offer};
}

/// Response with imported offer ID
class ImportOfferResponse {
  ImportOfferResponse({required this.offerId});

  /// ID of the imported offer
  final String offerId;

  factory ImportOfferResponse.fromJson(Map<String, dynamic> json) =>
      ImportOfferResponse(offerId: json['offer_id'] as String);

  Map<String, dynamic> toJson() => {'offer_id': offerId};
}

/// Increase the derivation index to generate more addresses
class IncreaseDerivationIndex {
  IncreaseDerivationIndex({
    this.hardened,
    required this.index,
    this.unhardened,
  });

  /// Whether to derive hardened addresses (defaults to true if not specified)
  final bool? hardened;

  /// The target derivation index to increase to
  final int index;

  /// Whether to derive unhardened addresses (defaults to true if not specified)
  final bool? unhardened;

  factory IncreaseDerivationIndex.fromJson(Map<String, dynamic> json) =>
      IncreaseDerivationIndex(
        hardened: json['hardened'] == null ? null : (json['hardened'] as bool),
        index: json['index'] as int,
        unhardened: json['unhardened'] == null
            ? null
            : (json['unhardened'] as bool),
      );

  Map<String, dynamic> toJson() => {
    if (hardened != null) 'hardened': hardened,
    'index': index,
    if (unhardened != null) 'unhardened': unhardened,
  };
}

/// Response after increasing the derivation index
class IncreaseDerivationIndexResponse {
  const IncreaseDerivationIndexResponse();

  factory IncreaseDerivationIndexResponse.fromJson(Map<String, dynamic> json) =>
      IncreaseDerivationIndexResponse();

  Map<String, dynamic> toJson() => {};
}

/// Check if an asset is owned
class IsAssetOwned {
  IsAssetOwned({required this.assetId});

  /// Asset ID to check
  final String assetId;

  factory IsAssetOwned.fromJson(Map<String, dynamic> json) =>
      IsAssetOwned(assetId: json['asset_id'] as String);

  Map<String, dynamic> toJson() => {'asset_id': assetId};
}

/// Response with asset ownership status
class IsAssetOwnedResponse {
  IsAssetOwnedResponse({required this.owned});

  /// Whether the asset is owned by this wallet
  final bool owned;

  factory IsAssetOwnedResponse.fromJson(Map<String, dynamic> json) =>
      IsAssetOwnedResponse(owned: json['owned'] as bool);

  Map<String, dynamic> toJson() => {'owned': owned};
}

/// Issue a new CAT token
class IssueCat {
  IssueCat({
    required this.amount,
    this.autoSubmit,
    required this.fee,
    required this.name,
    required this.ticker,
  });

  /// Initial supply amount
  final BigInt amount;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Token name
  final String name;

  /// Token ticker symbol
  final String ticker;

  factory IssueCat.fromJson(Map<String, dynamic> json) => IssueCat(
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    name: json['name'] as String,
    ticker: json['ticker'] as String,
  );

  Map<String, dynamic> toJson() => {
    'amount': amount.toString(),
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'name': name,
    'ticker': ticker,
  };
}

class KeyInfo {
  KeyInfo({
    this.emoji,
    required this.fingerprint,
    required this.hasSecrets,
    required this.kind,
    required this.name,
    required this.networkId,
    required this.publicKey,
  });

  final String? emoji;

  final int fingerprint;

  final bool hasSecrets;

  final KeyKind kind;

  final String name;

  final String networkId;

  final String publicKey;

  factory KeyInfo.fromJson(Map<String, dynamic> json) => KeyInfo(
    emoji: json['emoji'] == null ? null : (json['emoji'] as String),
    fingerprint: json['fingerprint'] as int,
    hasSecrets: json['has_secrets'] as bool,
    kind: KeyKind.fromJson(json['kind'] as String),
    name: json['name'] as String,
    networkId: json['network_id'] as String,
    publicKey: json['public_key'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (emoji != null) 'emoji': emoji,
    'fingerprint': fingerprint,
    'has_secrets': hasSecrets,
    'kind': kind.toJson(),
    'name': name,
    'network_id': networkId,
    'public_key': publicKey,
  };
}

/// Login to a wallet using a fingerprint
class Login {
  Login({required this.fingerprint});

  /// The unique fingerprint identifier of the wallet to authenticate with. This is a 32-bit unsigned integer that uniquely identifies each wallet key in the system.
  final int fingerprint;

  factory Login.fromJson(Map<String, dynamic> json) =>
      Login(fingerprint: json['fingerprint'] as int);

  Map<String, dynamic> toJson() => {'fingerprint': fingerprint};
}

/// Response from logging into a wallet
class LoginResponse {
  const LoginResponse();

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse();

  Map<String, dynamic> toJson() => {};
}

/// Log out of the current wallet session
class Logout {
  const Logout();

  factory Logout.fromJson(Map<String, dynamic> json) => Logout();

  Map<String, dynamic> toJson() => {};
}

/// Response from logging out of a wallet
class LogoutResponse {
  const LogoutResponse();

  factory LogoutResponse.fromJson(Map<String, dynamic> json) =>
      LogoutResponse();

  Map<String, dynamic> toJson() => {};
}

/// Create a new offer
class MakeOffer {
  MakeOffer({
    this.autoImport,
    this.coinIds,
    this.expiresAtSecond,
    required this.fee,
    required this.offeredAssets,
    this.receiveAddress,
    required this.requestedAssets,
  });

  /// Whether to automatically import the offer
  final bool? autoImport;

  /// Optional specific coin IDs to use for the offer instead of auto-selecting
  final List<String>? coinIds;

  /// Optional expiration timestamp
  final int? expiresAtSecond;

  /// Transaction fee
  final BigInt fee;

  /// Assets offered in exchange
  final List<OfferAmount> offeredAssets;

  /// Optional receive address
  final String? receiveAddress;

  /// Assets requested in the offer
  final List<OfferAmount> requestedAssets;

  factory MakeOffer.fromJson(Map<String, dynamic> json) => MakeOffer(
    autoImport: json['auto_import'] == null
        ? null
        : (json['auto_import'] as bool),
    coinIds: json['coin_ids'] == null
        ? null
        : (((json['coin_ids']) as List).cast<String>()),
    expiresAtSecond: json['expires_at_second'] == null
        ? null
        : (json['expires_at_second'] as int),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    offeredAssets: ((json['offered_assets']) as List)
        .map((e) => OfferAmount.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    receiveAddress: json['receive_address'] == null
        ? null
        : (json['receive_address'] as String),
    requestedAssets: ((json['requested_assets']) as List)
        .map((e) => OfferAmount.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (autoImport != null) 'auto_import': autoImport,
    if (coinIds != null) 'coin_ids': coinIds,
    if (expiresAtSecond != null) 'expires_at_second': expiresAtSecond,
    'fee': fee.toString(),
    'offered_assets': offeredAssets.map((e) => e.toJson()).toList(),
    if (receiveAddress != null) 'receive_address': receiveAddress,
    'requested_assets': requestedAssets.map((e) => e.toJson()).toList(),
  };
}

/// Response with created offer
class MakeOfferResponse {
  MakeOfferResponse({required this.offer, required this.offerId});

  /// Offer string (bech32 encoded)
  final String offer;

  /// Offer ID
  final String offerId;

  factory MakeOfferResponse.fromJson(Map<String, dynamic> json) =>
      MakeOfferResponse(
        offer: json['offer'] as String,
        offerId: json['offer_id'] as String,
      );

  Map<String, dynamic> toJson() => {'offer': offer, 'offer_id': offerId};
}

class MintNftAction {
  MintNftAction({
    this.dataHash,
    this.dataUris,
    this.editionNumber,
    this.editionTotal,
    this.licenseHash,
    this.licenseUris,
    this.metadataHash,
    this.metadataUris,
    required this.parentId,
    this.royaltyAddress,
    this.royaltyTenThousandths,
  });

  /// Data hash
  final String? dataHash;

  /// Data URIs
  final List<String>? dataUris;

  /// Edition number
  final int? editionNumber;

  /// Total editions
  final int? editionTotal;

  /// License hash
  final String? licenseHash;

  /// License URIs
  final List<String>? licenseUris;

  /// Metadata hash
  final String? metadataHash;

  /// Metadata URIs
  final List<String>? metadataUris;

  /// The parent asset id of the minted NFT
  final Map<String, dynamic> parentId;

  /// Royalty payment address
  final String? royaltyAddress;

  /// Royalty percentage in ten-thousandths (e.g., 300 = 3%)
  final int? royaltyTenThousandths;

  factory MintNftAction.fromJson(Map<String, dynamic> json) => MintNftAction(
    dataHash: json['data_hash'] == null ? null : (json['data_hash'] as String),
    dataUris: json['data_uris'] == null
        ? null
        : (((json['data_uris']) as List).cast<String>()),
    editionNumber: json['edition_number'] == null
        ? null
        : (json['edition_number'] as int),
    editionTotal: json['edition_total'] == null
        ? null
        : (json['edition_total'] as int),
    licenseHash: json['license_hash'] == null
        ? null
        : (json['license_hash'] as String),
    licenseUris: json['license_uris'] == null
        ? null
        : (((json['license_uris']) as List).cast<String>()),
    metadataHash: json['metadata_hash'] == null
        ? null
        : (json['metadata_hash'] as String),
    metadataUris: json['metadata_uris'] == null
        ? null
        : (((json['metadata_uris']) as List).cast<String>()),
    parentId: (json['parent_id'] as Map).cast<String, dynamic>(),
    royaltyAddress: json['royalty_address'] == null
        ? null
        : (json['royalty_address'] as String),
    royaltyTenThousandths: json['royalty_ten_thousandths'] == null
        ? null
        : (json['royalty_ten_thousandths'] as int),
  );

  Map<String, dynamic> toJson() => {
    if (dataHash != null) 'data_hash': dataHash,
    if (dataUris != null) 'data_uris': dataUris,
    if (editionNumber != null) 'edition_number': editionNumber,
    if (editionTotal != null) 'edition_total': editionTotal,
    if (licenseHash != null) 'license_hash': licenseHash,
    if (licenseUris != null) 'license_uris': licenseUris,
    if (metadataHash != null) 'metadata_hash': metadataHash,
    if (metadataUris != null) 'metadata_uris': metadataUris,
    'parent_id': parentId,
    if (royaltyAddress != null) 'royalty_address': royaltyAddress,
    if (royaltyTenThousandths != null)
      'royalty_ten_thousandths': royaltyTenThousandths,
  };
}

/// Mint a new option
class MintOption {
  MintOption({
    this.autoSubmit,
    required this.expirationSeconds,
    required this.fee,
    required this.strike,
    required this.underlying,
  });

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Expiration time in seconds
  final int expirationSeconds;

  /// Transaction fee
  final BigInt fee;

  /// Strike price asset
  final OptionAsset strike;

  /// Underlying asset
  final OptionAsset underlying;

  factory MintOption.fromJson(Map<String, dynamic> json) => MintOption(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    expirationSeconds: json['expiration_seconds'] as int,
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    strike: OptionAsset.fromJson(
      (json['strike'] as Map).cast<String, dynamic>(),
    ),
    underlying: OptionAsset.fromJson(
      (json['underlying'] as Map).cast<String, dynamic>(),
    ),
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'expiration_seconds': expirationSeconds,
    'fee': fee.toString(),
    'strike': strike.toJson(),
    'underlying': underlying.toJson(),
  };
}

/// Response for minting an option
class MintOptionResponse {
  MintOptionResponse({
    required this.coinSpends,
    required this.optionId,
    required this.summary,
  });

  /// Coin spends in the transaction
  final List<CoinSpendJson> coinSpends;

  /// ID of the minted option
  final String optionId;

  /// Transaction summary
  final TransactionSummary summary;

  factory MintOptionResponse.fromJson(Map<String, dynamic> json) =>
      MintOptionResponse(
        coinSpends: ((json['coin_spends']) as List)
            .map(
              (e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
        optionId: json['option_id'] as String,
        summary: TransactionSummary.fromJson(
          (json['summary'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
    'option_id': optionId,
    'summary': summary.toJson(),
  };
}

/// Send multiple assets in one transaction
class MultiSend {
  MultiSend({this.autoSubmit, required this.fee, required this.payments});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// List of payments to make
  final List<Payment> payments;

  factory MultiSend.fromJson(Map<String, dynamic> json) => MultiSend(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    payments: ((json['payments']) as List)
        .map((e) => Payment.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'payments': payments.map((e) => e.toJson()).toList(),
  };
}

class NewNftUri {
  NewNftUri({required this.kind, required this.uri});

  /// The type of URI
  final NftUriKind kind;

  /// The URI to add
  final String uri;

  factory NewNftUri.fromJson(Map<String, dynamic> json) => NewNftUri(
    kind: NftUriKind.fromJson(json['kind'] as String),
    uri: json['uri'] as String,
  );

  Map<String, dynamic> toJson() => {'kind': kind.toJson(), 'uri': uri};
}

class NftCollectionRecord {
  NftCollectionRecord({
    required this.collectionId,
    required this.didId,
    this.icon,
    required this.metadataCollectionId,
    this.name,
    required this.visible,
  });

  final String collectionId;

  final String didId;

  final String? icon;

  final String metadataCollectionId;

  final String? name;

  final bool visible;

  factory NftCollectionRecord.fromJson(Map<String, dynamic> json) =>
      NftCollectionRecord(
        collectionId: json['collection_id'] as String,
        didId: json['did_id'] as String,
        icon: json['icon'] == null ? null : (json['icon'] as String),
        metadataCollectionId: json['metadata_collection_id'] as String,
        name: json['name'] == null ? null : (json['name'] as String),
        visible: json['visible'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'collection_id': collectionId,
    'did_id': didId,
    if (icon != null) 'icon': icon,
    'metadata_collection_id': metadataCollectionId,
    if (name != null) 'name': name,
    'visible': visible,
  };
}

class NftData {
  NftData({
    this.blob,
    required this.hashMatches,
    required this.metadataHashMatches,
    this.metadataJson,
    this.mimeType,
  });

  final String? blob;

  final bool hashMatches;

  final bool metadataHashMatches;

  final String? metadataJson;

  final String? mimeType;

  factory NftData.fromJson(Map<String, dynamic> json) => NftData(
    blob: json['blob'] == null ? null : (json['blob'] as String),
    hashMatches: json['hash_matches'] as bool,
    metadataHashMatches: json['metadata_hash_matches'] as bool,
    metadataJson: json['metadata_json'] == null
        ? null
        : (json['metadata_json'] as String),
    mimeType: json['mime_type'] == null ? null : (json['mime_type'] as String),
  );

  Map<String, dynamic> toJson() => {
    if (blob != null) 'blob': blob,
    'hash_matches': hashMatches,
    'metadata_hash_matches': metadataHashMatches,
    if (metadataJson != null) 'metadata_json': metadataJson,
    if (mimeType != null) 'mime_type': mimeType,
  };
}

/// Individual NFT to mint
class NftMint {
  NftMint({
    this.address,
    this.dataHash,
    this.dataUris,
    this.editionNumber,
    this.editionTotal,
    this.licenseHash,
    this.licenseUris,
    this.metadataHash,
    this.metadataUris,
    this.royaltyAddress,
    this.royaltyTenThousandths,
  });

  /// Optional target address
  final String? address;

  /// Data hash
  final String? dataHash;

  /// Data URIs
  final List<String>? dataUris;

  /// Edition number
  final int? editionNumber;

  /// Total editions
  final int? editionTotal;

  /// License hash
  final String? licenseHash;

  /// License URIs
  final List<String>? licenseUris;

  /// Metadata hash
  final String? metadataHash;

  /// Metadata URIs
  final List<String>? metadataUris;

  /// Royalty payment address
  final String? royaltyAddress;

  /// Royalty percentage in ten-thousandths (e.g., 300 = 3%)
  final int? royaltyTenThousandths;

  factory NftMint.fromJson(Map<String, dynamic> json) => NftMint(
    address: json['address'] == null ? null : (json['address'] as String),
    dataHash: json['data_hash'] == null ? null : (json['data_hash'] as String),
    dataUris: json['data_uris'] == null
        ? null
        : (((json['data_uris']) as List).cast<String>()),
    editionNumber: json['edition_number'] == null
        ? null
        : (json['edition_number'] as int),
    editionTotal: json['edition_total'] == null
        ? null
        : (json['edition_total'] as int),
    licenseHash: json['license_hash'] == null
        ? null
        : (json['license_hash'] as String),
    licenseUris: json['license_uris'] == null
        ? null
        : (((json['license_uris']) as List).cast<String>()),
    metadataHash: json['metadata_hash'] == null
        ? null
        : (json['metadata_hash'] as String),
    metadataUris: json['metadata_uris'] == null
        ? null
        : (((json['metadata_uris']) as List).cast<String>()),
    royaltyAddress: json['royalty_address'] == null
        ? null
        : (json['royalty_address'] as String),
    royaltyTenThousandths: json['royalty_ten_thousandths'] == null
        ? null
        : (json['royalty_ten_thousandths'] as int),
  );

  Map<String, dynamic> toJson() => {
    if (address != null) 'address': address,
    if (dataHash != null) 'data_hash': dataHash,
    if (dataUris != null) 'data_uris': dataUris,
    if (editionNumber != null) 'edition_number': editionNumber,
    if (editionTotal != null) 'edition_total': editionTotal,
    if (licenseHash != null) 'license_hash': licenseHash,
    if (licenseUris != null) 'license_uris': licenseUris,
    if (metadataHash != null) 'metadata_hash': metadataHash,
    if (metadataUris != null) 'metadata_uris': metadataUris,
    if (royaltyAddress != null) 'royalty_address': royaltyAddress,
    if (royaltyTenThousandths != null)
      'royalty_ten_thousandths': royaltyTenThousandths,
  };
}

class NftRecord {
  NftRecord({
    required this.address,
    required this.coinId,
    this.collectionId,
    this.collectionName,
    this.createdHeight,
    this.createdTimestamp,
    this.dataHash,
    required this.dataUris,
    this.editionNumber,
    this.editionTotal,
    this.iconUrl,
    required this.launcherId,
    this.licenseHash,
    required this.licenseUris,
    this.metadataHash,
    required this.metadataUris,
    this.minterDid,
    this.name,
    this.ownerDid,
    required this.royaltyAddress,
    required this.royaltyTenThousandths,
    required this.sensitiveContent,
    this.specialUseType,
    required this.visible,
  });

  final String address;

  final String coinId;

  final String? collectionId;

  final String? collectionName;

  final int? createdHeight;

  final int? createdTimestamp;

  final String? dataHash;

  final List<String> dataUris;

  final int? editionNumber;

  final int? editionTotal;

  final String? iconUrl;

  final String launcherId;

  final String? licenseHash;

  final List<String> licenseUris;

  final String? metadataHash;

  final List<String> metadataUris;

  final String? minterDid;

  final String? name;

  final String? ownerDid;

  final String royaltyAddress;

  final int royaltyTenThousandths;

  final bool sensitiveContent;

  final NftSpecialUseType? specialUseType;

  final bool visible;

  factory NftRecord.fromJson(Map<String, dynamic> json) => NftRecord(
    address: json['address'] as String,
    coinId: json['coin_id'] as String,
    collectionId: json['collection_id'] == null
        ? null
        : (json['collection_id'] as String),
    collectionName: json['collection_name'] == null
        ? null
        : (json['collection_name'] as String),
    createdHeight: json['created_height'] == null
        ? null
        : (json['created_height'] as int),
    createdTimestamp: json['created_timestamp'] == null
        ? null
        : (json['created_timestamp'] as int),
    dataHash: json['data_hash'] == null ? null : (json['data_hash'] as String),
    dataUris: ((json['data_uris']) as List).cast<String>(),
    editionNumber: json['edition_number'] == null
        ? null
        : (json['edition_number'] as int),
    editionTotal: json['edition_total'] == null
        ? null
        : (json['edition_total'] as int),
    iconUrl: json['icon_url'] == null ? null : (json['icon_url'] as String),
    launcherId: json['launcher_id'] as String,
    licenseHash: json['license_hash'] == null
        ? null
        : (json['license_hash'] as String),
    licenseUris: ((json['license_uris']) as List).cast<String>(),
    metadataHash: json['metadata_hash'] == null
        ? null
        : (json['metadata_hash'] as String),
    metadataUris: ((json['metadata_uris']) as List).cast<String>(),
    minterDid: json['minter_did'] == null
        ? null
        : (json['minter_did'] as String),
    name: json['name'] == null ? null : (json['name'] as String),
    ownerDid: json['owner_did'] == null ? null : (json['owner_did'] as String),
    royaltyAddress: json['royalty_address'] as String,
    royaltyTenThousandths: json['royalty_ten_thousandths'] as int,
    sensitiveContent: json['sensitive_content'] as bool,
    specialUseType: json['special_use_type'] == null
        ? null
        : (NftSpecialUseType.fromJson(json['special_use_type'] as String)),
    visible: json['visible'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'coin_id': coinId,
    if (collectionId != null) 'collection_id': collectionId,
    if (collectionName != null) 'collection_name': collectionName,
    if (createdHeight != null) 'created_height': createdHeight,
    if (createdTimestamp != null) 'created_timestamp': createdTimestamp,
    if (dataHash != null) 'data_hash': dataHash,
    'data_uris': dataUris,
    if (editionNumber != null) 'edition_number': editionNumber,
    if (editionTotal != null) 'edition_total': editionTotal,
    if (iconUrl != null) 'icon_url': iconUrl,
    'launcher_id': launcherId,
    if (licenseHash != null) 'license_hash': licenseHash,
    'license_uris': licenseUris,
    if (metadataHash != null) 'metadata_hash': metadataHash,
    'metadata_uris': metadataUris,
    if (minterDid != null) 'minter_did': minterDid,
    if (name != null) 'name': name,
    if (ownerDid != null) 'owner_did': ownerDid,
    'royalty_address': royaltyAddress,
    'royalty_ten_thousandths': royaltyTenThousandths,
    'sensitive_content': sensitiveContent,
    if (specialUseType != null) 'special_use_type': specialUseType!.toJson(),
    'visible': visible,
  };
}

class NftRoyalty {
  NftRoyalty({required this.royaltyAddress, required this.royaltyBasisPoints});

  final String royaltyAddress;

  final int royaltyBasisPoints;

  factory NftRoyalty.fromJson(Map<String, dynamic> json) => NftRoyalty(
    royaltyAddress: json['royalty_address'] as String,
    royaltyBasisPoints: json['royalty_basis_points'] as int,
  );

  Map<String, dynamic> toJson() => {
    'royalty_address': royaltyAddress,
    'royalty_basis_points': royaltyBasisPoints,
  };
}

class NftTransfer {
  NftTransfer({this.didId});

  final Map<String, dynamic>? didId;

  factory NftTransfer.fromJson(Map<String, dynamic> json) => NftTransfer(
    didId: json['did_id'] == null
        ? null
        : ((json['did_id'] as Map).cast<String, dynamic>()),
  );

  Map<String, dynamic> toJson() => {if (didId != null) 'did_id': didId};
}

/// Normalize DIDs to latest state
class NormalizeDids {
  NormalizeDids({this.autoSubmit, required this.didIds, required this.fee});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// DID IDs to normalize
  final List<String> didIds;

  /// Transaction fee
  final BigInt fee;

  factory NormalizeDids.fromJson(Map<String, dynamic> json) => NormalizeDids(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    didIds: ((json['did_ids']) as List).cast<String>(),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'did_ids': didIds,
    'fee': fee.toString(),
  };
}

/// Asset amount in an offer
class OfferAmount {
  OfferAmount({required this.amount, this.assetId, this.hiddenPuzzleHash});

  /// Amount of the asset
  final BigInt amount;

  /// Optional asset ID (null for XCH)
  final String? assetId;

  /// Optional hidden puzzle hash for privacy
  final String? hiddenPuzzleHash;

  factory OfferAmount.fromJson(Map<String, dynamic> json) => OfferAmount(
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
    hiddenPuzzleHash: json['hidden_puzzle_hash'] == null
        ? null
        : (json['hidden_puzzle_hash'] as String),
  );

  Map<String, dynamic> toJson() => {
    'amount': amount.toString(),
    if (assetId != null) 'asset_id': assetId,
    if (hiddenPuzzleHash != null) 'hidden_puzzle_hash': hiddenPuzzleHash,
  };
}

class OfferAsset {
  OfferAsset({
    required this.amount,
    required this.asset,
    this.nftRoyalty,
    this.optionAssets,
    required this.royalty,
  });

  final BigInt amount;

  final Asset asset;

  final NftRoyalty? nftRoyalty;

  final OptionAssets? optionAssets;

  final BigInt royalty;

  factory OfferAsset.fromJson(Map<String, dynamic> json) => OfferAsset(
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    asset: Asset.fromJson((json['asset'] as Map).cast<String, dynamic>()),
    nftRoyalty: json['nft_royalty'] == null
        ? null
        : (NftRoyalty.fromJson(
            (json['nft_royalty'] as Map).cast<String, dynamic>(),
          )),
    optionAssets: json['option_assets'] == null
        ? null
        : (OptionAssets.fromJson(
            (json['option_assets'] as Map).cast<String, dynamic>(),
          )),
    royalty: ((json['royalty']) is String
        ? BigInt.parse(json['royalty'] as String)
        : BigInt.from((json['royalty'] as num).toInt())),
  );

  Map<String, dynamic> toJson() => {
    'amount': amount.toString(),
    'asset': asset.toJson(),
    if (nftRoyalty != null) 'nft_royalty': nftRoyalty!.toJson(),
    if (optionAssets != null) 'option_assets': optionAssets!.toJson(),
    'royalty': royalty.toString(),
  };
}

class OfferRecord {
  OfferRecord({
    required this.creationTimestamp,
    required this.offer,
    required this.offerId,
    required this.status,
    required this.summary,
  });

  final int creationTimestamp;

  final String offer;

  final String offerId;

  final OfferRecordStatus status;

  final OfferSummary summary;

  factory OfferRecord.fromJson(Map<String, dynamic> json) => OfferRecord(
    creationTimestamp: json['creation_timestamp'] as int,
    offer: json['offer'] as String,
    offerId: json['offer_id'] as String,
    status: OfferRecordStatus.fromJson(json['status'] as String),
    summary: OfferSummary.fromJson(
      (json['summary'] as Map).cast<String, dynamic>(),
    ),
  );

  Map<String, dynamic> toJson() => {
    'creation_timestamp': creationTimestamp,
    'offer': offer,
    'offer_id': offerId,
    'status': status.toJson(),
    'summary': summary.toJson(),
  };
}

class OfferSummary {
  OfferSummary({
    this.expirationHeight,
    this.expirationTimestamp,
    required this.fee,
    required this.maker,
    required this.taker,
  });

  final int? expirationHeight;

  final int? expirationTimestamp;

  final BigInt fee;

  final List<OfferAsset> maker;

  final List<OfferAsset> taker;

  factory OfferSummary.fromJson(Map<String, dynamic> json) => OfferSummary(
    expirationHeight: json['expiration_height'] == null
        ? null
        : (json['expiration_height'] as int),
    expirationTimestamp: json['expiration_timestamp'] == null
        ? null
        : (json['expiration_timestamp'] as int),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    maker: ((json['maker']) as List)
        .map((e) => OfferAsset.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    taker: ((json['taker']) as List)
        .map((e) => OfferAsset.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (expirationHeight != null) 'expiration_height': expirationHeight,
    if (expirationTimestamp != null)
      'expiration_timestamp': expirationTimestamp,
    'fee': fee.toString(),
    'maker': maker.map((e) => e.toJson()).toList(),
    'taker': taker.map((e) => e.toJson()).toList(),
  };
}

/// Asset specification for options
class OptionAsset {
  OptionAsset({required this.amount, this.assetId});

  /// Amount
  final BigInt amount;

  /// Asset ID (null for XCH)
  final String? assetId;

  factory OptionAsset.fromJson(Map<String, dynamic> json) => OptionAsset(
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
  );

  Map<String, dynamic> toJson() => {
    'amount': amount.toString(),
    if (assetId != null) 'asset_id': assetId,
  };
}

class OptionAssets {
  OptionAssets({
    required this.expirationSeconds,
    required this.strikeAmount,
    required this.strikeAsset,
    required this.underlyingAmount,
    required this.underlyingAsset,
  });

  final int expirationSeconds;

  final BigInt strikeAmount;

  final Asset strikeAsset;

  final BigInt underlyingAmount;

  final Asset underlyingAsset;

  factory OptionAssets.fromJson(Map<String, dynamic> json) => OptionAssets(
    expirationSeconds: json['expiration_seconds'] as int,
    strikeAmount: ((json['strike_amount']) is String
        ? BigInt.parse(json['strike_amount'] as String)
        : BigInt.from((json['strike_amount'] as num).toInt())),
    strikeAsset: Asset.fromJson(
      (json['strike_asset'] as Map).cast<String, dynamic>(),
    ),
    underlyingAmount: ((json['underlying_amount']) is String
        ? BigInt.parse(json['underlying_amount'] as String)
        : BigInt.from((json['underlying_amount'] as num).toInt())),
    underlyingAsset: Asset.fromJson(
      (json['underlying_asset'] as Map).cast<String, dynamic>(),
    ),
  );

  Map<String, dynamic> toJson() => {
    'expiration_seconds': expirationSeconds,
    'strike_amount': strikeAmount.toString(),
    'strike_asset': strikeAsset.toJson(),
    'underlying_amount': underlyingAmount.toString(),
    'underlying_asset': underlyingAsset.toJson(),
  };
}

class OptionRecord {
  OptionRecord({
    required this.address,
    required this.amount,
    required this.coinId,
    this.createdHeight,
    this.createdTimestamp,
    required this.expirationSeconds,
    required this.launcherId,
    this.name,
    required this.strikeAmount,
    required this.strikeAsset,
    required this.underlyingAmount,
    required this.underlyingAsset,
    required this.underlyingCoinId,
    required this.visible,
  });

  final String address;

  final BigInt amount;

  final String coinId;

  final int? createdHeight;

  final int? createdTimestamp;

  final int expirationSeconds;

  final String launcherId;

  final String? name;

  final BigInt strikeAmount;

  final Asset strikeAsset;

  final BigInt underlyingAmount;

  final Asset underlyingAsset;

  final String underlyingCoinId;

  final bool visible;

  factory OptionRecord.fromJson(Map<String, dynamic> json) => OptionRecord(
    address: json['address'] as String,
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    coinId: json['coin_id'] as String,
    createdHeight: json['created_height'] == null
        ? null
        : (json['created_height'] as int),
    createdTimestamp: json['created_timestamp'] == null
        ? null
        : (json['created_timestamp'] as int),
    expirationSeconds: json['expiration_seconds'] as int,
    launcherId: json['launcher_id'] as String,
    name: json['name'] == null ? null : (json['name'] as String),
    strikeAmount: ((json['strike_amount']) is String
        ? BigInt.parse(json['strike_amount'] as String)
        : BigInt.from((json['strike_amount'] as num).toInt())),
    strikeAsset: Asset.fromJson(
      (json['strike_asset'] as Map).cast<String, dynamic>(),
    ),
    underlyingAmount: ((json['underlying_amount']) is String
        ? BigInt.parse(json['underlying_amount'] as String)
        : BigInt.from((json['underlying_amount'] as num).toInt())),
    underlyingAsset: Asset.fromJson(
      (json['underlying_asset'] as Map).cast<String, dynamic>(),
    ),
    underlyingCoinId: json['underlying_coin_id'] as String,
    visible: json['visible'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    'coin_id': coinId,
    if (createdHeight != null) 'created_height': createdHeight,
    if (createdTimestamp != null) 'created_timestamp': createdTimestamp,
    'expiration_seconds': expirationSeconds,
    'launcher_id': launcherId,
    if (name != null) 'name': name,
    'strike_amount': strikeAmount.toString(),
    'strike_asset': strikeAsset.toJson(),
    'underlying_amount': underlyingAmount.toString(),
    'underlying_asset': underlyingAsset.toJson(),
    'underlying_coin_id': underlyingCoinId,
    'visible': visible,
  };
}

/// Individual payment in a multi-send transaction
class Payment {
  Payment({
    required this.address,
    required this.amount,
    this.assetId,
    this.memos,
  });

  /// Recipient address
  final String address;

  /// Amount to send
  final BigInt amount;

  /// Optional asset ID (null for XCH)
  final String? assetId;

  /// Optional memos
  final List<String>? memos;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    address: json['address'] as String,
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
    memos: json['memos'] == null
        ? null
        : (((json['memos']) as List).cast<String>()),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    if (assetId != null) 'asset_id': assetId,
    if (memos != null) 'memos': memos,
  };
}

class PeerRecord {
  PeerRecord({
    required this.ipAddr,
    required this.peakHeight,
    required this.port,
    required this.userManaged,
  });

  final String ipAddr;

  final int peakHeight;

  final int port;

  final bool userManaged;

  factory PeerRecord.fromJson(Map<String, dynamic> json) => PeerRecord(
    ipAddr: json['ip_addr'] as String,
    peakHeight: json['peak_height'] as int,
    port: json['port'] as int,
    userManaged: json['user_managed'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'ip_addr': ipAddr,
    'peak_height': peakHeight,
    'port': port,
    'user_managed': userManaged,
  };
}

class PendingTransactionRecord {
  PendingTransactionRecord({
    required this.fee,
    this.submittedAt,
    required this.transactionId,
  });

  final BigInt fee;

  final int? submittedAt;

  final String transactionId;

  factory PendingTransactionRecord.fromJson(Map<String, dynamic> json) =>
      PendingTransactionRecord(
        fee: ((json['fee']) is String
            ? BigInt.parse(json['fee'] as String)
            : BigInt.from((json['fee'] as num).toInt())),
        submittedAt: json['submitted_at'] == null
            ? null
            : (json['submitted_at'] as int),
        transactionId: json['transaction_id'] as String,
      );

  Map<String, dynamic> toJson() => {
    'fee': fee.toString(),
    if (submittedAt != null) 'submitted_at': submittedAt,
    'transaction_id': transactionId,
  };
}

/// Perform database maintenance operations
class PerformDatabaseMaintenance {
  PerformDatabaseMaintenance({required this.forceVacuum});

  /// Whether to force a full vacuum (may take longer)
  final bool forceVacuum;

  factory PerformDatabaseMaintenance.fromJson(Map<String, dynamic> json) =>
      PerformDatabaseMaintenance(forceVacuum: json['force_vacuum'] as bool);

  Map<String, dynamic> toJson() => {'force_vacuum': forceVacuum};
}

/// Response with maintenance operation statistics
class PerformDatabaseMaintenanceResponse {
  PerformDatabaseMaintenanceResponse({
    required this.analyzeDurationMs,
    required this.pagesVacuumed,
    required this.totalDurationMs,
    required this.vacuumDurationMs,
    required this.walCheckpointDurationMs,
    required this.walPagesCheckpointed,
  });

  /// Time spent analyzing in milliseconds
  final int analyzeDurationMs;

  /// Number of pages reclaimed by vacuum
  final int pagesVacuumed;

  /// Total maintenance duration in milliseconds
  final int totalDurationMs;

  /// Time spent vacuuming in milliseconds
  final int vacuumDurationMs;

  /// Time spent checkpointing WAL in milliseconds
  final int walCheckpointDurationMs;

  /// Number of WAL pages checkpointed
  final int walPagesCheckpointed;

  factory PerformDatabaseMaintenanceResponse.fromJson(
    Map<String, dynamic> json,
  ) => PerformDatabaseMaintenanceResponse(
    analyzeDurationMs: json['analyze_duration_ms'] as int,
    pagesVacuumed: json['pages_vacuumed'] as int,
    totalDurationMs: json['total_duration_ms'] as int,
    vacuumDurationMs: json['vacuum_duration_ms'] as int,
    walCheckpointDurationMs: json['wal_checkpoint_duration_ms'] as int,
    walPagesCheckpointed: json['wal_pages_checkpointed'] as int,
  );

  Map<String, dynamic> toJson() => {
    'analyze_duration_ms': analyzeDurationMs,
    'pages_vacuumed': pagesVacuumed,
    'total_duration_ms': totalDurationMs,
    'vacuum_duration_ms': vacuumDurationMs,
    'wal_checkpoint_duration_ms': walCheckpointDurationMs,
    'wal_pages_checkpointed': walPagesCheckpointed,
  };
}

/// Re-download an `NFT`'s data and metadata from its URIs
class RedownloadNft {
  RedownloadNft({required this.nftId});

  /// The `NFT` ID to re-download
  final String nftId;

  factory RedownloadNft.fromJson(Map<String, dynamic> json) =>
      RedownloadNft(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

/// Response after re-downloading an `NFT`
class RedownloadNftResponse {
  const RedownloadNftResponse();

  factory RedownloadNftResponse.fromJson(Map<String, dynamic> json) =>
      RedownloadNftResponse();

  Map<String, dynamic> toJson() => {};
}

/// Remove a peer from the connection list
class RemovePeer {
  RemovePeer({required this.ban, required this.ip});

  /// Whether to ban the peer from reconnecting
  final bool ban;

  /// IP address or hostname of the peer
  final String ip;

  factory RemovePeer.fromJson(Map<String, dynamic> json) =>
      RemovePeer(ban: json['ban'] as bool, ip: json['ip'] as String);

  Map<String, dynamic> toJson() => {'ban': ban, 'ip': ip};
}

/// Rename a wallet key
class RenameKey {
  RenameKey({required this.fingerprint, required this.name});

  /// Wallet fingerprint
  final int fingerprint;

  /// New display name
  final String name;

  factory RenameKey.fromJson(Map<String, dynamic> json) => RenameKey(
    fingerprint: json['fingerprint'] as int,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {'fingerprint': fingerprint, 'name': name};
}

/// Response for key rename
class RenameKeyResponse {
  const RenameKeyResponse();

  factory RenameKeyResponse.fromJson(Map<String, dynamic> json) =>
      RenameKeyResponse();

  Map<String, dynamic> toJson() => {};
}

/// Resynchronize wallet data with the blockchain
class Resync {
  Resync({
    this.deleteAddresses,
    this.deleteAssets,
    this.deleteBlocks,
    this.deleteCoins,
    this.deleteFiles,
    this.deleteOffers,
    required this.fingerprint,
  });

  /// Delete all address records during resync
  final bool? deleteAddresses;

  /// Delete all asset records during resync
  final bool? deleteAssets;

  /// Delete all block records during resync
  final bool? deleteBlocks;

  /// Delete all coin records during resync
  final bool? deleteCoins;

  /// Delete all file records during resync
  final bool? deleteFiles;

  /// Delete all offer records during resync
  final bool? deleteOffers;

  /// The fingerprint of the wallet to resync
  final int fingerprint;

  factory Resync.fromJson(Map<String, dynamic> json) => Resync(
    deleteAddresses: json['delete_addresses'] == null
        ? null
        : (json['delete_addresses'] as bool),
    deleteAssets: json['delete_assets'] == null
        ? null
        : (json['delete_assets'] as bool),
    deleteBlocks: json['delete_blocks'] == null
        ? null
        : (json['delete_blocks'] as bool),
    deleteCoins: json['delete_coins'] == null
        ? null
        : (json['delete_coins'] as bool),
    deleteFiles: json['delete_files'] == null
        ? null
        : (json['delete_files'] as bool),
    deleteOffers: json['delete_offers'] == null
        ? null
        : (json['delete_offers'] as bool),
    fingerprint: json['fingerprint'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (deleteAddresses != null) 'delete_addresses': deleteAddresses,
    if (deleteAssets != null) 'delete_assets': deleteAssets,
    if (deleteBlocks != null) 'delete_blocks': deleteBlocks,
    if (deleteCoins != null) 'delete_coins': deleteCoins,
    if (deleteFiles != null) 'delete_files': deleteFiles,
    if (deleteOffers != null) 'delete_offers': deleteOffers,
    'fingerprint': fingerprint,
  };
}

/// Resynchronize a `CAT` token's metadata from an external source
class ResyncCat {
  ResyncCat({required this.assetId});

  /// The asset ID of the `CAT` token to resynchronize
  final String assetId;

  factory ResyncCat.fromJson(Map<String, dynamic> json) =>
      ResyncCat(assetId: json['asset_id'] as String);

  Map<String, dynamic> toJson() => {'asset_id': assetId};
}

/// Response after resynchronizing a `CAT` token
class ResyncCatResponse {
  const ResyncCatResponse();

  factory ResyncCatResponse.fromJson(Map<String, dynamic> json) =>
      ResyncCatResponse();

  Map<String, dynamic> toJson() => {};
}

/// Response from resynchronizing the wallet
class ResyncResponse {
  const ResyncResponse();

  factory ResyncResponse.fromJson(Map<String, dynamic> json) =>
      ResyncResponse();

  Map<String, dynamic> toJson() => {};
}

/// Save a theme NFT to the wallet
class SaveUserTheme {
  SaveUserTheme({required this.nftId});

  /// NFT ID of the theme
  final String nftId;

  factory SaveUserTheme.fromJson(Map<String, dynamic> json) =>
      SaveUserTheme(nftId: json['nft_id'] as String);

  Map<String, dynamic> toJson() => {'nft_id': nftId};
}

class SaveUserThemeResponse {
  const SaveUserThemeResponse();

  factory SaveUserThemeResponse.fromJson(Map<String, dynamic> json) =>
      SaveUserThemeResponse();

  Map<String, dynamic> toJson() => {};
}

class SecretKeyInfo {
  SecretKeyInfo({this.mnemonic, required this.secretKey});

  final String? mnemonic;

  final String secretKey;

  factory SecretKeyInfo.fromJson(Map<String, dynamic> json) => SecretKeyInfo(
    mnemonic: json['mnemonic'] == null ? null : (json['mnemonic'] as String),
    secretKey: json['secret_key'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (mnemonic != null) 'mnemonic': mnemonic,
    'secret_key': secretKey,
  };
}

class SendAction {
  SendAction({
    required this.address,
    required this.amount,
    this.clawback,
    required this.id,
    this.memos,
  });

  /// The address to send to, in bech32 format
  final String address;

  /// The amount to send, in mojos
  final BigInt amount;

  /// Optional clawback timestamp (seconds since epoch)
  final int? clawback;

  /// The id of the asset to send
  final Map<String, dynamic> id;

  /// A list of memos (encoded as hex) to include in the transaction
  final List<String>? memos;

  factory SendAction.fromJson(Map<String, dynamic> json) => SendAction(
    address: json['address'] as String,
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    clawback: json['clawback'] == null ? null : (json['clawback'] as int),
    id: (json['id'] as Map).cast<String, dynamic>(),
    memos: json['memos'] == null
        ? null
        : (((json['memos']) as List).cast<String>()),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    if (clawback != null) 'clawback': clawback,
    'id': id,
    if (memos != null) 'memos': memos,
  };
}

/// Send CAT tokens to an address
class SendCat {
  SendCat({
    required this.address,
    required this.amount,
    required this.assetId,
    this.autoSubmit,
    this.clawback,
    required this.fee,
    this.includeHint,
    this.memos,
  });

  /// Recipient address
  final String address;

  /// Amount to send
  final BigInt amount;

  /// Asset ID of the CAT
  final String assetId;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Optional clawback timestamp
  final int? clawback;

  /// Transaction fee
  final BigInt fee;

  /// Whether to include the CAT hint
  final bool? includeHint;

  /// Optional memos
  final List<String>? memos;

  factory SendCat.fromJson(Map<String, dynamic> json) => SendCat(
    address: json['address'] as String,
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    assetId: json['asset_id'] as String,
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    clawback: json['clawback'] == null ? null : (json['clawback'] as int),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    includeHint: json['include_hint'] == null
        ? null
        : (json['include_hint'] as bool),
    memos: json['memos'] == null
        ? null
        : (((json['memos']) as List).cast<String>()),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    'asset_id': assetId,
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    if (clawback != null) 'clawback': clawback,
    'fee': fee.toString(),
    if (includeHint != null) 'include_hint': includeHint,
    if (memos != null) 'memos': memos,
  };
}

/// Send a transaction immediately
class SendTransactionImmediately {
  SendTransactionImmediately({required this.spendBundle});

  /// Spend bundle to send
  final SpendBundle spendBundle;

  factory SendTransactionImmediately.fromJson(Map<String, dynamic> json) =>
      SendTransactionImmediately(
        spendBundle: SpendBundle.fromJson(
          (json['spend_bundle'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {'spend_bundle': spendBundle.toJson()};
}

/// Response with transaction status
class SendTransactionImmediatelyResponse {
  SendTransactionImmediatelyResponse({this.error, required this.status});

  /// Optional error message
  final String? error;

  /// Status code
  final int status;

  factory SendTransactionImmediatelyResponse.fromJson(
    Map<String, dynamic> json,
  ) => SendTransactionImmediatelyResponse(
    error: json['error'] == null ? null : (json['error'] as String),
    status: json['status'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (error != null) 'error': error,
    'status': status,
  };
}

/// Send XCH to an address
class SendXch {
  SendXch({
    required this.address,
    required this.amount,
    this.autoSubmit,
    this.clawback,
    required this.fee,
    this.memos,
  });

  /// Recipient address
  final String address;

  /// Amount to send
  final BigInt amount;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Optional clawback timestamp (seconds since epoch)
  final int? clawback;

  /// Transaction fee
  final BigInt fee;

  /// Optional memos
  final List<String>? memos;

  factory SendXch.fromJson(Map<String, dynamic> json) => SendXch(
    address: json['address'] as String,
    amount: ((json['amount']) is String
        ? BigInt.parse(json['amount'] as String)
        : BigInt.from((json['amount'] as num).toInt())),
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    clawback: json['clawback'] == null ? null : (json['clawback'] as int),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    memos: json['memos'] == null
        ? null
        : (((json['memos']) as List).cast<String>()),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    if (clawback != null) 'clawback': clawback,
    'fee': fee.toString(),
    if (memos != null) 'memos': memos,
  };
}

/// Set the change address for transactions
class SetChangeAddress {
  SetChangeAddress({this.changeAddress, required this.fingerprint});

  /// Change address (null to use default derivation)
  final String? changeAddress;

  /// Wallet fingerprint
  final int fingerprint;

  factory SetChangeAddress.fromJson(Map<String, dynamic> json) =>
      SetChangeAddress(
        changeAddress: json['change_address'] == null
            ? null
            : (json['change_address'] as String),
        fingerprint: json['fingerprint'] as int,
      );

  Map<String, dynamic> toJson() => {
    if (changeAddress != null) 'change_address': changeAddress,
    'fingerprint': fingerprint,
  };
}

/// Enable or disable delta sync
class SetDeltaSync {
  SetDeltaSync({required this.deltaSync});

  /// Whether to enable delta sync
  final bool deltaSync;

  factory SetDeltaSync.fromJson(Map<String, dynamic> json) =>
      SetDeltaSync(deltaSync: json['delta_sync'] as bool);

  Map<String, dynamic> toJson() => {'delta_sync': deltaSync};
}

/// Override delta sync settings for a specific wallet
class SetDeltaSyncOverride {
  SetDeltaSyncOverride({this.deltaSync, required this.fingerprint});

  /// Delta sync setting (null to use default)
  final bool? deltaSync;

  /// Wallet fingerprint
  final int fingerprint;

  factory SetDeltaSyncOverride.fromJson(Map<String, dynamic> json) =>
      SetDeltaSyncOverride(
        deltaSync: json['delta_sync'] == null
            ? null
            : (json['delta_sync'] as bool),
        fingerprint: json['fingerprint'] as int,
      );

  Map<String, dynamic> toJson() => {
    if (deltaSync != null) 'delta_sync': deltaSync,
    'fingerprint': fingerprint,
  };
}

/// Enable or disable automatic peer discovery
class SetDiscoverPeers {
  SetDiscoverPeers({required this.discoverPeers});

  /// Whether to enable peer discovery
  final bool discoverPeers;

  factory SetDiscoverPeers.fromJson(Map<String, dynamic> json) =>
      SetDiscoverPeers(discoverPeers: json['discover_peers'] as bool);

  Map<String, dynamic> toJson() => {'discover_peers': discoverPeers};
}

/// Set the active network
class SetNetwork {
  SetNetwork({required this.name});

  /// Network name to switch to
  final String name;

  factory SetNetwork.fromJson(Map<String, dynamic> json) =>
      SetNetwork(name: json['name'] as String);

  Map<String, dynamic> toJson() => {'name': name};
}

/// Override network settings for a specific wallet
class SetNetworkOverride {
  SetNetworkOverride({required this.fingerprint, this.name});

  /// Wallet fingerprint to override network for
  final int fingerprint;

  /// Network name (null to reset to default)
  final String? name;

  factory SetNetworkOverride.fromJson(Map<String, dynamic> json) =>
      SetNetworkOverride(
        fingerprint: json['fingerprint'] as int,
        name: json['name'] == null ? null : (json['name'] as String),
      );

  Map<String, dynamic> toJson() => {
    'fingerprint': fingerprint,
    if (name != null) 'name': name,
  };
}

/// Set target number of peers to maintain
class SetTargetPeers {
  SetTargetPeers({required this.targetPeers});

  /// Target number of peer connections
  final int targetPeers;

  factory SetTargetPeers.fromJson(Map<String, dynamic> json) =>
      SetTargetPeers(targetPeers: json['target_peers'] as int);

  Map<String, dynamic> toJson() => {'target_peers': targetPeers};
}

/// Set wallet emoji
class SetWalletEmoji {
  SetWalletEmoji({this.emoji, required this.fingerprint});

  /// Emoji character (null to remove)
  final String? emoji;

  /// Wallet fingerprint
  final int fingerprint;

  factory SetWalletEmoji.fromJson(Map<String, dynamic> json) => SetWalletEmoji(
    emoji: json['emoji'] == null ? null : (json['emoji'] as String),
    fingerprint: json['fingerprint'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (emoji != null) 'emoji': emoji,
    'fingerprint': fingerprint,
  };
}

/// Response for emoji update
class SetWalletEmojiResponse {
  const SetWalletEmojiResponse();

  factory SetWalletEmojiResponse.fromJson(Map<String, dynamic> json) =>
      SetWalletEmojiResponse();

  Map<String, dynamic> toJson() => {};
}

/// Sign coin spends to create a transaction
class SignCoinSpends {
  SignCoinSpends({this.autoSubmit, required this.coinSpends, this.partial});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Coin spends to sign
  final List<CoinSpendJson> coinSpends;

  /// Whether to partially sign (for multi-signature)
  final bool? partial;

  factory SignCoinSpends.fromJson(Map<String, dynamic> json) => SignCoinSpends(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    coinSpends: ((json['coin_spends']) as List)
        .map((e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    partial: json['partial'] == null ? null : (json['partial'] as bool),
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
    if (partial != null) 'partial': partial,
  };
}

/// Response with signed spend bundle
class SignCoinSpendsResponse {
  SignCoinSpendsResponse({required this.spendBundle});

  /// Signed spend bundle
  final SpendBundleJson spendBundle;

  factory SignCoinSpendsResponse.fromJson(Map<String, dynamic> json) =>
      SignCoinSpendsResponse(
        spendBundle: SpendBundleJson.fromJson(
          (json['spend_bundle'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {'spend_bundle': spendBundle.toJson()};
}

/// Sign a message by address
class SignMessageByAddress {
  SignMessageByAddress({required this.address, required this.message});

  /// Address whose key to use
  final String address;

  /// Message to sign
  final String message;

  factory SignMessageByAddress.fromJson(Map<String, dynamic> json) =>
      SignMessageByAddress(
        address: json['address'] as String,
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {'address': address, 'message': message};
}

/// Response with signed message
class SignMessageByAddressResponse {
  SignMessageByAddressResponse({
    required this.publicKey,
    required this.signature,
  });

  /// Public key used
  final String publicKey;

  /// Signature
  final String signature;

  factory SignMessageByAddressResponse.fromJson(Map<String, dynamic> json) =>
      SignMessageByAddressResponse(
        publicKey: json['publicKey'] as String,
        signature: json['signature'] as String,
      );

  Map<String, dynamic> toJson() => {
    'publicKey': publicKey,
    'signature': signature,
  };
}

/// Sign a message with a public key
class SignMessageWithPublicKey {
  SignMessageWithPublicKey({required this.message, required this.publicKey});

  /// Message to sign
  final String message;

  /// Public key to use for signing
  final String publicKey;

  factory SignMessageWithPublicKey.fromJson(Map<String, dynamic> json) =>
      SignMessageWithPublicKey(
        message: json['message'] as String,
        publicKey: json['publicKey'] as String,
      );

  Map<String, dynamic> toJson() => {'message': message, 'publicKey': publicKey};
}

/// Response with message signature
class SignMessageWithPublicKeyResponse {
  SignMessageWithPublicKeyResponse({required this.signature});

  /// Signature
  final String signature;

  factory SignMessageWithPublicKeyResponse.fromJson(
    Map<String, dynamic> json,
  ) => SignMessageWithPublicKeyResponse(signature: json['signature'] as String);

  Map<String, dynamic> toJson() => {'signature': signature};
}

class SpendBundleJson {
  SpendBundleJson({
    required this.aggregatedSignature,
    required this.coinSpends,
  });

  final String aggregatedSignature;

  final List<CoinSpendJson> coinSpends;

  factory SpendBundleJson.fromJson(Map<String, dynamic> json) =>
      SpendBundleJson(
        aggregatedSignature: json['aggregated_signature'] as String,
        coinSpends: ((json['coin_spends']) as List)
            .map(
              (e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'aggregated_signature': aggregatedSignature,
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
  };
}

/// Split coins into multiple smaller coins
class Split {
  Split({
    this.autoSubmit,
    required this.coinIds,
    required this.fee,
    required this.outputCount,
  });

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Coin IDs to split
  final List<String> coinIds;

  /// Transaction fee
  final BigInt fee;

  /// Number of output coins
  final int outputCount;

  factory Split.fromJson(Map<String, dynamic> json) => Split(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    coinIds: ((json['coin_ids']) as List).cast<String>(),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    outputCount: json['output_count'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'coin_ids': coinIds,
    'fee': fee.toString(),
    'output_count': outputCount,
  };
}

/// Submit a transaction to the network
class SubmitTransaction {
  SubmitTransaction({required this.spendBundle});

  /// Spend bundle to submit
  final SpendBundleJson spendBundle;

  factory SubmitTransaction.fromJson(Map<String, dynamic> json) =>
      SubmitTransaction(
        spendBundle: SpendBundleJson.fromJson(
          (json['spend_bundle'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {'spend_bundle': spendBundle.toJson()};
}

/// Response for transaction submission
class SubmitTransactionResponse {
  const SubmitTransactionResponse();

  factory SubmitTransactionResponse.fromJson(Map<String, dynamic> json) =>
      SubmitTransactionResponse();

  Map<String, dynamic> toJson() => {};
}

/// Accept an offer
class TakeOffer {
  TakeOffer({this.autoSubmit, required this.fee, required this.offer});

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Transaction fee
  final BigInt fee;

  /// Offer string to accept
  final String offer;

  factory TakeOffer.fromJson(Map<String, dynamic> json) => TakeOffer(
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    offer: json['offer'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    'fee': fee.toString(),
    'offer': offer,
  };
}

/// Response with accepted offer details
class TakeOfferResponse {
  TakeOfferResponse({
    required this.spendBundle,
    required this.summary,
    required this.transactionId,
  });

  /// Spend bundle
  final SpendBundleJson spendBundle;

  /// Transaction summary
  final TransactionSummary summary;

  /// Transaction ID
  final String transactionId;

  factory TakeOfferResponse.fromJson(Map<String, dynamic> json) =>
      TakeOfferResponse(
        spendBundle: SpendBundleJson.fromJson(
          (json['spend_bundle'] as Map).cast<String, dynamic>(),
        ),
        summary: TransactionSummary.fromJson(
          (json['summary'] as Map).cast<String, dynamic>(),
        ),
        transactionId: json['transaction_id'] as String,
      );

  Map<String, dynamic> toJson() => {
    'spend_bundle': spendBundle.toJson(),
    'summary': summary.toJson(),
    'transaction_id': transactionId,
  };
}

class TokenRecord {
  TokenRecord({
    this.assetId,
    required this.balance,
    this.description,
    this.iconUrl,
    this.name,
    required this.precision,
    this.revocationAddress,
    required this.selectableBalance,
    this.ticker,
    required this.visible,
  });

  final String? assetId;

  final BigInt balance;

  final String? description;

  final String? iconUrl;

  final String? name;

  final int precision;

  final String? revocationAddress;

  final BigInt selectableBalance;

  final String? ticker;

  final bool visible;

  factory TokenRecord.fromJson(Map<String, dynamic> json) => TokenRecord(
    assetId: json['asset_id'] == null ? null : (json['asset_id'] as String),
    balance: ((json['balance']) is String
        ? BigInt.parse(json['balance'] as String)
        : BigInt.from((json['balance'] as num).toInt())),
    description: json['description'] == null
        ? null
        : (json['description'] as String),
    iconUrl: json['icon_url'] == null ? null : (json['icon_url'] as String),
    name: json['name'] == null ? null : (json['name'] as String),
    precision: json['precision'] as int,
    revocationAddress: json['revocation_address'] == null
        ? null
        : (json['revocation_address'] as String),
    selectableBalance: ((json['selectable_balance']) is String
        ? BigInt.parse(json['selectable_balance'] as String)
        : BigInt.from((json['selectable_balance'] as num).toInt())),
    ticker: json['ticker'] == null ? null : (json['ticker'] as String),
    visible: json['visible'] as bool,
  );

  Map<String, dynamic> toJson() => {
    if (assetId != null) 'asset_id': assetId,
    'balance': balance.toString(),
    if (description != null) 'description': description,
    if (iconUrl != null) 'icon_url': iconUrl,
    if (name != null) 'name': name,
    'precision': precision,
    if (revocationAddress != null) 'revocation_address': revocationAddress,
    'selectable_balance': selectableBalance.toString(),
    if (ticker != null) 'ticker': ticker,
    'visible': visible,
  };
}

class TransactionCoinRecord {
  TransactionCoinRecord({
    this.address,
    required this.addressKind,
    required this.amount,
    required this.asset,
    required this.coinId,
  });

  final String? address;

  final AddressKind addressKind;

  final BigInt amount;

  final Asset asset;

  final String coinId;

  factory TransactionCoinRecord.fromJson(Map<String, dynamic> json) =>
      TransactionCoinRecord(
        address: json['address'] == null ? null : (json['address'] as String),
        addressKind: AddressKind.fromJson(json['address_kind'] as String),
        amount: ((json['amount']) is String
            ? BigInt.parse(json['amount'] as String)
            : BigInt.from((json['amount'] as num).toInt())),
        asset: Asset.fromJson((json['asset'] as Map).cast<String, dynamic>()),
        coinId: json['coin_id'] as String,
      );

  Map<String, dynamic> toJson() => {
    if (address != null) 'address': address,
    'address_kind': addressKind.toJson(),
    'amount': amount.toString(),
    'asset': asset.toJson(),
    'coin_id': coinId,
  };
}

class TransactionInput {
  TransactionInput({
    required this.address,
    required this.amount,
    this.asset,
    required this.coinId,
    required this.outputs,
  });

  final String address;

  final BigInt amount;

  final Asset? asset;

  final String coinId;

  final List<TransactionOutput> outputs;

  factory TransactionInput.fromJson(Map<String, dynamic> json) =>
      TransactionInput(
        address: json['address'] as String,
        amount: ((json['amount']) is String
            ? BigInt.parse(json['amount'] as String)
            : BigInt.from((json['amount'] as num).toInt())),
        asset: json['asset'] == null
            ? null
            : (Asset.fromJson((json['asset'] as Map).cast<String, dynamic>())),
        coinId: json['coin_id'] as String,
        outputs: ((json['outputs']) as List)
            .map(
              (e) => TransactionOutput.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    if (asset != null) 'asset': asset!.toJson(),
    'coin_id': coinId,
    'outputs': outputs.map((e) => e.toJson()).toList(),
  };
}

class TransactionOutput {
  TransactionOutput({
    required this.address,
    required this.amount,
    required this.burning,
    required this.coinId,
    required this.receiving,
  });

  final String address;

  final BigInt amount;

  final bool burning;

  final String coinId;

  final bool receiving;

  factory TransactionOutput.fromJson(Map<String, dynamic> json) =>
      TransactionOutput(
        address: json['address'] as String,
        amount: ((json['amount']) is String
            ? BigInt.parse(json['amount'] as String)
            : BigInt.from((json['amount'] as num).toInt())),
        burning: json['burning'] as bool,
        coinId: json['coin_id'] as String,
        receiving: json['receiving'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'address': address,
    'amount': amount.toString(),
    'burning': burning,
    'coin_id': coinId,
    'receiving': receiving,
  };
}

class TransactionRecord {
  TransactionRecord({
    required this.created,
    required this.height,
    required this.spent,
    this.timestamp,
  });

  final List<TransactionCoinRecord> created;

  final int height;

  final List<TransactionCoinRecord> spent;

  final int? timestamp;

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        created: ((json['created']) as List)
            .map(
              (e) => TransactionCoinRecord.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
        height: json['height'] as int,
        spent: ((json['spent']) as List)
            .map(
              (e) => TransactionCoinRecord.fromJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
        timestamp: json['timestamp'] == null
            ? null
            : (json['timestamp'] as int),
      );

  Map<String, dynamic> toJson() => {
    'created': created.map((e) => e.toJson()).toList(),
    'height': height,
    'spent': spent.map((e) => e.toJson()).toList(),
    if (timestamp != null) 'timestamp': timestamp,
  };
}

/// Standard transaction response
class TransactionResponse {
  TransactionResponse({required this.coinSpends, required this.summary});

  /// Coin spends in the transaction
  final List<CoinSpendJson> coinSpends;

  /// Transaction summary
  final TransactionSummary summary;

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      TransactionResponse(
        coinSpends: ((json['coin_spends']) as List)
            .map(
              (e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
        summary: TransactionSummary.fromJson(
          (json['summary'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
  };
}

class TransactionSummary {
  TransactionSummary({required this.fee, required this.inputs});

  final BigInt fee;

  final List<TransactionInput> inputs;

  factory TransactionSummary.fromJson(Map<String, dynamic> json) =>
      TransactionSummary(
        fee: ((json['fee']) is String
            ? BigInt.parse(json['fee'] as String)
            : BigInt.from((json['fee'] as num).toInt())),
        inputs: ((json['inputs']) as List)
            .map(
              (e) =>
                  TransactionInput.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'fee': fee.toString(),
    'inputs': inputs.map((e) => e.toJson()).toList(),
  };
}

/// Transfer DIDs to a new address
class TransferDids {
  TransferDids({
    required this.address,
    this.autoSubmit,
    this.clawback,
    required this.didIds,
    required this.fee,
  });

  /// Recipient address
  final String address;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Optional clawback timestamp
  final int? clawback;

  /// DID IDs to transfer
  final List<String> didIds;

  /// Transaction fee
  final BigInt fee;

  factory TransferDids.fromJson(Map<String, dynamic> json) => TransferDids(
    address: json['address'] as String,
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    clawback: json['clawback'] == null ? null : (json['clawback'] as int),
    didIds: ((json['did_ids']) as List).cast<String>(),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    if (clawback != null) 'clawback': clawback,
    'did_ids': didIds,
    'fee': fee.toString(),
  };
}

/// Transfer NFTs to a new owner
class TransferNfts {
  TransferNfts({
    required this.address,
    this.autoSubmit,
    this.clawback,
    required this.fee,
    required this.nftIds,
  });

  /// Recipient address
  final String address;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Optional clawback timestamp
  final int? clawback;

  /// Transaction fee
  final BigInt fee;

  /// NFT IDs to transfer
  final List<String> nftIds;

  factory TransferNfts.fromJson(Map<String, dynamic> json) => TransferNfts(
    address: json['address'] as String,
    autoSubmit: json['auto_submit'] == null
        ? null
        : (json['auto_submit'] as bool),
    clawback: json['clawback'] == null ? null : (json['clawback'] as int),
    fee: ((json['fee']) is String
        ? BigInt.parse(json['fee'] as String)
        : BigInt.from((json['fee'] as num).toInt())),
    nftIds: ((json['nft_ids']) as List).cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    if (clawback != null) 'clawback': clawback,
    'fee': fee.toString(),
    'nft_ids': nftIds,
  };
}

/// Transfer options to another address
class TransferOptions {
  TransferOptions({
    required this.address,
    this.autoSubmit,
    this.clawback,
    required this.fee,
    required this.optionIds,
  });

  /// Recipient address
  final String address;

  /// Whether to automatically submit the transaction
  final bool? autoSubmit;

  /// Optional clawback timestamp
  final int? clawback;

  /// Transaction fee
  final BigInt fee;

  /// Option IDs to transfer
  final List<String> optionIds;

  factory TransferOptions.fromJson(Map<String, dynamic> json) =>
      TransferOptions(
        address: json['address'] as String,
        autoSubmit: json['auto_submit'] == null
            ? null
            : (json['auto_submit'] as bool),
        clawback: json['clawback'] == null ? null : (json['clawback'] as int),
        fee: ((json['fee']) is String
            ? BigInt.parse(json['fee'] as String)
            : BigInt.from((json['fee'] as num).toInt())),
        optionIds: ((json['option_ids']) as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    'address': address,
    if (autoSubmit != null) 'auto_submit': autoSubmit,
    if (clawback != null) 'clawback': clawback,
    'fee': fee.toString(),
    'option_ids': optionIds,
  };
}

class Unit {
  Unit({required this.precision, required this.ticker});

  final int precision;

  final String ticker;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
    precision: json['precision'] as int,
    ticker: json['ticker'] as String,
  );

  Map<String, dynamic> toJson() => {'precision': precision, 'ticker': ticker};
}

/// Update a `CAT` token's metadata and visibility
class UpdateCat {
  UpdateCat({required this.record});

  /// The token record containing updated metadata
  final TokenRecord record;

  factory UpdateCat.fromJson(Map<String, dynamic> json) => UpdateCat(
    record: TokenRecord.fromJson(
      (json['record'] as Map).cast<String, dynamic>(),
    ),
  );

  Map<String, dynamic> toJson() => {'record': record.toJson()};
}

/// Response after updating a `CAT` token
class UpdateCatResponse {
  const UpdateCatResponse();

  factory UpdateCatResponse.fromJson(Map<String, dynamic> json) =>
      UpdateCatResponse();

  Map<String, dynamic> toJson() => {};
}

/// Update a `DID`'s name and visibility settings
class UpdateDid {
  UpdateDid({required this.didId, this.name, required this.visible});

  /// The `DID` ID to update
  final String didId;

  /// Optional new name for the `DID`
  final String? name;

  /// Whether the `DID` should be visible in the UI
  final bool visible;

  factory UpdateDid.fromJson(Map<String, dynamic> json) => UpdateDid(
    didId: json['did_id'] as String,
    name: json['name'] == null ? null : (json['name'] as String),
    visible: json['visible'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'did_id': didId,
    if (name != null) 'name': name,
    'visible': visible,
  };
}

/// Response after updating a `DID`
class UpdateDidResponse {
  const UpdateDidResponse();

  factory UpdateDidResponse.fromJson(Map<String, dynamic> json) =>
      UpdateDidResponse();

  Map<String, dynamic> toJson() => {};
}

/// Update an `NFT`'s visibility settings
class UpdateNft {
  UpdateNft({required this.nftId, required this.visible});

  /// The `NFT` ID to update
  final String nftId;

  /// Whether the `NFT` should be visible in the UI
  final bool visible;

  factory UpdateNft.fromJson(Map<String, dynamic> json) => UpdateNft(
    nftId: json['nft_id'] as String,
    visible: json['visible'] as bool,
  );

  Map<String, dynamic> toJson() => {'nft_id': nftId, 'visible': visible};
}

class UpdateNftAction {
  UpdateNftAction({required this.id, this.newUris, this.transfer});

  /// The id of the NFT to update
  final Map<String, dynamic> id;

  /// A list of URLs to add
  final List<NewNftUri>? newUris;

  final NftTransfer? transfer;

  factory UpdateNftAction.fromJson(Map<String, dynamic> json) =>
      UpdateNftAction(
        id: (json['id'] as Map).cast<String, dynamic>(),
        newUris: json['new_uris'] == null
            ? null
            : (((json['new_uris']) as List)
                  .map(
                    (e) =>
                        NewNftUri.fromJson((e as Map).cast<String, dynamic>()),
                  )
                  .toList()),
        transfer: json['transfer'] == null
            ? null
            : (NftTransfer.fromJson(
                (json['transfer'] as Map).cast<String, dynamic>(),
              )),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (newUris != null) 'new_uris': newUris!.map((e) => e.toJson()).toList(),
    if (transfer != null) 'transfer': transfer!.toJson(),
  };
}

/// Update an `NFT` collection's visibility settings
class UpdateNftCollection {
  UpdateNftCollection({required this.collectionId, required this.visible});

  /// The collection ID to update
  final String collectionId;

  /// Whether the collection should be visible in the UI
  final bool visible;

  factory UpdateNftCollection.fromJson(Map<String, dynamic> json) =>
      UpdateNftCollection(
        collectionId: json['collection_id'] as String,
        visible: json['visible'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'collection_id': collectionId,
    'visible': visible,
  };
}

/// Response after updating an `NFT` collection
class UpdateNftCollectionResponse {
  const UpdateNftCollectionResponse();

  factory UpdateNftCollectionResponse.fromJson(Map<String, dynamic> json) =>
      UpdateNftCollectionResponse();

  Map<String, dynamic> toJson() => {};
}

/// Response after updating an `NFT`
class UpdateNftResponse {
  const UpdateNftResponse();

  factory UpdateNftResponse.fromJson(Map<String, dynamic> json) =>
      UpdateNftResponse();

  Map<String, dynamic> toJson() => {};
}

/// Update an option's visibility settings
class UpdateOption {
  UpdateOption({required this.optionId, required this.visible});

  /// The option ID to update
  final String optionId;

  /// Whether the option should be visible in the UI
  final bool visible;

  factory UpdateOption.fromJson(Map<String, dynamic> json) => UpdateOption(
    optionId: json['option_id'] as String,
    visible: json['visible'] as bool,
  );

  Map<String, dynamic> toJson() => {'option_id': optionId, 'visible': visible};
}

/// Response after updating an option
class UpdateOptionResponse {
  const UpdateOptionResponse();

  factory UpdateOptionResponse.fromJson(Map<String, dynamic> json) =>
      UpdateOptionResponse();

  Map<String, dynamic> toJson() => {};
}

class Vec {
  const Vec();

  factory Vec.fromJson(Map<String, dynamic> json) => Vec();

  Map<String, dynamic> toJson() => {};
}

/// View coin spends without signing
class ViewCoinSpends {
  ViewCoinSpends({required this.coinSpends});

  /// Coin spends to view
  final List<CoinSpendJson> coinSpends;

  factory ViewCoinSpends.fromJson(Map<String, dynamic> json) => ViewCoinSpends(
    coinSpends: ((json['coin_spends']) as List)
        .map((e) => CoinSpendJson.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'coin_spends': coinSpends.map((e) => e.toJson()).toList(),
  };
}

/// Response with transaction summary
class ViewCoinSpendsResponse {
  ViewCoinSpendsResponse({required this.summary});

  /// Transaction summary
  final TransactionSummary summary;

  factory ViewCoinSpendsResponse.fromJson(Map<String, dynamic> json) =>
      ViewCoinSpendsResponse(
        summary: TransactionSummary.fromJson(
          (json['summary'] as Map).cast<String, dynamic>(),
        ),
      );

  Map<String, dynamic> toJson() => {'summary': summary.toJson()};
}

/// View an offer without accepting
class ViewOffer {
  ViewOffer({required this.offer});

  /// Offer string to view
  final String offer;

  factory ViewOffer.fromJson(Map<String, dynamic> json) =>
      ViewOffer(offer: json['offer'] as String);

  Map<String, dynamic> toJson() => {'offer': offer};
}

/// Response with offer details
class ViewOfferResponse {
  ViewOfferResponse({required this.offer, required this.status});

  /// Offer summary
  final OfferSummary offer;

  /// Offer status
  final OfferRecordStatus status;

  factory ViewOfferResponse.fromJson(Map<String, dynamic> json) =>
      ViewOfferResponse(
        offer: OfferSummary.fromJson(
          (json['offer'] as Map).cast<String, dynamic>(),
        ),
        status: OfferRecordStatus.fromJson(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
    'offer': offer.toJson(),
    'status': status.toJson(),
  };
}

/// Typed facade over [SageClient]. One method per Sage endpoint,
/// auto-generated from Sage's OpenAPI spec — see tool/gen_sage_api.py.
class SageApi {
  SageApi(this._client);
  final SageClient _client;

  /// Add a URI to an NFT
  Future<TransactionResponse> addNftUri(AddNftUri request) async {
    final json = await _client.callJson('add_nft_uri', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Add a new peer to connect to
  Future<EmptyResponse> addPeer(AddPeer request) async {
    final json = await _client.callJson('add_peer', request.toJson());
    return EmptyResponse.fromJson(json);
  }

  /// Assign NFTs to a DID
  Future<TransactionResponse> assignNftsToDid(AssignNftsToDid request) async {
    final json = await _client.callJson('assign_nfts_to_did', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Automatically combine CAT coins
  Future<AutoCombineCatResponse> autoCombineCat(AutoCombineCat request) async {
    final json = await _client.callJson('auto_combine_cat', request.toJson());
    return AutoCombineCatResponse.fromJson(json);
  }

  /// Automatically combine XCH coins
  Future<AutoCombineXchResponse> autoCombineXch(AutoCombineXch request) async {
    final json = await _client.callJson('auto_combine_xch', request.toJson());
    return AutoCombineXchResponse.fromJson(json);
  }

  /// Mint multiple NFTs in one transaction
  Future<BulkMintNftsResponse> bulkMintNfts(BulkMintNfts request) async {
    final json = await _client.callJson('bulk_mint_nfts', request.toJson());
    return BulkMintNftsResponse.fromJson(json);
  }

  /// Send CAT tokens to multiple addresses
  Future<TransactionResponse> bulkSendCat(BulkSendCat request) async {
    final json = await _client.callJson('bulk_send_cat', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Send XCH to multiple addresses
  Future<TransactionResponse> bulkSendXch(BulkSendXch request) async {
    final json = await _client.callJson('bulk_send_xch', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Cancel an offer on-chain
  Future<TransactionResponse> cancelOffer(CancelOffer request) async {
    final json = await _client.callJson('cancel_offer', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Cancel multiple offers
  Future<TransactionResponse> cancelOffers(CancelOffers request) async {
    final json = await _client.callJson('cancel_offers', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Validate and check an address
  Future<CheckAddressResponse> checkAddress(CheckAddress request) async {
    final json = await _client.callJson('check_address', request.toJson());
    return CheckAddressResponse.fromJson(json);
  }

  /// Combine multiple coins into one
  Future<TransactionResponse> combine(Combine request) async {
    final json = await _client.callJson('combine', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Combine multiple offers
  Future<CombineOffersResponse> combineOffers(CombineOffers request) async {
    final json = await _client.callJson('combine_offers', request.toJson());
    return CombineOffersResponse.fromJson(json);
  }

  /// Create a new DID
  Future<TransactionResponse> createDid(CreateDid request) async {
    final json = await _client.callJson('create_did', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// create_transaction
  Future<TransactionResponse> createTransaction(
    CreateTransaction request,
  ) async {
    final json = await _client.callJson('create_transaction', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Delete a wallet database
  Future<DeleteDatabaseResponse> deleteDatabase(DeleteDatabase request) async {
    final json = await _client.callJson('delete_database', request.toJson());
    return DeleteDatabaseResponse.fromJson(json);
  }

  /// Delete a wallet key
  Future<DeleteKeyResponse> deleteKey(DeleteKey request) async {
    final json = await _client.callJson('delete_key', request.toJson());
    return DeleteKeyResponse.fromJson(json);
  }

  /// Delete an offer
  Future<DeleteOfferResponse> deleteOffer(DeleteOffer request) async {
    final json = await _client.callJson('delete_offer', request.toJson());
    return DeleteOfferResponse.fromJson(json);
  }

  /// Delete a theme NFT from the wallet
  Future<DeleteUserThemeResponse> deleteUserTheme(
    DeleteUserTheme request,
  ) async {
    final json = await _client.callJson('delete_user_theme', request.toJson());
    return DeleteUserThemeResponse.fromJson(json);
  }

  /// Exercise options
  Future<TransactionResponse> exerciseOptions(ExerciseOptions request) async {
    final json = await _client.callJson('exercise_options', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Filter unlocked coins from a list
  Future<FilterUnlockedCoinsResponse> filterUnlockedCoins(
    FilterUnlockedCoins request,
  ) async {
    final json = await _client.callJson(
      'filter_unlocked_coins',
      request.toJson(),
    );
    return FilterUnlockedCoinsResponse.fromJson(json);
  }

  /// Send CAT tokens to an address
  Future<TransactionResponse> finalizeClawback(FinalizeClawback request) async {
    final json = await _client.callJson('finalize_clawback', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Generate a new mnemonic phrase for wallet creation
  Future<GenerateMnemonicResponse> generateMnemonic(
    GenerateMnemonic request,
  ) async {
    final json = await _client.callJson('generate_mnemonic', request.toJson());
    return GenerateMnemonicResponse.fromJson(json);
  }

  /// Get all known CAT tokens
  Future<GetAllCatsResponse> getAllCats([
    GetAllCats request = const GetAllCats(),
  ]) async {
    final json = await _client.callJson('get_all_cats', request.toJson());
    return GetAllCatsResponse.fromJson(json);
  }

  /// Check if specific coins are spendable
  Future<GetAreCoinsSpendableResponse> getAreCoinsSpendable(
    GetAreCoinsSpendable request,
  ) async {
    final json = await _client.callJson(
      'get_are_coins_spendable',
      request.toJson(),
    );
    return GetAreCoinsSpendableResponse.fromJson(json);
  }

  /// Get spendable coins for an asset
  Future<Map<String, dynamic>> getAssetCoins(GetAssetCoins request) async {
    final json = await _client.callJson('get_asset_coins', request.toJson());
    return json;
  }

  /// Get CAT tokens in wallet
  Future<GetCatsResponse> getCats([GetCats request = const GetCats()]) async {
    final json = await _client.callJson('get_cats', request.toJson());
    return GetCatsResponse.fromJson(json);
  }

  /// List coins with filtering and pagination
  Future<GetCoinsResponse> getCoins(GetCoins request) async {
    final json = await _client.callJson('get_coins', request.toJson());
    return GetCoinsResponse.fromJson(json);
  }

  /// Retrieve specific coins by their IDs
  Future<GetCoinsByIdsResponse> getCoinsByIds(GetCoinsByIds request) async {
    final json = await _client.callJson('get_coins_by_ids', request.toJson());
    return GetCoinsByIdsResponse.fromJson(json);
  }

  /// Retrieve database statistics
  Future<GetDatabaseStatsResponse> getDatabaseStats([
    GetDatabaseStats request = const GetDatabaseStats(),
  ]) async {
    final json = await _client.callJson('get_database_stats', request.toJson());
    return GetDatabaseStatsResponse.fromJson(json);
  }

  /// Get address derivation information
  Future<GetDerivationsResponse> getDerivations(GetDerivations request) async {
    final json = await _client.callJson('get_derivations', request.toJson());
    return GetDerivationsResponse.fromJson(json);
  }

  /// List all DIDs in the wallet
  Future<GetDidsResponse> getDids([GetDids request = const GetDids()]) async {
    final json = await _client.callJson('get_dids', request.toJson());
    return GetDidsResponse.fromJson(json);
  }

  /// Get a specific wallet key
  Future<GetKeyResponse> getKey(GetKey request) async {
    final json = await _client.callJson('get_key', request.toJson());
    return GetKeyResponse.fromJson(json);
  }

  /// List all wallet keys
  Future<GetKeysResponse> getKeys([GetKeys request = const GetKeys()]) async {
    final json = await _client.callJson('get_keys', request.toJson());
    return GetKeysResponse.fromJson(json);
  }

  /// Get minter DIDs with pagination
  Future<GetMinterDidIdsResponse> getMinterDidIds(
    GetMinterDidIds request,
  ) async {
    final json = await _client.callJson('get_minter_did_ids', request.toJson());
    return GetMinterDidIdsResponse.fromJson(json);
  }

  /// Get current network information
  Future<Map<String, dynamic>> getNetwork([
    GetNetwork request = const GetNetwork(),
  ]) async {
    final json = await _client.callJson('get_network', request.toJson());
    return json;
  }

  /// List available networks
  Future<Map<String, dynamic>> getNetworks([
    GetNetworks request = const GetNetworks(),
  ]) async {
    final json = await _client.callJson('get_networks', request.toJson());
    return json;
  }

  /// Get a specific NFT
  Future<GetNftResponse> getNft(GetNft request) async {
    final json = await _client.callJson('get_nft', request.toJson());
    return GetNftResponse.fromJson(json);
  }

  /// Get a specific NFT collection
  Future<GetNftCollectionResponse> getNftCollection(
    GetNftCollection request,
  ) async {
    final json = await _client.callJson('get_nft_collection', request.toJson());
    return GetNftCollectionResponse.fromJson(json);
  }

  /// List NFT collections
  Future<GetNftCollectionsResponse> getNftCollections(
    GetNftCollections request,
  ) async {
    final json = await _client.callJson(
      'get_nft_collections',
      request.toJson(),
    );
    return GetNftCollectionsResponse.fromJson(json);
  }

  /// Get NFT data file
  Future<GetNftDataResponse> getNftData(GetNftData request) async {
    final json = await _client.callJson('get_nft_data', request.toJson());
    return GetNftDataResponse.fromJson(json);
  }

  /// Get NFT icon image
  Future<GetNftIconResponse> getNftIcon(GetNftIcon request) async {
    final json = await _client.callJson('get_nft_icon', request.toJson());
    return GetNftIconResponse.fromJson(json);
  }

  /// Get NFT thumbnail image
  Future<GetNftThumbnailResponse> getNftThumbnail(
    GetNftThumbnail request,
  ) async {
    final json = await _client.callJson('get_nft_thumbnail', request.toJson());
    return GetNftThumbnailResponse.fromJson(json);
  }

  /// List NFTs with filtering
  Future<GetNftsResponse> getNfts(GetNfts request) async {
    final json = await _client.callJson('get_nfts', request.toJson());
    return GetNftsResponse.fromJson(json);
  }

  /// Get a specific offer
  Future<GetOfferResponse> getOffer(GetOffer request) async {
    final json = await _client.callJson('get_offer', request.toJson());
    return GetOfferResponse.fromJson(json);
  }

  /// List all offers
  Future<GetOffersResponse> getOffers([
    GetOffers request = const GetOffers(),
  ]) async {
    final json = await _client.callJson('get_offers', request.toJson());
    return GetOffersResponse.fromJson(json);
  }

  /// Get offers for a specific asset
  Future<GetOffersForAssetResponse> getOffersForAsset(
    GetOffersForAsset request,
  ) async {
    final json = await _client.callJson(
      'get_offers_for_asset',
      request.toJson(),
    );
    return GetOffersForAssetResponse.fromJson(json);
  }

  /// Get a specific option
  Future<GetOptionResponse> getOption(GetOption request) async {
    final json = await _client.callJson('get_option', request.toJson());
    return GetOptionResponse.fromJson(json);
  }

  /// List options with filtering
  Future<GetOptionsResponse> getOptions(GetOptions request) async {
    final json = await _client.callJson('get_options', request.toJson());
    return GetOptionsResponse.fromJson(json);
  }

  /// List all network peers
  Future<GetPeersResponse> getPeers([
    GetPeers request = const GetPeers(),
  ]) async {
    final json = await _client.callJson('get_peers', request.toJson());
    return GetPeersResponse.fromJson(json);
  }

  /// Get pending transactions
  Future<GetPendingTransactionsResponse> getPendingTransactions([
    GetPendingTransactions request = const GetPendingTransactions(),
  ]) async {
    final json = await _client.callJson(
      'get_pending_transactions',
      request.toJson(),
    );
    return GetPendingTransactionsResponse.fromJson(json);
  }

  /// Get wallet secret key
  Future<GetSecretKeyResponse> getSecretKey(GetSecretKey request) async {
    final json = await _client.callJson('get_secret_key', request.toJson());
    return GetSecretKeyResponse.fromJson(json);
  }

  /// Get the count of spendable coins
  Future<GetSpendableCoinCountResponse> getSpendableCoinCount(
    GetSpendableCoinCount request,
  ) async {
    final json = await _client.callJson(
      'get_spendable_coin_count',
      request.toJson(),
    );
    return GetSpendableCoinCountResponse.fromJson(json);
  }

  /// Get the current synchronization status
  Future<GetSyncStatusResponse> getSyncStatus([
    GetSyncStatus request = const GetSyncStatus(),
  ]) async {
    final json = await _client.callJson('get_sync_status', request.toJson());
    return GetSyncStatusResponse.fromJson(json);
  }

  /// Get detailed token information
  Future<GetTokenResponse> getToken(GetToken request) async {
    final json = await _client.callJson('get_token', request.toJson());
    return GetTokenResponse.fromJson(json);
  }

  /// Get a specific transaction by height
  Future<GetTransactionResponse> getTransaction(GetTransaction request) async {
    final json = await _client.callJson('get_transaction', request.toJson());
    return GetTransactionResponse.fromJson(json);
  }

  /// List transactions with filtering
  Future<GetTransactionsResponse> getTransactions(
    GetTransactions request,
  ) async {
    final json = await _client.callJson('get_transactions', request.toJson());
    return GetTransactionsResponse.fromJson(json);
  }

  /// Get a specific theme NFT
  Future<GetUserThemeResponse> getUserTheme(GetUserTheme request) async {
    final json = await _client.callJson('get_user_theme', request.toJson());
    return GetUserThemeResponse.fromJson(json);
  }

  /// List all custom theme NFTs
  Future<GetUserThemesResponse> getUserThemes([
    GetUserThemes request = const GetUserThemes(),
  ]) async {
    final json = await _client.callJson('get_user_themes', request.toJson());
    return GetUserThemesResponse.fromJson(json);
  }

  /// Get the wallet version
  Future<GetVersionResponse> getVersion([
    GetVersion request = const GetVersion(),
  ]) async {
    final json = await _client.callJson('get_version', request.toJson());
    return GetVersionResponse.fromJson(json);
  }

  /// Import a wallet key
  Future<ImportKeyResponse> importKey(ImportKey request) async {
    final json = await _client.callJson('import_key', request.toJson());
    return ImportKeyResponse.fromJson(json);
  }

  /// Import an offer
  Future<ImportOfferResponse> importOffer(ImportOffer request) async {
    final json = await _client.callJson('import_offer', request.toJson());
    return ImportOfferResponse.fromJson(json);
  }

  /// Increase the derivation index to generate more addresses
  Future<IncreaseDerivationIndexResponse> increaseDerivationIndex(
    IncreaseDerivationIndex request,
  ) async {
    final json = await _client.callJson(
      'increase_derivation_index',
      request.toJson(),
    );
    return IncreaseDerivationIndexResponse.fromJson(json);
  }

  /// Check if an asset is owned
  Future<IsAssetOwnedResponse> isAssetOwned(IsAssetOwned request) async {
    final json = await _client.callJson('is_asset_owned', request.toJson());
    return IsAssetOwnedResponse.fromJson(json);
  }

  /// Issue a new CAT token
  Future<TransactionResponse> issueCat(IssueCat request) async {
    final json = await _client.callJson('issue_cat', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Login to a wallet using a fingerprint
  Future<LoginResponse> login(Login request) async {
    final json = await _client.callJson('login', request.toJson());
    return LoginResponse.fromJson(json);
  }

  /// Log out of the current wallet session
  Future<LogoutResponse> logout([Logout request = const Logout()]) async {
    final json = await _client.callJson('logout', request.toJson());
    return LogoutResponse.fromJson(json);
  }

  /// Create a new offer
  Future<MakeOfferResponse> makeOffer(MakeOffer request) async {
    final json = await _client.callJson('make_offer', request.toJson());
    return MakeOfferResponse.fromJson(json);
  }

  /// Mint a new option
  Future<MintOptionResponse> mintOption(MintOption request) async {
    final json = await _client.callJson('mint_option', request.toJson());
    return MintOptionResponse.fromJson(json);
  }

  /// Send multiple assets in one transaction
  Future<TransactionResponse> multiSend(MultiSend request) async {
    final json = await _client.callJson('multi_send', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Normalize DIDs to latest state
  Future<TransactionResponse> normalizeDids(NormalizeDids request) async {
    final json = await _client.callJson('normalize_dids', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Perform database maintenance operations
  Future<PerformDatabaseMaintenanceResponse> performDatabaseMaintenance(
    PerformDatabaseMaintenance request,
  ) async {
    final json = await _client.callJson(
      'perform_database_maintenance',
      request.toJson(),
    );
    return PerformDatabaseMaintenanceResponse.fromJson(json);
  }

  /// Re-download an `NFT`'s data and metadata from its URIs
  Future<RedownloadNftResponse> redownloadNft(RedownloadNft request) async {
    final json = await _client.callJson('redownload_nft', request.toJson());
    return RedownloadNftResponse.fromJson(json);
  }

  /// Remove a peer from the connection list
  Future<EmptyResponse> removePeer(RemovePeer request) async {
    final json = await _client.callJson('remove_peer', request.toJson());
    return EmptyResponse.fromJson(json);
  }

  /// Rename a wallet key
  Future<RenameKeyResponse> renameKey(RenameKey request) async {
    final json = await _client.callJson('rename_key', request.toJson());
    return RenameKeyResponse.fromJson(json);
  }

  /// Resynchronize wallet data with the blockchain
  Future<ResyncResponse> resync(Resync request) async {
    final json = await _client.callJson('resync', request.toJson());
    return ResyncResponse.fromJson(json);
  }

  /// Resynchronize a `CAT` token's metadata from an external source
  Future<ResyncCatResponse> resyncCat(ResyncCat request) async {
    final json = await _client.callJson('resync_cat', request.toJson());
    return ResyncCatResponse.fromJson(json);
  }

  /// Save a theme NFT to the wallet
  Future<SaveUserThemeResponse> saveUserTheme(SaveUserTheme request) async {
    final json = await _client.callJson('save_user_theme', request.toJson());
    return SaveUserThemeResponse.fromJson(json);
  }

  /// Send CAT tokens to an address
  Future<TransactionResponse> sendCat(SendCat request) async {
    final json = await _client.callJson('send_cat', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Send a transaction immediately
  Future<SendTransactionImmediatelyResponse> sendTransactionImmediately(
    SendTransactionImmediately request,
  ) async {
    final json = await _client.callJson(
      'send_transaction_immediately',
      request.toJson(),
    );
    return SendTransactionImmediatelyResponse.fromJson(json);
  }

  /// Send XCH to an address
  Future<TransactionResponse> sendXch(SendXch request) async {
    final json = await _client.callJson('send_xch', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Set the change address for transactions
  Future<EmptyResponse> setChangeAddress(SetChangeAddress request) async {
    final json = await _client.callJson('set_change_address', request.toJson());
    return EmptyResponse.fromJson(json);
  }

  /// Enable or disable delta sync
  Future<EmptyResponse> setDeltaSync(SetDeltaSync request) async {
    final json = await _client.callJson('set_delta_sync', request.toJson());
    return EmptyResponse.fromJson(json);
  }

  /// Override delta sync settings for a specific wallet
  Future<EmptyResponse> setDeltaSyncOverride(
    SetDeltaSyncOverride request,
  ) async {
    final json = await _client.callJson(
      'set_delta_sync_override',
      request.toJson(),
    );
    return EmptyResponse.fromJson(json);
  }

  /// Enable or disable automatic peer discovery
  Future<EmptyResponse> setDiscoverPeers(SetDiscoverPeers request) async {
    final json = await _client.callJson('set_discover_peers', request.toJson());
    return EmptyResponse.fromJson(json);
  }

  /// Set the active network
  Future<EmptyResponse> setNetwork(SetNetwork request) async {
    final json = await _client.callJson('set_network', request.toJson());
    return EmptyResponse.fromJson(json);
  }

  /// Override network settings for a specific wallet
  Future<EmptyResponse> setNetworkOverride(SetNetworkOverride request) async {
    final json = await _client.callJson(
      'set_network_override',
      request.toJson(),
    );
    return EmptyResponse.fromJson(json);
  }

  /// Set target number of peers to maintain
  Future<EmptyResponse> setTargetPeers(SetTargetPeers request) async {
    final json = await _client.callJson('set_target_peers', request.toJson());
    return EmptyResponse.fromJson(json);
  }

  /// Set wallet emoji
  Future<SetWalletEmojiResponse> setWalletEmoji(SetWalletEmoji request) async {
    final json = await _client.callJson('set_wallet_emoji', request.toJson());
    return SetWalletEmojiResponse.fromJson(json);
  }

  /// Sign coin spends to create a transaction
  Future<SignCoinSpendsResponse> signCoinSpends(SignCoinSpends request) async {
    final json = await _client.callJson('sign_coin_spends', request.toJson());
    return SignCoinSpendsResponse.fromJson(json);
  }

  /// Sign a message by address
  Future<SignMessageByAddressResponse> signMessageByAddress(
    SignMessageByAddress request,
  ) async {
    final json = await _client.callJson(
      'sign_message_by_address',
      request.toJson(),
    );
    return SignMessageByAddressResponse.fromJson(json);
  }

  /// Sign a message with a public key
  Future<SignMessageWithPublicKeyResponse> signMessageWithPublicKey(
    SignMessageWithPublicKey request,
  ) async {
    final json = await _client.callJson(
      'sign_message_with_public_key',
      request.toJson(),
    );
    return SignMessageWithPublicKeyResponse.fromJson(json);
  }

  /// Split coins into multiple smaller coins
  Future<TransactionResponse> split(Split request) async {
    final json = await _client.callJson('split', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Submit a transaction to the network
  Future<SubmitTransactionResponse> submitTransaction(
    SubmitTransaction request,
  ) async {
    final json = await _client.callJson('submit_transaction', request.toJson());
    return SubmitTransactionResponse.fromJson(json);
  }

  /// Accept an offer
  Future<TakeOfferResponse> takeOffer(TakeOffer request) async {
    final json = await _client.callJson('take_offer', request.toJson());
    return TakeOfferResponse.fromJson(json);
  }

  /// Transfer DIDs to a new address
  Future<TransactionResponse> transferDids(TransferDids request) async {
    final json = await _client.callJson('transfer_dids', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Transfer NFTs to a new owner
  Future<TransactionResponse> transferNfts(TransferNfts request) async {
    final json = await _client.callJson('transfer_nfts', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Transfer options to another address
  Future<TransactionResponse> transferOptions(TransferOptions request) async {
    final json = await _client.callJson('transfer_options', request.toJson());
    return TransactionResponse.fromJson(json);
  }

  /// Update a `CAT` token's metadata and visibility
  Future<UpdateCatResponse> updateCat(UpdateCat request) async {
    final json = await _client.callJson('update_cat', request.toJson());
    return UpdateCatResponse.fromJson(json);
  }

  /// Update a `DID`'s name and visibility settings
  Future<UpdateDidResponse> updateDid(UpdateDid request) async {
    final json = await _client.callJson('update_did', request.toJson());
    return UpdateDidResponse.fromJson(json);
  }

  /// Update an `NFT`'s visibility settings
  Future<UpdateNftResponse> updateNft(UpdateNft request) async {
    final json = await _client.callJson('update_nft', request.toJson());
    return UpdateNftResponse.fromJson(json);
  }

  /// Update an `NFT` collection's visibility settings
  Future<UpdateNftCollectionResponse> updateNftCollection(
    UpdateNftCollection request,
  ) async {
    final json = await _client.callJson(
      'update_nft_collection',
      request.toJson(),
    );
    return UpdateNftCollectionResponse.fromJson(json);
  }

  /// Update an option's visibility settings
  Future<UpdateOptionResponse> updateOption(UpdateOption request) async {
    final json = await _client.callJson('update_option', request.toJson());
    return UpdateOptionResponse.fromJson(json);
  }

  /// View coin spends without signing
  Future<ViewCoinSpendsResponse> viewCoinSpends(ViewCoinSpends request) async {
    final json = await _client.callJson('view_coin_spends', request.toJson());
    return ViewCoinSpendsResponse.fromJson(json);
  }

  /// View an offer without accepting
  Future<ViewOfferResponse> viewOffer(ViewOffer request) async {
    final json = await _client.callJson('view_offer', request.toJson());
    return ViewOfferResponse.fromJson(json);
  }
}

/// One entry per Sage endpoint: name, OpenAPI tag, description and
/// a ready-to-edit request JSON template (required fields filled).
class SageEndpoint {
  const SageEndpoint(this.name, this.tag, this.description, this.template);
  final String name;
  final String tag;
  final String description;
  final String template;
}

const List<SageEndpoint> kSageEndpoints = [
  SageEndpoint(
    'add_nft_uri',
    'NFTs',
    'Add a URI to an NFT',
    '{"fee": "0", "kind": "data", "nft_id": "", "uri": ""}',
  ),
  SageEndpoint(
    'add_peer',
    'Peers',
    'Add a new peer to connect to',
    '{"ip": "node.example.com:8444"}',
  ),
  SageEndpoint(
    'assign_nfts_to_did',
    'NFTs',
    'Assign NFTs to a DID',
    '{"fee": "0", "nft_ids": []}',
  ),
  SageEndpoint(
    'auto_combine_cat',
    'CAT Tokens',
    'Automatically combine CAT coins',
    '{"asset_id": "", "fee": "0", "max_coins": 0}',
  ),
  SageEndpoint(
    'auto_combine_xch',
    'XCH Transactions',
    'Automatically combine XCH coins',
    '{"fee": "0", "max_coins": 0}',
  ),
  SageEndpoint(
    'bulk_mint_nfts',
    'NFTs',
    'Mint multiple NFTs in one transaction',
    '{"did_id": "", "fee": "0", "mints": []}',
  ),
  SageEndpoint(
    'bulk_send_cat',
    'CAT Tokens',
    'Send CAT tokens to multiple addresses',
    '{"addresses": [], "amount": "0", "asset_id": "", "fee": "0"}',
  ),
  SageEndpoint(
    'bulk_send_xch',
    'XCH Transactions',
    'Send XCH to multiple addresses',
    '{"addresses": [], "amount": "0", "fee": "0"}',
  ),
  SageEndpoint(
    'cancel_offer',
    'Offers',
    'Cancel an offer on-chain',
    '{"fee": "0", "offer_id": ""}',
  ),
  SageEndpoint(
    'cancel_offers',
    'Offers',
    'Cancel multiple offers',
    '{"fee": "0", "offer_ids": []}',
  ),
  SageEndpoint(
    'check_address',
    'Addresses',
    'Validate and check an address',
    '{"address": "xch1..."}',
  ),
  SageEndpoint(
    'combine',
    'XCH Transactions',
    'Combine multiple coins into one',
    '{"coin_ids": [], "fee": "0"}',
  ),
  SageEndpoint(
    'combine_offers',
    'Offers',
    'Combine multiple offers',
    '{"offers": []}',
  ),
  SageEndpoint(
    'create_did',
    'DIDs',
    'Create a new DID',
    '{"fee": "0", "name": ""}',
  ),
  SageEndpoint(
    'create_transaction',
    'Transactions',
    'create_transaction',
    '{"actions": []}',
  ),
  SageEndpoint(
    'delete_database',
    'System & Sync',
    'Delete a wallet database',
    '{"fingerprint": 1234567890, "network": ""}',
  ),
  SageEndpoint(
    'delete_key',
    'Authentication & Keys',
    'Delete a wallet key',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint('delete_offer', 'Offers', 'Delete an offer', '{"offer_id": ""}'),
  SageEndpoint(
    'delete_user_theme',
    'Themes',
    'Delete a theme NFT from the wallet',
    '{"nft_id": ""}',
  ),
  SageEndpoint(
    'exercise_options',
    'Options',
    'Exercise options',
    '{"fee": "0", "option_ids": []}',
  ),
  SageEndpoint(
    'filter_unlocked_coins',
    'WalletConnect',
    'Filter unlocked coins from a list',
    '{"coin_ids": []}',
  ),
  SageEndpoint(
    'finalize_clawback',
    'XCH Transactions',
    'Send CAT tokens to an address',
    '{"coin_ids": [], "fee": "0"}',
  ),
  SageEndpoint(
    'generate_mnemonic',
    'Authentication & Keys',
    'Generate a new mnemonic phrase for wallet creation',
    '{"use_24_words": false}',
  ),
  SageEndpoint('get_all_cats', 'CAT Tokens', 'Get all known CAT tokens', '{}'),
  SageEndpoint(
    'get_are_coins_spendable',
    'Coins',
    'Check if specific coins are spendable',
    '{"coin_ids": []}',
  ),
  SageEndpoint(
    'get_asset_coins',
    'WalletConnect',
    'Get spendable coins for an asset',
    '{}',
  ),
  SageEndpoint('get_cats', 'CAT Tokens', 'Get CAT tokens in wallet', '{}'),
  SageEndpoint(
    'get_coins',
    'Coins',
    'List coins with filtering and pagination',
    '{"limit": 50, "offset": 0}',
  ),
  SageEndpoint(
    'get_coins_by_ids',
    'Coins',
    'Retrieve specific coins by their IDs',
    '{"coin_ids": []}',
  ),
  SageEndpoint(
    'get_database_stats',
    'System & Sync',
    'Retrieve database statistics',
    '{}',
  ),
  SageEndpoint(
    'get_derivations',
    'Addresses',
    'Get address derivation information',
    '{"limit": 50, "offset": 0}',
  ),
  SageEndpoint('get_dids', 'DIDs', 'List all DIDs in the wallet', '{}'),
  SageEndpoint(
    'get_key',
    'Authentication & Keys',
    'Get a specific wallet key',
    '{}',
  ),
  SageEndpoint(
    'get_keys',
    'Authentication & Keys',
    'List all wallet keys',
    '{}',
  ),
  SageEndpoint(
    'get_minter_did_ids',
    'DIDs',
    'Get minter DIDs with pagination',
    '{"limit": 50, "offset": 0}',
  ),
  SageEndpoint(
    'get_network',
    'Network Settings',
    'Get current network information',
    '{}',
  ),
  SageEndpoint(
    'get_networks',
    'Network Settings',
    'List available networks',
    '{}',
  ),
  SageEndpoint('get_nft', 'NFTs', 'Get a specific NFT', '{"nft_id": ""}'),
  SageEndpoint(
    'get_nft_collection',
    'NFTs',
    'Get a specific NFT collection',
    '{}',
  ),
  SageEndpoint(
    'get_nft_collections',
    'NFTs',
    'List NFT collections',
    '{"include_hidden": false, "limit": 50, "offset": 0}',
  ),
  SageEndpoint('get_nft_data', 'NFTs', 'Get NFT data file', '{"nft_id": ""}'),
  SageEndpoint('get_nft_icon', 'NFTs', 'Get NFT icon image', '{"nft_id": ""}'),
  SageEndpoint(
    'get_nft_thumbnail',
    'NFTs',
    'Get NFT thumbnail image',
    '{"nft_id": ""}',
  ),
  SageEndpoint(
    'get_nfts',
    'NFTs',
    'List NFTs with filtering',
    '{"include_hidden": false, "limit": 50, "offset": 0, "sort_mode": "name"}',
  ),
  SageEndpoint(
    'get_offer',
    'Offers',
    'Get a specific offer',
    '{"offer_id": ""}',
  ),
  SageEndpoint('get_offers', 'Offers', 'List all offers', '{}'),
  SageEndpoint(
    'get_offers_for_asset',
    'Offers',
    'Get offers for a specific asset',
    '{"asset_id": ""}',
  ),
  SageEndpoint(
    'get_option',
    'Options',
    'Get a specific option',
    '{"option_id": ""}',
  ),
  SageEndpoint(
    'get_options',
    'Options',
    'List options with filtering',
    '{"limit": 50, "offset": 0}',
  ),
  SageEndpoint('get_peers', 'Peers', 'List all network peers', '{}'),
  SageEndpoint(
    'get_pending_transactions',
    'Transactions',
    'Get pending transactions',
    '{}',
  ),
  SageEndpoint(
    'get_secret_key',
    'Authentication & Keys',
    'Get wallet secret key',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint(
    'get_spendable_coin_count',
    'Coins',
    'Get the count of spendable coins',
    '{}',
  ),
  SageEndpoint(
    'get_sync_status',
    'System & Sync',
    'Get the current synchronization status',
    '{}',
  ),
  SageEndpoint(
    'get_token',
    'CAT Tokens',
    'Get detailed token information',
    '{}',
  ),
  SageEndpoint(
    'get_transaction',
    'Transactions',
    'Get a specific transaction by height',
    '{"height": 0}',
  ),
  SageEndpoint(
    'get_transactions',
    'Transactions',
    'List transactions with filtering',
    '{"ascending": false, "limit": 50, "offset": 0}',
  ),
  SageEndpoint(
    'get_user_theme',
    'Themes',
    'Get a specific theme NFT',
    '{"nft_id": ""}',
  ),
  SageEndpoint('get_user_themes', 'Themes', 'List all custom theme NFTs', '{}'),
  SageEndpoint('get_version', 'System & Sync', 'Get the wallet version', '{}'),
  SageEndpoint(
    'import_key',
    'Authentication & Keys',
    'Import a wallet key',
    '{"key": "", "name": ""}',
  ),
  SageEndpoint('import_offer', 'Offers', 'Import an offer', '{"offer": ""}'),
  SageEndpoint(
    'increase_derivation_index',
    'Addresses',
    'Increase the derivation index to generate more addresses',
    '{"index": 100}',
  ),
  SageEndpoint(
    'is_asset_owned',
    'Assets',
    'Check if an asset is owned',
    '{"asset_id": ""}',
  ),
  SageEndpoint(
    'issue_cat',
    'CAT Tokens',
    'Issue a new CAT token',
    '{"amount": "0", "fee": "0", "name": "", "ticker": ""}',
  ),
  SageEndpoint(
    'login',
    'Authentication & Keys',
    'Login to a wallet using a fingerprint',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint(
    'logout',
    'Authentication & Keys',
    'Log out of the current wallet session',
    '{}',
  ),
  SageEndpoint(
    'make_offer',
    'Offers',
    'Create a new offer',
    '{"fee": "0", "offered_assets": [], "requested_assets": []}',
  ),
  SageEndpoint(
    'mint_option',
    'Options',
    'Mint a new option',
    '{"expiration_seconds": 0, "fee": "0", "strike": {"amount": "0"}, "underlying": {"amount": "0"}}',
  ),
  SageEndpoint(
    'multi_send',
    'XCH Transactions',
    'Send multiple assets in one transaction',
    '{"fee": "0", "payments": []}',
  ),
  SageEndpoint(
    'normalize_dids',
    'DIDs',
    'Normalize DIDs to latest state',
    '{"did_ids": [], "fee": "0"}',
  ),
  SageEndpoint(
    'perform_database_maintenance',
    'System & Sync',
    'Perform database maintenance operations',
    '{"force_vacuum": false}',
  ),
  SageEndpoint(
    'redownload_nft',
    'NFTs',
    'Re-download an `NFT`\'s data and metadata from its URIs',
    '{"nft_id": "nft1..."}',
  ),
  SageEndpoint(
    'remove_peer',
    'Peers',
    'Remove a peer from the connection list',
    '{"ban": false, "ip": "127.0.0.1:8444"}',
  ),
  SageEndpoint(
    'rename_key',
    'Authentication & Keys',
    'Rename a wallet key',
    '{"fingerprint": 1234567890, "name": ""}',
  ),
  SageEndpoint(
    'resync',
    'System & Sync',
    'Resynchronize wallet data with the blockchain',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint(
    'resync_cat',
    'CAT Tokens',
    'Resynchronize a `CAT` token\'s metadata from an external source',
    '{"asset_id": "a628c1c2c6fcb74d53746157e438e108eab5c0bb3e5c80ff9b1910b3e4832913"}',
  ),
  SageEndpoint(
    'save_user_theme',
    'Themes',
    'Save a theme NFT to the wallet',
    '{"nft_id": ""}',
  ),
  SageEndpoint(
    'send_cat',
    'CAT Tokens',
    'Send CAT tokens to an address',
    '{"address": "", "amount": "0", "asset_id": "", "fee": "0"}',
  ),
  SageEndpoint(
    'send_transaction_immediately',
    'WalletConnect',
    'Send a transaction immediately',
    '{"spend_bundle": null}',
  ),
  SageEndpoint(
    'send_xch',
    'XCH Transactions',
    'Send XCH to an address',
    '{"address": "xch1...", "amount": "0", "fee": "0"}',
  ),
  SageEndpoint(
    'set_change_address',
    'Addresses',
    'Set the change address for transactions',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint(
    'set_delta_sync',
    'Network Settings',
    'Enable or disable delta sync',
    '{"delta_sync": true}',
  ),
  SageEndpoint(
    'set_delta_sync_override',
    'Network Settings',
    'Override delta sync settings for a specific wallet',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint(
    'set_discover_peers',
    'Peers',
    'Enable or disable automatic peer discovery',
    '{"discover_peers": true}',
  ),
  SageEndpoint(
    'set_network',
    'Network Settings',
    'Set the active network',
    '{"name": "mainnet"}',
  ),
  SageEndpoint(
    'set_network_override',
    'Network Settings',
    'Override network settings for a specific wallet',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint(
    'set_target_peers',
    'Peers',
    'Set target number of peers to maintain',
    '{"target_peers": 8}',
  ),
  SageEndpoint(
    'set_wallet_emoji',
    'Authentication & Keys',
    'Set wallet emoji',
    '{"fingerprint": 1234567890}',
  ),
  SageEndpoint(
    'sign_coin_spends',
    'Transactions',
    'Sign coin spends to create a transaction',
    '{"coin_spends": []}',
  ),
  SageEndpoint(
    'sign_message_by_address',
    'WalletConnect',
    'Sign a message by address',
    '{"address": "", "message": ""}',
  ),
  SageEndpoint(
    'sign_message_with_public_key',
    'WalletConnect',
    'Sign a message with a public key',
    '{"message": "", "publicKey": ""}',
  ),
  SageEndpoint(
    'split',
    'XCH Transactions',
    'Split coins into multiple smaller coins',
    '{"coin_ids": [], "fee": "0", "output_count": 0}',
  ),
  SageEndpoint(
    'submit_transaction',
    'Transactions',
    'Submit a transaction to the network',
    '{"spend_bundle": {"aggregated_signature": "", "coin_spends": []}}',
  ),
  SageEndpoint(
    'take_offer',
    'Offers',
    'Accept an offer',
    '{"fee": "0", "offer": ""}',
  ),
  SageEndpoint(
    'transfer_dids',
    'DIDs',
    'Transfer DIDs to a new address',
    '{"address": "", "did_ids": [], "fee": "0"}',
  ),
  SageEndpoint(
    'transfer_nfts',
    'NFTs',
    'Transfer NFTs to a new owner',
    '{"address": "", "fee": "0", "nft_ids": []}',
  ),
  SageEndpoint(
    'transfer_options',
    'Options',
    'Transfer options to another address',
    '{"address": "", "fee": "0", "option_ids": []}',
  ),
  SageEndpoint(
    'update_cat',
    'CAT Tokens',
    'Update a `CAT` token\'s metadata and visibility',
    '{"record": {"balance": "0", "precision": 0, "selectable_balance": "0", "visible": false}}',
  ),
  SageEndpoint(
    'update_did',
    'DIDs',
    'Update a `DID`\'s name and visibility settings',
    '{"did_id": "did:chia:...", "visible": true}',
  ),
  SageEndpoint(
    'update_nft',
    'NFTs',
    'Update an `NFT`\'s visibility settings',
    '{"nft_id": "nft1...", "visible": true}',
  ),
  SageEndpoint(
    'update_nft_collection',
    'NFTs',
    'Update an `NFT` collection\'s visibility settings',
    '{"collection_id": "col1...", "visible": true}',
  ),
  SageEndpoint(
    'update_option',
    'Options',
    'Update an option\'s visibility settings',
    '{"option_id": "0x...", "visible": true}',
  ),
  SageEndpoint(
    'view_coin_spends',
    'Transactions',
    'View coin spends without signing',
    '{"coin_spends": []}',
  ),
  SageEndpoint(
    'view_offer',
    'Offers',
    'View an offer without accepting',
    '{"offer": ""}',
  ),
];
