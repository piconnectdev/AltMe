import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip393;
import 'package:dio/dio.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';
import 'package:jose/jose.dart';
import 'package:json_path/json_path.dart';
import 'package:secp256k1/secp256k1.dart';
// ignore: implementation_imports
// ignore: implementation_imports, unnecessary_import

/// {@template ebsi}
/// EBSI wallet compliance
/// {@endtemplate}
class Ebsi {
  /// {@macro ebsi}
  Ebsi(this.client);

  ///
  final Dio client;

  /// create JWK from mnemonic
  Future<String> jwkFromMnemonic({
    required String mnemonic,
  }) async {
    //notice photo opera keen climb agent soft parrot best joke field devote
    final seed = bip393.mnemonicToSeed(mnemonic);

    late Uint8List seedBytes;

    /// m/44'/5467'/0'/0' is already used for did:key in Altme project
    final child = await ED25519_HD_KEY.derivePath("m/44'/5467'/0'/1'", seed);
    seedBytes = Uint8List.fromList(child.key);

    final key = jwkFromSeed(
      seedBytes: seedBytes,
    );
    return jsonEncode(key);
  }

  /// create JWK from seed
  Map<String, String> jwkFromSeed({
    required Uint8List seedBytes,
  }) {
    final epk = HEX.encode(seedBytes);
    final pk = PrivateKey.fromHex(epk); //Instance of 'PrivateKey'
    final pub = pk.publicKey.toHex().substring(2);
    final ad = HEX.decode(epk);
    final d = base64Url.encode(ad).substring(0, 43);
    // remove "=" padding 43/44
    final mx = pub.substring(0, 64);
    // first 32 bytes
    final ax = HEX.decode(mx);
    final x = base64Url.encode(ax).substring(0, 43);
    // remove "=" padding 43/44
    final my = pub.substring(64);
    // last 32 bytes
    final ay = HEX.decode(my);
    final y = base64Url.encode(ay).substring(0, 43);
    // ATTENTION !!!!!
    // alg "ES256K-R" for did:ethr
    // and did:tz2 "EcdsaSecp256k1RecoverySignature2020"
    // use alg "ES256K" for did:key
    final jwk = {
      'kty': 'EC',
      'crv': 'P-256K',
      'd': d,
      'x': x,
      'y': y,
      'alg': 'ES256K'
    };
    return jwk;
  }

  /// getDidFromJwk
  String getDidFromJwk(Map<String, String> jwk) {
    // final jwkKey = JsonWebKey.fromJson(jwk);
    final jwkKey = JsonWebKey.fromJson(jwk);

    final thumbprint = jwkKey.toBytes();

    final encodedAddress = Base58Encode([2, ...thumbprint]);
    final decodedAddress = Base58Decode(encodedAddress);
    return 'did:ebsi:z$encodedAddress';
  }

  /// Verifiy is url is first EBSI url, starting point to get a credential
  ///
  static bool _isEbsiInitiateIssuanceUrl(String url) {
    if (url.startsWith('openid://initiate_issuance?')) {
      return true;
    }
    return false;
  }

  ///
  Future<Uri> getAuthorizationUriForIssuer(
    String openIdRequest,
    String redirectUrl,
  ) async {
    if (_isEbsiInitiateIssuanceUrl(openIdRequest)) {
      try {
        final jsonPath = JsonPath(r'$..authorization_endpoint');
        final openidConfigurationUrl =
            '${_getIssuerFromOpenidRequest(openIdRequest)}/.well-known/openid-configuration';
        final openidConfigurationResponse =
            await client.get(openidConfigurationUrl);
        final authorizationEndpoint = jsonPath
            .readValues(openidConfigurationResponse.data)
            .first as String;
        Map<String, dynamic> authorizationRequestParemeters =
            _getAuthorizationRequestParemeters(openIdRequest, redirectUrl);

        final url = Uri.parse(authorizationEndpoint);
        final authorizationUri =
            Uri.https(url.authority, url.path, authorizationRequestParemeters);
        return authorizationUri;
      } catch (e) {
        throw Exception(e);
      }
    }
    throw Exception('Not a valid openid url to initiate issuance');
  }

  Map<String, dynamic> _getAuthorizationRequestParemeters(
    String openIdRequest,
    String redirectUrl,
  ) {
    final openIdRequestUri = Uri.parse(openIdRequest);
    final credentialType = openIdRequestUri.queryParameters['credential_type'];
    final issuerState = openIdRequestUri.queryParameters['issuer_state'];
    final issuer = openIdRequestUri.queryParameters['issuer'];
    final myRequest = <String, dynamic>{
      'scope': 'openid',
      'client_id': redirectUrl,
      'response_type': 'code',
      'authorization_details': jsonEncode([
        {
          'type': 'openid_credential',
          'credential_type': credentialType,
          'format': 'jwt_vc'
        }
      ]),
      'redirect_uri':
          '$redirectUrl?credential_type=$credentialType&issuer=$issuer',
      'state': issuerState,
      'issuer_state': issuerState
    };
    return myRequest;
  }

  String _getIssuerFromOpenidRequest(String openIdRequest) {
    final openIdRequestUri = Uri.parse(openIdRequest);
    final issuer = openIdRequestUri.queryParameters['issuer'] ?? '';
    return issuer;
  }

  /// Extract credential_type's Url from openid request
  ///
  ///
  String getCredentialRequest(String openidRequest) {
    var credentialType = '';
    try {
      final uri = Uri.parse(openidRequest);
      if (uri.scheme == 'openid') {
        credentialType = uri.queryParameters['credential_type'] ?? '';
      }
    } catch (e) {
      credentialType = '';
    }
    return credentialType;
  }

  String getIssuerRequest(String openidRequest) {
    var issuer = '';
    try {
      final uri = Uri.parse(openidRequest);
      if (uri.scheme == 'openid') {
        issuer = uri.queryParameters['issuer'] ?? '';
      }
    } catch (e) {
      issuer = '';
    }
    return issuer;
  }

  /// Retreive credential_type from url
  Future<dynamic> getCredential(
    Uri credentialRequestReceived,
  ) async {
    print('credential !!!');

    /// getting token
    final tokenHeaders = <String, dynamic>{
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    final credentialType =
        credentialRequestReceived.queryParameters['credential_type'];
    final issuerAndCode = credentialRequestReceived.queryParameters['issuer'];
    final issuerAndCodeUri = Uri.parse(issuerAndCode!);
    final code = issuerAndCodeUri.queryParameters['code'];
    final issuer =
        '${issuerAndCodeUri.scheme}://${issuerAndCodeUri.authority}${issuerAndCodeUri.path}';
    final jsonPath = JsonPath(r'$..token_endpoint');
    final openidConfigurationUrl = '$issuer/.well-known/openid-configuration';
    final openidConfigurationResponse =
        await client.get(openidConfigurationUrl);
    final tokenEndPoint =
        jsonPath.readValues(openidConfigurationResponse.data).first as String;

    final tokenData = <String, dynamic>{
      'code': code,
      'grant_type': 'authorization_code',
      'redirect_uri': credentialRequestReceived
    };
    final response = await _getToken(tokenEndPoint, tokenHeaders, tokenData);
    final accessToken = response.data['access_token'] as String;
    final cNonce = response.data['c_nonce'] as String;

    /// preparation before getting credential
    String jwt = _getJwt(cNonce, issuer);

    final jsonPathCredential = JsonPath(r'$..credential_endpoint');
    final credentialEndpoint = jsonPathCredential
        .readValues(openidConfigurationResponse.data)
        .first as String;

    final credentialHeaders = <String, dynamic>{
      // 'Conformance': conformance,
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    final credentialData = <String, dynamic>{
      'type': credentialType,
      'format': 'jwt_vc',
      'proof': {'proof_type': 'jwt', 'jwt': jwt}
    };

    final dynamic credentialResponse = await client.post(
      credentialEndpoint,
      options: Options(headers: credentialHeaders),
      data: credentialData,
    );

    return credentialResponse.data;
  }

  String _getJwt(String cNonce, String issuer) {
    /// preparation before getting credential
    final keyDict = {
      'crv': 'P-256',
      'd': 'ZpntMmvHtDxw6przKSJY-zOHMrEZd8C47D3yuqAsqrw',
      'kty': 'EC',
      'x': 'NB1ylMveV4_PPYtx9KYEjoS1WWA8qN33SJav9opWTaM',
      'y': 'UtOG2jR3NHadMMJ7wdYEq5_nHJHVfcy7QPt_OBHhBrE'
    };

    final keyJwk = {
      'crv': 'P-256',
      'kty': 'EC',
      'x': 'NB1ylMveV4_PPYtx9KYEjoS1WWA8qN33SJav9opWTaM',
      'y': 'UtOG2jR3NHadMMJ7wdYEq5_nHJHVfcy7QPt_OBHhBrE'
    };

    final verifierKey = JsonWebKey.fromJson(keyDict);
    final alg = keyDict['crv'] == 'P-256' ? 'ES256' : 'ES256K';
    final did = 'did:ebsi:zmSKef6zQZDC66MppKLHou9zCwjYE4Fwar7NSVy2c7aya';
    final kid =
        'did:ebsi:zmSKef6zQZDC66MppKLHou9zCwjYE4Fwar7NSVy2c7aya#lD7U7tcVLZWmqECJYRyGeLnDcU4ETX3reBN3Zdd0iTU';

    final payload = {
      'iss': did,
      'nonce': cNonce,
      'iat': DateTime.now().microsecondsSinceEpoch,
      'aud': issuer
    };
    final claims = new JsonWebTokenClaims.fromJson(payload);
    // create a builder, decoding the JWT in a JWS, so using a
    // JsonWebSignatureBuilder
    final builder = new JsonWebSignatureBuilder();
    // set the content
    builder.jsonContent = claims.toJson();

    builder.setProtectedHeader('typ', 'JWT');
    builder.setProtectedHeader('alg', alg);
    builder.setProtectedHeader('jwk', keyJwk);
    builder.setProtectedHeader('kid', kid);

    // add a key to sign, can only add one for JWT
    builder.addRecipient(
      verifierKey,
      algorithm: alg,
    );
    // build the jws
    var jws = builder.build();

    // output the compact serialization
    print('jwt compact serialization: ${jws.toCompactSerialization()}');
    final jwt = jws.toCompactSerialization();
    return jwt;
  }

  Future<dynamic> _getToken(
    String tokenEndPoint,
    Map<String, dynamic> tokenHeaders,
    Map<String, dynamic> tokenData,
  ) async {
    try {
      final dynamic tokenResponse = await client.post(
        tokenEndPoint,
        options: Options(headers: tokenHeaders),
        data: tokenData,
      );
      return tokenResponse.data;
    } catch (e) {
      print('what the !!');
      throw Exception(e);
    }
  }

  ///
  Future<dynamic> getCredentialWithPreAuthorizedCode(
      Uri credentialRequestReceived) async {
    /// getting token
    final tokenHeaders = <String, dynamic>{
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    final credentialType =
        credentialRequestReceived.queryParameters['credential_type'];
    final issuer = credentialRequestReceived.queryParameters['issuer'];
    final opState = credentialRequestReceived.queryParameters['issuer'];
    final preAuthorizedCode =
        credentialRequestReceived.queryParameters['pre-authorized_code'];
    final jsonPath = JsonPath(r'$..token_endpoint');
    final openidConfigurationUrl = '$issuer/.well-known/openid-configuration';
    final openidConfigurationResponse =
        await client.get(openidConfigurationUrl);
    final tokenEndPoint =
        jsonPath.readValues(openidConfigurationResponse.data).first as String;

    final tokenData = <String, dynamic>{
      'pre-authorized_code': preAuthorizedCode,
      'grant_type': 'urn:ietf:params:oauth:grant-type:pre-authorized_code',
    };

    final response = await _getToken(tokenEndPoint, tokenHeaders, tokenData);
    final accessToken = response['access_token'] as String;
    final cNonce = response['c_nonce'] as String;

    /// preparation before getting credential
    final jwt = _getJwt(cNonce, issuer!);

    final jsonPathCredential = JsonPath(r'$..credential_endpoint');
    final credentialEndpoint = jsonPathCredential
        .readValues(openidConfigurationResponse.data)
        .first as String;

    final credentialHeaders = <String, dynamic>{
      // 'Conformance': conformance,
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    final credentialData = <String, dynamic>{
      'type': credentialType,
      'format': 'jwt_vc',
      'proof': {'proof_type': 'jwt', 'jwt': jwt}
    };

    final dynamic credentialResponse = await client.post(
      credentialEndpoint,
      options: Options(headers: credentialHeaders),
      data: credentialData,
    );

    return credentialResponse.data;
  }
}
