// lib/features/offer_form/screens/offer_form_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'offer_form_controller.dart';

class OfferFormScreen extends GetView<OfferFormController> {
  const OfferFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing.value ? 'تعديل العرض' : 'إضافة عرض جديد')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("معلومات العرض الأساسية", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.offerNameController,
                decoration: const InputDecoration(labelText: 'اسم/معرّف العرض', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.annualPriceController,
                decoration: const InputDecoration(labelText: 'السعر السنوي', border: OutlineInputBorder(), suffixText: 'ل.س'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 24),
              Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("تفاصيل التغطية", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                    onPressed: controller.addCoverageDetail,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.coverageDetails.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.coverageDetails[index],
                            decoration: InputDecoration(
                              labelText: 'ميزة #${index + 1}',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                          ),
                        ),
                        if (controller.coverageDetails.length > 1)
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                            onPressed: () => controller.removeCoverageDetail(index),
                          ),
                      ],
                    ),
                  );
                },
              )),
              const SizedBox(height: 32),
              Obx(() => Center(
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ العرض'),
                  onPressed: controller.saveOffer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}