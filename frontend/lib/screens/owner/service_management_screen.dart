import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/service_provider.dart';
import '../../widgets/common_widgets.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices(activeOnly: false);
    });
  }

  void _showServiceDialog({String? serviceId}) {
    final serviceProvider = context.read<ServiceProvider>();
    final service = serviceId != null
        ? serviceProvider.services.firstWhere((s) => s.id == serviceId)
        : null;

    final nameController = TextEditingController(text: service?.name);
    final descriptionController = TextEditingController(text: service?.description);
    final priceController = TextEditingController(
      text: service?.price.toStringAsFixed(2),
    );
    final timeController = TextEditingController(
      text: service?.estimatedTime.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  service == null ? 'Add New Service' : 'Edit Service',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: nameController,
                  label: 'Service Name',
                  prefixIcon: Icons.build_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: priceController,
                        label: 'Price (\$)',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: timeController,
                        label: 'Time (min)',
                        prefixIcon: Icons.access_time,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter time';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: service == null ? 'Add Service' : 'Update Service',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    bool success;
                    if (service == null) {
                      success = await serviceProvider.createService(
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        estimatedTime: int.parse(timeController.text),
                      );
                    } else {
                      success = await serviceProvider.updateService(
                        id: service.id,
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        estimatedTime: int.parse(timeController.text),
                      );
                    }

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            service == null
                                ? 'Service added successfully'
                                : 'Service updated successfully',
                          ),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String serviceId, String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "$serviceName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<ServiceProvider>().deleteService(serviceId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service deleted'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showServiceDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => serviceProvider.loadServices(activeOnly: false),
        child: serviceProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : serviceProvider.services.isEmpty
                ? EmptyState(
                    icon: Icons.build_outlined,
                    title: 'No services yet',
                    description: 'Add your first service to get started',
                    action: GradientButton(
                      text: 'Add Service',
                      width: 200,
                      onPressed: () => _showServiceDialog(),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: serviceProvider.services.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final service = serviceProvider.services[index];
                      return ServiceCard(
                        name: service.name,
                        description: service.description,
                        price: service.price,
                        estimatedTime: service.estimatedTimeDisplay,
                        showActions: true,
                        onEdit: () => _showServiceDialog(serviceId: service.id),
                        onDelete: () => _confirmDelete(service.id, service.name),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Service', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
