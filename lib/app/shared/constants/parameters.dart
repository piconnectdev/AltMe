import 'package:altme/dashboard/dashboard.dart';

class Parameters {
  static const int multipleCredentialsProcessDelay = 1;

  static const bool walletHandlesCrypto = true;

  static const AdvanceSettingsState defaultAdvanceSettingsState =
      AdvanceSettingsState(
    isGamingEnabled: true,
    isIdentityEnabled: true,
    isBlockchainAccountsEnabled: true,
    isEducationEnabled: true,
    isSocialMediaEnabled: true,
    isCommunityEnabled: true,
    isOtherEnabled: true,
    isPassEnabled: true,
    isFinanceEnabled: true,
    isHumanityProofEnabled: true,
    isWalletIntegrityEnabled: true,
  );

  static const ebsiUniversalLink = 'https://app.altme.io/app/download/ebsi';

  static const web3RpcMainnetUrl = 'https://mainnet.infura.io/v3/';

  static const POLYGON_MAIN_NETWORK = 'main';
  static const INFURA_URL = 'https://polygon-mainnet.infura.io/v3/';
  static const INFURA_RDP_URL = 'wss://polygon-mainnet.infura.io/v3/';
  static const ID_STATE_CONTRACT_ADDR =
      '0x624ce98D2d27b20b8f8d521723Df8fC4db71D79D';
  static const PUSH_URL = 'https://push-staging.polygonid.com/api/v1';

  static const POLYGON_TEST_NETWORK = 'mumbai';
  static const INFURA_MUMBAI_URL = 'https://polygon-mumbai.infura.io/v3/';
  static const INFURA_MUMBAI_RDP_URL = 'wss://polygon-mumbai.infura.io/v3/';
  static const MUMBAI_ID_STATE_CONTRACT_ADDR =
      '0x134B1BE34911E39A8397ec6289782989729807a4';
  static const MUMBAI_PUSH_URL = 'https://push-staging.polygonid.com/api/v1';
}
