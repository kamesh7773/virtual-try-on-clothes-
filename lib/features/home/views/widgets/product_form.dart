import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/widgets/custom_button.dart';

class ProductFormResult {
  final String title;
  final num price;
  final String description;

  const ProductFormResult({
    required this.title,
    required this.price,
    required this.description,
  });
}

class ProductForm extends HookWidget {
  final String title;
  final String initialTitle;
  final String initialPrice;
  final String initialDescription;
  final String submitLabel;

  const ProductForm({
    super.key,
    required this.title,
    this.initialTitle = '',
    this.initialPrice = '',
    this.initialDescription = '',
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final titleCtrl = useTextEditingController(text: initialTitle);
    final priceCtrl = useTextEditingController(text: initialPrice);
    final descriptionCtrl = useTextEditingController(text: initialDescription);
    final formKey = useMemoized(() => GlobalKey<FormState>(), const []);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Title is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Price is required';
              final parsed = num.tryParse(v.trim());
              if (parsed == null || parsed < 0) return 'Enter a valid price';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descriptionCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Description is required'
                : null,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: submitLabel,
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.of(context).pop(
                ProductFormResult(
                  title: titleCtrl.text.trim(),
                  price: num.parse(priceCtrl.text.trim()),
                  description: descriptionCtrl.text.trim(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
