import 'package:flutter/material.dart';

import '../services/progress_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<ProgressData> _progressFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _progressFuture = ProgressService.load();
  }

  Future<void> _buyOrEquip(_ShopItem item, ProgressData progress) async {
    if (_saving) {
      return;
    }
    if (!progress.ownedItems.contains(item.id) && progress.coins < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes suficientes monedas.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ProgressService.purchaseAndEquip(
        itemId: item.id,
        price: item.price,
      );
      if (mounted) {
        setState(() => _progressFuture = ProgressService.load());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              progress.ownedItems.contains(item.id)
                  ? '${item.name} equipado.'
                  : '${item.name} comprado y equipado.',
            ),
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo completar la compra: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puesto del arqueólogo')),
      body: FutureBuilder<ProgressData>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('No se pudo cargar el inventario: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final progress = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.toll, color: Color(0xFFE9BD60)),
                    const SizedBox(width: 8),
                    Text(
                      'MONEDAS: ${progress.coins}',
                      style: const TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final owned = progress.ownedItems.contains(item.id);
                    final equipped = progress.equippedItem == item.id;
                    return Card(
                      color: const Color(0xFF24211C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                        side: const BorderSide(color: Color(0xFF59442E)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A2D20),
                            border: Border.all(color: const Color(0xFF80603B)),
                          ),
                          child: Icon(item.icon, color: item.color),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.description}\n'
                          '${owned ? 'Disponible' : 'Precio: ${item.price} monedas'}',
                        ),
                        isThreeLine: true,
                        trailing: SizedBox(
                          width: 110,
                          child: FilledButton(
                            onPressed: _saving || equipped
                                ? null
                                : () => _buyOrEquip(item, progress),
                            child: Text(
                              equipped
                                  ? 'Equipado'
                                  : owned
                                  ? 'Equipar'
                                  : 'Comprar',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShopItem {
  const _ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
}

const _items = <_ShopItem>[
  _ShopItem(
    id: 'explorer',
    name: 'Equipo de explorador',
    description: 'Equipo clásico para iniciar el viaje.',
    price: 0,
    icon: Icons.backpack_outlined,
    color: Color(0xFFB88C58),
  ),
  _ShopItem(
    id: 'torch',
    name: 'Antorcha antigua',
    description: 'Una llama cálida para las galerías profundas.',
    price: 40,
    icon: Icons.local_fire_department,
    color: Color(0xFFFFA33D),
  ),
  _ShopItem(
    id: 'armor',
    name: 'Armadura de piedra',
    description: 'Piedra tallada con marcas de otra expedición.',
    price: 75,
    icon: Icons.shield_outlined,
    color: Color(0xFF91A89B),
  ),
  _ShopItem(
    id: 'relic',
    name: 'Reliquia dorada',
    description: 'Un recuerdo brillante de las ruinas.',
    price: 120,
    icon: Icons.auto_awesome,
    color: Color(0xFFE9BD60),
  ),
];
