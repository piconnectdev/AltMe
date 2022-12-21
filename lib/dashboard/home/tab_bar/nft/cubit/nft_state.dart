part of 'nft_cubit.dart';

@JsonSerializable()
class NftState extends Equatable {
  const NftState({
    this.status = AppStatus.init,
    this.message,
    this.offset = 0,
    this.data = const [],
  });

  factory NftState.fromJson(Map<String, dynamic> json) =>
      _$NftStateFromJson(json);

  final AppStatus status;
  final StateMessage? message;
  final List<TezosNftModel> data;
  final int offset;

  NftState fetching() {
    return NftState(
      status: AppStatus.fetching,
      data: data,
      offset: offset,
    );
  }

  NftState loading() {
    return NftState(
      status: AppStatus.loading,
      data: data,
      offset: offset,
    );
  }

  NftState error({
    required MessageHandler messageHandler,
  }) {
    return NftState(
      status: AppStatus.error,
      message: StateMessage.error(messageHandler: messageHandler),
      data: data,
      offset: offset,
    );
  }

  NftState populate({
    List<TezosNftModel>? data,
  }) {
    return NftState(
      status: AppStatus.populate,
      data: data ?? this.data,
      offset: offset,
      message: null,
    );
  }

  NftState copyWith({
    AppStatus? status,
    MessageHandler? messageHandler,
    List<TezosNftModel>? data,
    int? offset,
    StateMessage? message,
  }) {
    return NftState(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toJson() => _$NftStateToJson(this);

  @override
  List<Object?> get props => [status, message, data, offset];
}
