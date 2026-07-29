// ═══════════════════════════════════════════════════════════════════════════
// 📦 Paginated Response Model
// ═══════════════════════════════════════════════════════════════════════════

class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final bool hasMore;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // ✅ Support both nested 'data' and direct array
    final dataKey = json['data'];
    final List<dynamic> dataList;
    
    if (dataKey is Map<String, dynamic> && dataKey.containsKey('data')) {
      // Laravel pagination: {data: {data: [], meta: {}}}
      dataList = dataKey['data'] as List<dynamic>;
    } else if (dataKey is List) {
      // Simple pagination: {data: [], meta: {}}
      dataList = dataKey;
    } else {
      dataList = [];
    }

    final metaData = json['meta'] ?? json['data'];
    
    final currentPage = _getInt(metaData, ['current_page', 'currentPage'], 1);
    final lastPage = _getInt(metaData, ['last_page', 'lastPage'], 1);

    return PaginatedResponse(
      data: dataList
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      total: _getInt(metaData, ['total'], 0),
      perPage: _getInt(metaData, ['per_page', 'perPage'], 20),
      hasMore: currentPage < lastPage,
    );
  }

  static int _getInt(dynamic data, List<String> keys, int defaultValue) {
    if (data == null) return defaultValue;
    
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? defaultValue;
      }
    }
    
    return defaultValue;
  }

  PaginatedResponse<T> copyWith({
    List<T>? data,
    int? currentPage,
    int? lastPage,
    int? total,
    int? perPage,
    bool? hasMore,
  }) {
    return PaginatedResponse<T>(
      data: data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      perPage: perPage ?? this.perPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
