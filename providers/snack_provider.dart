import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SnackProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Categoria> categorias = [];
  List<Producto> productos = [];
  CajaSesion? cajaActual;
  List<Venta> ventasDelDia = [];
  List<ItemCarrito> carrito = [];

  bool get cajaAbierta => cajaActual != null;

  SnackProvider() { initApp(); }

  Future<void> initApp() async { await cargarInventario(); await verificarCajaAbierta(); }

  Future<void> cargarInventario() async {
    try {
      final resCat = await supabase.from('categorias').select().order('nombre');
      categorias = (resCat as List).map((e) => Categoria.fromJson(e)).toList();
      final resProd = await supabase.from('productos').select().eq('activo', true).order('nombre');
      productos = (resProd as List).map((e) => Producto.fromJson(e)).toList();
      notifyListeners();
    } catch (e) { debugPrint("Error inventario: $e"); }
  }

  // --- GESTIÓN DE PRODUCTOS Y STOCK ---
  
  Future<bool> agregarProducto(String nombre, double precio, int idCategoria, int stockInicial) async {
    try {
      await supabase.from('productos').insert({
        'nombre': nombre, 'precio': precio, 'id_categoria': idCategoria, 'stock': stockInicial, 'activo': true
      });
      await cargarInventario();
      return true;
    } catch (e) { return false; }
  }

  // NUEVO: Función para sumar o restar stock manual
  Future<bool> ajustarStock(int idProducto, int cantidadAjuste) async {
    try {
      // Usamos una función RPC o simplemente leemos y actualizamos. 
      // Para simplificar y evitar crear funciones SQL complejas, leemos el actual y sumamos en Dart.
      final prod = productos.firstWhere((p) => p.id == idProducto);
      final nuevoStock = prod.stock + cantidadAjuste;

      await supabase.from('productos').update({'stock': nuevoStock}).eq('id_producto', idProducto);
      await cargarInventario(); // Recargamos para ver el cambio
      return true;
    } catch (e) { return false; }
  }

  Future<void> eliminarProducto(int idProducto) async {
    try { await supabase.from('productos').update({'activo': false}).eq('id_producto', idProducto); await cargarInventario(); } catch (e) {}
  }

  // --- CAJA ---
  Future<void> verificarCajaAbierta() async {
    try {
      final res = await supabase.from('caja_sesiones').select().eq('estado', 'ABIERTA').maybeSingle();
      if (res != null) { cajaActual = CajaSesion.fromJson(res); await cargarVentasCajaActual(); } 
      else { cajaActual = null; ventasDelDia = []; }
      notifyListeners();
    } catch (e) {}
  }

  Future<bool> abrirCaja(double montoInicial) async {
    try {
      final res = await supabase.from('caja_sesiones').insert({'monto_inicial': montoInicial, 'fecha_apertura': DateTime.now().toIso8601String(), 'estado': 'ABIERTA'}).select().single();
      cajaActual = CajaSesion.fromJson(res); ventasDelDia = []; notifyListeners(); return true; 
    } catch (e) { return false; }
  }

  Future<void> cerrarCaja(double montoRealContado) async {
    if (cajaActual == null) return;
    try {
      final esperado = cajaActual!.montoInicial + calcularVentasPorMetodo('Efectivo');
      await supabase.from('caja_sesiones').update({'fecha_cierre': DateTime.now().toIso8601String(), 'monto_final_esperado': esperado, 'monto_final_real': montoRealContado, 'estado': 'CERRADA'}).eq('id_caja', cajaActual!.id);
      cajaActual = null; ventasDelDia = []; notifyListeners();
    } catch (e) {}
  }

  Future<void> cargarVentasCajaActual() async {
    if (cajaActual == null) return;
    try {
      final res = await supabase.from('ventas').select().eq('id_caja', cajaActual!.id).order('fecha', ascending: false);
      ventasDelDia = (res as List).map((e) => Venta.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {}
  }

  // --- CARRITO Y COBRO ---
  void agregarAlCarrito(Producto prod) {
    if (!cajaAbierta) return;
    final index = carrito.indexWhere((i) => i.producto.id == prod.id);
    // VALIDACIÓN VISUAL: No permitir agregar más del stock (opcional, pero recomendado)
    // if (index != -1 && carrito[index].cantidad >= prod.stock) return; 
    
    if (index != -1) carrito[index].cantidad++;
    else carrito.add(ItemCarrito(producto: prod));
    notifyListeners();
  }

  void quitarDelCarrito(Producto prod) {
    final index = carrito.indexWhere((i) => i.producto.id == prod.id);
    if (index == -1) return;
    if (carrito[index].cantidad > 1) carrito[index].cantidad--; else carrito.removeAt(index);
    notifyListeners();
  }
  void vaciarCarrito() { carrito.clear(); notifyListeners(); }
  double get totalCarrito => carrito.fold(0, (sum, i) => sum + i.subtotal);
  int get itemsTotales => carrito.fold(0, (sum, i) => sum + i.cantidad);

  Future<bool> cobrar(String metodo) async {
    if (cajaActual == null || carrito.isEmpty) return false;
    try {
      final total = totalCarrito;
      // 1. Crear Venta
      final resVenta = await supabase.from('ventas').insert({'id_caja': cajaActual!.id, 'total': total, 'metodo_pago': metodo}).select().single();
      final idVenta = resVenta['id_venta'];

      // 2. Detalles y DESCUENTO DE STOCK
      for (var item in carrito) {
        // Guardar detalle
        await supabase.from('detalle_ventas').insert({
          'id_venta': idVenta, 'id_producto': item.producto.id, 'cantidad': item.cantidad, 'precio_unitario': item.producto.precio
        });
        
        // Descontar Stock (Lógica simple: Stock Actual - Cantidad Vendida)
        final nuevoStock = item.producto.stock - item.cantidad;
        await supabase.from('productos').update({'stock': nuevoStock}).eq('id_producto', item.producto.id);
      }
      
      vaciarCarrito();
      await cargarInventario(); // Actualizar inventario visualmente
      await cargarVentasCajaActual();
      return true;
    } catch (e) { return false; }
  }

  // --- CALCULOS ---
  double calcularTotalVentas() => ventasDelDia.fold(0, (sum, v) => sum + v.total);
  double calcularVentasPorMetodo(String metodo) => ventasDelDia.where((v) => v.metodoPago == metodo).fold(0.0, (sum, v) => sum + v.total);
  double calcularDineroEnCaja() => cajaActual == null ? 0.0 : cajaActual!.montoInicial + calcularVentasPorMetodo('Efectivo');
}