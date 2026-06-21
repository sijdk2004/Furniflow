class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;

  BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {
    return BaseResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}
