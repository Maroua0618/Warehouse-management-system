// Model for Bon de commande (Command Order)
class CommandOrder {
  final String deliveryId;
  final DateTime receptionAt;
  final List<CommandOrderItem> items;

  CommandOrder({
    required this.deliveryId,
    required this.receptionAt,
    required this.items,
  });

  factory CommandOrder.fromJson(Map<String, dynamic> json) {
    return CommandOrder(
      deliveryId: json['delivery_id'] ?? '',
      receptionAt: json['reception_at'] != null
          ? DateTime.parse(json['reception_at'])
          : DateTime.now(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => CommandOrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_id': deliveryId,
      'reception_at': receptionAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CommandOrderItem {
  final String productIdentifier; // Can be SKU code or ID
  final int quantityReceived;
  final String? productName;

  CommandOrderItem({
    required this.productIdentifier,
    required this.quantityReceived,
    this.productName,
  });

  factory CommandOrderItem.fromJson(Map<String, dynamic> json) {
    return CommandOrderItem(
      productIdentifier: json['product_identifier'] ?? json['sku_code'] ?? '',
      quantityReceived: json['quantity_received'] ?? json['qty'] ?? 0,
      productName: json['product_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_identifier': productIdentifier,
      'quantity_received': quantityReceived,
      'product_name': productName,
    };
  }
}
