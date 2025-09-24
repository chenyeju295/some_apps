import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/balance_controller.dart';
import '../models/product_model.dart';
import '../services/in_app_purchase_service.dart';

class ShopDialog extends StatelessWidget {
  const ShopDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final iapService = Get.find<InAppPurchaseService>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Crystal Shop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Store status and restore button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Obx(() => Icon(
                        iapService.isAvailable.value
                            ? Icons.check_circle
                            : Icons.error,
                        color: iapService.isAvailable.value
                            ? Colors.green
                            : Colors.red,
                        size: 16,
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => Text(
                          iapService.isAvailable.value
                              ? 'App Store is available'
                              : 'App Store is not available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                        )),
                  ),
                  TextButton(
                    onPressed: () => iapService.restorePurchases(),
                    child:
                        const Text('Restore', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Products List
            Flexible(
              child: Obx(() {
                if (iapService.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shrinkWrap: true,
                  itemCount: ProductModel.products.length,
                  itemBuilder: (context, index) {
                    return ProductItem(
                      product: ProductModel.products[index],
                      onPurchase: () => _handlePurchase(
                          context, ProductModel.products[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context, ProductModel product) async {
    final balanceController = Get.find<BalanceController>();

    // Attempt purchase - loading and success/error handling is done in the service
    final success = await balanceController.purchaseCrystals(
      product.productId,
      product.crystals,
      product.price,
    );

    if (success) {
      // Close shop dialog
      Navigator.of(context).pop();
    }
    // Error handling is done in the service
  }
}

class ProductItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onPurchase;

  const ProductItem({
    super.key,
    required this.product,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isPopular
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.3),
          width: product.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPurchase,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Crystal Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.diamond,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${product.crystals}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(product.crystalsPerDollar).toInt()} crystals per dollar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price & Buy Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Show real App Store price if available
                    Builder(
                      builder: (context) {
                        final iapService = Get.find<InAppPurchaseService>();
                        final localizedPrice =
                            iapService.getLocalizedPrice(product.productId);

                        return Text(
                          localizedPrice != 'N/A'
                              ? localizedPrice
                              : product.formattedPrice,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: product.isPopular
                            ? Theme.of(context).primaryColor
                            : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
