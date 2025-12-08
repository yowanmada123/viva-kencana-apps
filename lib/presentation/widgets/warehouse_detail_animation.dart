import 'package:flutter/material.dart';

class TruckLoadingAnimation extends StatefulWidget {
  const TruckLoadingAnimation({super.key});

  @override
  State<TruckLoadingAnimation> createState() => _TruckLoadingAnimationState();
}

class _TruckLoadingAnimationState extends State<TruckLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> boxMove;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // ⚡ lebih cepat
    )..repeat(reverse: true);

    boxMove = Tween<double>(
      begin: 0,
      end: 70, // 📦 bergerak lebih jauh
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ================= TRUCK KIRI =================
          Positioned(
            left: 40,
            child: SizedBox(
              width: 100,
              child: Column(
                children: [
                  Icon(Icons.warehouse, color: Colors.green.shade700, size: 55),
                  const Text("Warehouse", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),

          // ================= TRUCK KANAN =================
          Positioned(
            right: 40,
            child: SizedBox(
              width: 100,
              child: Column(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: const Color.fromARGB(255, 0, 126, 253),
                    size: 55,
                  ),
                  const Text("Truck", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),

          // ================= BOX ANIMATION =================
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Positioned(
                left:
                    MediaQuery.of(context).size.width / 2 - 20 + boxMove.value,
                child: Transform.scale(
                  scale: 1 + (controller.value * 0.2), // efek naik turun
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            },
          ),

          // ================= TITIK LOADING =================
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: controller,
                  builder:
                      (_, __) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              controller.value > (i * 0.3)
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
