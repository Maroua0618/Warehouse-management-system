/// Represents a single product line in a delivery
class ProductLine {
  final String sku;
  final int quantityReceived;

  const ProductLine({required this.sku, required this.quantityReceived});

  /// Create from Supabase JSON
  factory ProductLine.fromJson(Map<String, dynamic> json) {
    return ProductLine(
      sku: json['sku'] as String,
      quantityReceived: json['quantity_received'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sku': sku, 'quantity_received': quantityReceived};
  }

  ProductLine copyWith({String? sku, int? quantityReceived}) {
    return ProductLine(
      sku: sku ?? this.sku,
      quantityReceived: quantityReceived ?? this.quantityReceived,
    );
  }
}

/// Represents a Bon de Commande (Command Order/Delivery Note)
class CommandOrder {
  final String deliveryId;
  final List<ProductLine> products;
  final DateTime scheduledReception;
  final String? bay; // Bay location (e.g., "Bay 4", "Bay 12")

  const CommandOrder({
    required this.deliveryId,
    required this.products,
    required this.scheduledReception,
    this.bay,
  });

  /// Create from Supabase JSON
  /// Expected JSON structure:
  /// {
  ///   "delivery_id": "DLV-882910",
  ///   "products": [{"sku": "442", "quantity_received": 1240}, ...],
  ///   "scheduled_reception": "2026-02-13T09:30:00Z",
  ///   "bay": "Bay 4"
  /// }
  factory CommandOrder.fromJson(Map<String, dynamic> json) {
    final productList =
        (json['products'] as List<dynamic>?)
            ?.map((p) => ProductLine.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return CommandOrder(
      deliveryId: json['delivery_id'] as String,
      products: productList,
      scheduledReception: DateTime.parse(json['scheduled_reception'] as String),
      bay: json['bay'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_id': deliveryId,
      'products': products.map((p) => p.toJson()).toList(),
      'scheduled_reception': scheduledReception.toIso8601String(),
      'bay': bay,
    };
  }

  /// Total quantity across all products
  int get totalQuantity {
    return products.fold(0, (sum, product) => sum + product.quantityReceived);
  }

  /// Format product SKUs for display (e.g., "SKU-442, SKU-109, SKU-882")
  String get productSkusFormatted {
    return products.map((p) => 'SKU-${p.sku}').join(', ');
  }

  CommandOrder copyWith({
    String? deliveryId,
    List<ProductLine>? products,
    DateTime? scheduledReception,
    String? bay,
  }) {
    return CommandOrder(
      deliveryId: deliveryId ?? this.deliveryId,
      products: products ?? this.products,
      scheduledReception: scheduledReception ?? this.scheduledReception,
      bay: bay ?? this.bay,
    );
  }
}
