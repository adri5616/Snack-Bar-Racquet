import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/snack_provider.dart';
import '../models/models.dart';

// --- PALETA MINIMALISTA ---
const kColorBackground = Color(0xFFFAFAFA);
const kColorSurface = Colors.white;
const kColorPrimary = Color(0xFF24BF5B); // VERDE PEDIDO
const kColorTextPrimary = Color(0xFF212121);
const kColorTextSecondary = Color(0xFF757575);
const kColorBorder = Color(0xFFEEEEEE);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SnackProvider>(context);

    // 1. PANTALLA DE APERTURA (Bloqueo)
    if (!provider.cajaAbierta) {
      return const _PantallaAperturaCaja();
    }

    return Scaffold(
      backgroundColor: kColorBackground,
      appBar: AppBar(
        backgroundColor: kColorSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: kColorBorder, height: 1),
        ),
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Snack Point",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kColorTextPrimary,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kColorPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Caja Abierta",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: kColorTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.power_settings_new_rounded,
              color: Colors.redAccent,
            ),
            tooltip: "Cerrar Turno",
            onPressed: () => _modalCerrarCaja(context, provider),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: _getBody(_index),

      // BOTÓN FLOTANTE SOLO EN INVENTARIO
      floatingActionButton: _index == 3
          ? FloatingActionButton.extended(
              onPressed: () => _modalAgregarProducto(context, provider),
              backgroundColor: kColorPrimary,
              elevation: 2,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                "Nuevo Producto",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: kColorSurface,
        surfaceTintColor: kColorSurface,
        indicatorColor: kColorPrimary.withOpacity(0.15),
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded, color: kColorTextSecondary),
            selectedIcon: Icon(Icons.grid_view_rounded, color: kColorPrimary),
            label: "Resumen",
          ),
          NavigationDestination(
            icon: Icon(Icons.lunch_dining_rounded, color: kColorTextSecondary),
            selectedIcon: Icon(
              Icons.lunch_dining_rounded,
              color: kColorPrimary,
            ),
            label: "Vender",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded, color: kColorTextSecondary),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
              color: kColorPrimary,
            ),
            label: "Historial",
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_rounded, color: kColorTextSecondary),
            selectedIcon: Icon(Icons.inventory_2_rounded, color: kColorPrimary),
            label: "Inventario",
          ),
        ],
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return const _VistaDashboard();
      case 1:
        return const _VistaVenta();
      case 2:
        return const _VistaReportes();
      case 3:
        return const _VistaInventario();
      default:
        return const SizedBox();
    }
  }

  // --- MODAL AGREGAR PRODUCTO (CON STOCK) ---
  void _modalAgregarProducto(BuildContext context, SnackProvider provider) {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: "0");
    int? catSeleccionada;
    if (provider.categorias.isNotEmpty)
      catSeleccionada = provider.categorias.first.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 25,
          ),
          decoration: const BoxDecoration(
            color: kColorSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nuevo Producto",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kColorTextPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nombreCtrl,
                style: const TextStyle(color: kColorTextPrimary),
                decoration: InputDecoration(
                  labelText: "Nombre",
                  filled: true,
                  fillColor: kColorBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: precioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Precio (Bs)",
                        filled: true,
                        fillColor: kColorBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Stock Inicial",
                        filled: true,
                        fillColor: kColorBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: kColorBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: catSeleccionada,
                    isExpanded: true,
                    items: provider.categorias
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => catSeleccionada = val),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    if (nombreCtrl.text.isNotEmpty &&
                        precioCtrl.text.isNotEmpty &&
                        catSeleccionada != null) {
                      final precio = double.tryParse(precioCtrl.text) ?? 0;
                      final stock = int.tryParse(stockCtrl.text) ?? 0;
                      final exito = await provider.agregarProducto(
                        nombreCtrl.text,
                        precio,
                        catSeleccionada!,
                        stock,
                      );
                      if (exito) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Producto guardado")),
                        );
                      }
                    }
                  },
                  child: Text(
                    "GUARDAR",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _modalCerrarCaja(BuildContext context, SnackProvider provider) {
    final montoCtrl = TextEditingController();
    final esperado = provider.calcularDineroEnCaja();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 25,
          left: 25,
          right: 25,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 25,
        ),
        decoration: const BoxDecoration(
          color: kColorSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cerrar Turno",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kColorTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: kColorBorder),
              ),
              child: Column(
                children: [
                  _FilaResumen("Caja Base", provider.cajaActual!.montoInicial),
                  _FilaResumen(
                    "Ventas Efectivo (+)",
                    provider.calcularVentasPorMetodo('Efectivo'),
                    color: kColorPrimary,
                  ),
                  const Divider(color: kColorBorder),
                  _FilaResumen("TOTAL EN CAJÓN", esperado, esTotal: true),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _FilaResumen(
                      "Digital (QR)",
                      provider.calcularVentasPorMetodo('QR'),
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Conteo Físico (Arqueo)",
              style: GoogleFonts.poppins(
                color: kColorTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: kColorTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "Bs. 0.00",
                prefixIcon: const Icon(
                  Icons.payments_outlined,
                  color: kColorTextSecondary,
                ),
                filled: true,
                fillColor: kColorBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: kColorBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: kColorPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  provider.cerrarCaja(double.tryParse(montoCtrl.text) ?? 0);
                  Navigator.pop(ctx);
                },
                child: Text(
                  "FINALIZAR TURNO",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 4. VISTA INVENTARIO (CON AJUSTE DE STOCK)
// =============================================================================
class _VistaInventario extends StatelessWidget {
  const _VistaInventario();

  void _mostrarAjusteStock(
    BuildContext context,
    SnackProvider provider,
    Producto p,
  ) {
    final cantidadCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 25,
          left: 25,
          right: 25,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 25,
        ),
        decoration: const BoxDecoration(
          color: kColorSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ajustar Stock: ${p.nombre}",
              style: GoogleFonts.poppins(
                color: kColorTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Stock actual: ${p.stock} unidades",
              style: GoogleFonts.poppins(
                color: kColorTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cantidadCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                color: kColorTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Cantidad",
                filled: true,
                fillColor: kColorBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      "QUITAR",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      final cant = int.tryParse(cantidadCtrl.text) ?? 0;
                      if (cant > 0) {
                        provider.ajustarStock(p.id, -cant);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Se descontaron $cant unidades"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      "AGREGAR",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      final cant = int.tryParse(cantidadCtrl.text) ?? 0;
                      if (cant > 0) {
                        provider.ajustarStock(p.id, cant);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Se agregaron $cant unidades"),
                            backgroundColor: kColorPrimary,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SnackProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gestión de Inventario",
            style: GoogleFonts.poppins(
              color: kColorTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.separated(
              itemCount: provider.productos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final p = provider.productos[i];
                final bajoStock = p.stock <= 5;
                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: kColorSurface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: kColorBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bajoStock
                              ? Colors.red.withOpacity(0.1)
                              : kColorPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${p.stock}",
                              style: GoogleFonts.poppins(
                                color: bajoStock ? Colors.red : kColorPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Unid.",
                              style: GoogleFonts.poppins(
                                color: bajoStock ? Colors.red : kColorPrimary,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nombre,
                              style: GoogleFonts.poppins(
                                color: kColorTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Bs. ${p.precio}",
                              style: GoogleFonts.poppins(
                                color: kColorTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.exposure,
                          color: Colors.blueGrey,
                        ),
                        tooltip: "Ajustar Stock",
                        onPressed: () =>
                            _mostrarAjusteStock(context, provider, p),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: kColorSurface,
                              title: const Text(
                                "¿Borrar?",
                                style: TextStyle(color: kColorTextPrimary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.eliminarProducto(p.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text(
                                    "Borrar",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 0. PANTALLA DE APERTURA
// =============================================================================
class _PantallaAperturaCaja extends StatelessWidget {
  const _PantallaAperturaCaja();
  @override
  Widget build(BuildContext context) {
    final montoCtrl = TextEditingController();
    final fechaHoy = DateFormat(
      "EEEE, d 'de' MMMM",
      'es',
    ).format(DateTime.now());
    final fb = fechaHoy[0].toUpperCase() + fechaHoy.substring(1);
    return Scaffold(
      backgroundColor: kColorSurface,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 60,
                    color: kColorPrimary,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Iniciar Turno",
                  style: GoogleFonts.poppins(
                    color: kColorTextPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  fb,
                  style: GoogleFonts.poppins(
                    color: kColorTextSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: montoCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: kColorTextPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: "Monto Inicial en Caja",
                    filled: true,
                    fillColor: kColorBackground,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: kColorBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: kColorPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final monto = double.tryParse(montoCtrl.text);
                      if (monto != null) {
                        final exito = await Provider.of<SnackProvider>(
                          context,
                          listen: false,
                        ).abrirCaja(monto);
                        if (!exito && context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Error al abrir."),
                              backgroundColor: Colors.red,
                            ),
                          );
                      }
                    },
                    child: Text(
                      "ABRIR CAJA",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 1. VISTA DASHBOARD
// =============================================================================
class _VistaDashboard extends StatelessWidget {
  const _VistaDashboard();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SnackProvider>(context);
    final vt = provider.calcularTotalVentas();
    final dc = provider.calcularDineroEnCaja();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Balance del Turno",
            style: GoogleFonts.poppins(
              color: kColorTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Ventas Totales",
                  value: vt,
                  icon: Icons.bar_chart_rounded,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _StatCard(
                  title: "Efectivo Caja",
                  value: dc,
                  icon: Icons.attach_money_rounded,
                  isPrimary: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            "Actividad Reciente",
            style: GoogleFonts.poppins(
              color: kColorTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          if (provider.ventasDelDia.isEmpty)
            _EmptyState(icon: Icons.receipt_long, text: "Sin ventas aún"),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.ventasDelDia.take(10).length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: kColorBorder),
            itemBuilder: (ctx, i) {
              final v = provider.ventasDelDia[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kColorBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    v.metodoPago == 'Efectivo'
                        ? Icons.payments_rounded
                        : Icons.qr_code_2_rounded,
                    color: kColorTextSecondary,
                  ),
                ),
                title: Text(
                  "Venta #${v.id}",
                  style: GoogleFonts.poppins(
                    color: kColorTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  DateFormat('hh:mm a').format(v.fecha),
                  style: GoogleFonts.poppins(
                    color: kColorTextSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  "+ ${v.total.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    color: kColorPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final bool isPrimary;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isPrimary,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kColorSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kColorBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPrimary
                ? kColorPrimary.withOpacity(0.1)
                : kColorBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isPrimary ? kColorPrimary : kColorTextSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: GoogleFonts.poppins(color: kColorTextSecondary, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          "Bs. ${value.toStringAsFixed(0)}",
          style: GoogleFonts.poppins(
            color: kColorTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
// 2. VISTA POS
// =============================================================================
class _VistaVenta extends StatefulWidget {
  const _VistaVenta();
  @override
  State<_VistaVenta> createState() => _VistaVentaState();
}

class _VistaVentaState extends State<_VistaVenta> {
  int? _catId;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SnackProvider>(context);
    final prods = _catId == null
        ? provider.productos
        : provider.productos.where((p) => p.idCategoria == _catId).toList();
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: kColorSurface,
                border: Border(bottom: BorderSide(color: kColorBorder)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                children: [
                  _CategoryPill(
                    label: "Todas",
                    isActive: _catId == null,
                    onTap: () => setState(() => _catId = null),
                  ),
                  ...provider.categorias.map(
                    (c) => _CategoryPill(
                      label: c.nombre,
                      isActive: _catId == c.id,
                      onTap: () => setState(() => _catId = c.id),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: prods.isEmpty
                  ? _EmptyState(
                      icon: Icons.fastfood_outlined,
                      text: "No hay productos",
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemCount: prods.length,
                      itemBuilder: (ctx, i) {
                        final p = prods[i];
                        return GestureDetector(
                          onTap: () {
                            provider.agregarAlCarrito(p);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: kColorSurface,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: kColorBorder),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Icon(
                                          Icons.lunch_dining,
                                          size: 40,
                                          color: kColorTextSecondary
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        p.nombre,
                                        style: GoogleFonts.poppins(
                                          color: kColorTextPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Bs. ${p.precio}",
                                      style: GoogleFonts.poppins(
                                        color: kColorPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: kColorBackground,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: kColorTextPrimary,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        if (provider.carrito.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => _mostrarCarrito(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: kColorPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kColorPrimary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${provider.itemsTotales}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "Ver Pedido",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Bs. ${provider.totalCarrito.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _mostrarCarrito(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Consumer<SnackProvider>(
        builder: (context, prov, _) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: kColorSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kColorBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  "Detalle del Pedido",
                  style: GoogleFonts.poppins(
                    color: kColorTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: prov.carrito.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: kColorBorder),
                  itemBuilder: (ctx, i) {
                    final item = prov.carrito[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fastfood,
                            color: kColorTextSecondary,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.producto.nombre,
                                  style: GoogleFonts.poppins(
                                    color: kColorTextPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Bs. ${item.producto.precio}",
                                  style: GoogleFonts.poppins(
                                    color: kColorTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _RoundBtn(
                                icon: Icons.remove,
                                onTap: () =>
                                    prov.quitarDelCarrito(item.producto),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  "${item.cantidad}",
                                  style: GoogleFonts.poppins(
                                    color: kColorTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              _RoundBtn(
                                icon: Icons.add,
                                onTap: () =>
                                    prov.agregarAlCarrito(item.producto),
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: kColorBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total a Pagar",
                          style: GoogleFonts.poppins(
                            color: kColorTextSecondary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Bs. ${prov.totalCarrito.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            color: kColorTextPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: _PayBtn(
                            label: "QR",
                            icon: Icons.qr_code,
                            isOutline: true,
                            onTap: () {
                              prov.cobrar("QR");
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _PayBtn(
                            label: "EFECTIVO",
                            icon: Icons.payments,
                            isOutline: false,
                            onTap: () {
                              prov.cobrar("Efectivo");
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 3. VISTA REPORTES
// =============================================================================
class _VistaReportes extends StatelessWidget {
  const _VistaReportes();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SnackProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Historial Completo",
            style: GoogleFonts.poppins(
              color: kColorTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: provider.ventasDelDia.isEmpty
                ? _EmptyState(
                    icon: Icons.history_toggle_off,
                    text: "Sin ventas",
                  )
                : ListView.separated(
                    itemCount: provider.ventasDelDia.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: kColorBorder),
                    itemBuilder: (ctx, i) {
                      final v = provider.ventasDelDia[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kColorBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            v.metodoPago == 'Efectivo'
                                ? Icons.payments_rounded
                                : Icons.qr_code_2_rounded,
                            color: kColorTextSecondary,
                          ),
                        ),
                        title: Text(
                          "Venta #${v.id}",
                          style: GoogleFonts.poppins(
                            color: kColorTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          v.metodoPago,
                          style: GoogleFonts.poppins(
                            color: kColorTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Bs. ${v.total.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                color: kColorPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(v.fecha),
                              style: GoogleFonts.poppins(
                                color: kColorTextSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String label;
  final double monto;
  final Color? color;
  final bool esTotal;
  const _FilaResumen(
    this.label,
    this.monto, {
    this.color,
    this.esTotal = false,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: kColorTextSecondary,
            fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "Bs. ${monto.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            color: color ?? kColorTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: esTotal ? 18 : 14,
          ),
        ),
      ],
    ),
  );
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kColorPrimary : kColorBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? kColorPrimary : kColorBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.white : kColorTextSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    ),
  );
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  const _RoundBtn({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isPrimary ? kColorPrimary : kColorBackground,
        shape: BoxShape.circle,
        border: Border.all(color: isPrimary ? kColorPrimary : kColorBorder),
      ),
      child: Icon(
        icon,
        color: isPrimary ? Colors.white : kColorTextSecondary,
        size: 18,
      ),
    ),
  );
}

class _PayBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOutline;
  final VoidCallback onTap;
  const _PayBtn({
    required this.label,
    required this.icon,
    required this.isOutline,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: isOutline ? kColorSurface : kColorPrimary,
      foregroundColor: isOutline ? kColorTextPrimary : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      elevation: 0,
      side: isOutline ? const BorderSide(color: kColorBorder) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    onPressed: onTap,
    icon: Icon(icon),
    label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 50, color: kColorBorder),
        const SizedBox(height: 15),
        Text(text, style: GoogleFonts.poppins(color: kColorTextSecondary)),
      ],
    ),
  );
}
