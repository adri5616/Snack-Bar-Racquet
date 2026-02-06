class Categoria {
  final int id;
  final String nombre;

  Categoria({required this.id, required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id_categoria'] ?? 0,
      nombre: json['nombre']?.toString() ?? 'Sin Nombre',
    );
  }
}

class Producto {
  final int id;
  final int idCategoria;
  final String nombre;
  final double precio;
  final int stock;

  Producto({
    required this.id,
    required this.idCategoria,
    required this.nombre,
    required this.precio,
    required this.stock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id_producto'] ?? 0,
      idCategoria: json['id_categoria'] ?? 0,
      nombre: json['nombre']?.toString() ?? 'Sin Nombre',
      // BLINDAJE AQUÍ: Si el precio es null, ponemos 0.0
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      // BLINDAJE AQUÍ: Si el stock es null, ponemos 0
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}

class ItemCarrito {
  final Producto producto;
  int cantidad;
  ItemCarrito({required this.producto, this.cantidad = 1});
  double get subtotal => producto.precio * cantidad;
}

class Venta {
  final int id;
  final DateTime fecha;
  final double total;
  final String metodoPago;

  Venta({required this.id, required this.fecha, required this.total, required this.metodoPago});

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id_venta'] ?? 0,
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      metodoPago: json['metodo_pago']?.toString() ?? 'Efectivo',
    );
  }
}

class CajaSesion {
  final int id;
  final DateTime fechaApertura;
  final double montoInicial;
  final String estado;

  CajaSesion({required this.id, required this.fechaApertura, required this.montoInicial, required this.estado});

  factory CajaSesion.fromJson(Map<String, dynamic> json) {
    return CajaSesion(
      id: json['id_caja'] ?? 0,
      fechaApertura: json['fecha_apertura'] != null ? DateTime.parse(json['fecha_apertura']) : DateTime.now(),
      montoInicial: (json['monto_inicial'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado']?.toString() ?? 'CERRADA',
    );
  }
}