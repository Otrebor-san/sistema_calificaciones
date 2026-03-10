import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/calificacion.dart';

class CalificacionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Calificacion> _calificaciones = [];
  String _busqueda = '';
  String _filtroNota = 'todos'; // 'todos', 'alta', 'media', 'baja'
  bool _cargando = false;

  // Getters
  List<Calificacion> get calificaciones => _calificaciones;
  String get busqueda => _busqueda;
  String get filtroNota => _filtroNota;
  bool get cargando => _cargando;

  // Cargar todas las calificaciones
  Future<void> cargarCalificaciones() async {
    _cargando = true;
    notifyListeners();

    if (_busqueda.isNotEmpty) {
      _calificaciones = await _db.buscar(_busqueda);
    } else if (_filtroNota == 'alta') {
      _calificaciones = await _db.filtrarPorNota(7, 10);
    } else if (_filtroNota == 'media') {
      _calificaciones = await _db.filtrarPorNota(5, 6.99);
    } else if (_filtroNota == 'baja') {
      _calificaciones = await _db.filtrarPorNota(0, 4.99);
    } else {
      _calificaciones = await _db.obtenerTodos();
    }

    _cargando = false;
    notifyListeners();
  }

  // Crear calificacion
  Future<void> crear(Calificacion calificacion) async {
    await _db.crear(calificacion);
    await cargarCalificaciones();
  }

  // Actualizar calificacion
  Future<void> actualizar(Calificacion calificacion) async {
    await _db.actualizar(calificacion);
    await cargarCalificaciones();
  }

  // Eliminar calificacion (logica)
  Future<void> eliminar(int id) async {
    await _db.eliminar(id);
    await cargarCalificaciones();
  }

  // Buscar por texto
  void setBusqueda(String texto) {
    _busqueda = texto;
    _filtroNota = 'todos';
    cargarCalificaciones();
  }

  // Filtrar por rango de nota
  void setFiltroNota(String filtro) {
    _filtroNota = filtro;
    _busqueda = '';
    cargarCalificaciones();
  }

  // Limpiar filtros
  void limpiarFiltros() {
    _busqueda = '';
    _filtroNota = 'todos';
    cargarCalificaciones();
  }
}