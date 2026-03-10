import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calificacion_provider.dart';
import '../models/calificacion.dart';
import 'detalle_screen.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<CalificacionProvider>().cargarCalificaciones());
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Color _colorNota(double nota) {
    if (nota >= 7) return Colors.green;
    if (nota >= 5) return Colors.orange;
    return Colors.red;
  }

  String _etiquetaNota(double nota) {
    if (nota >= 7) return 'Aprobado';
    if (nota >= 5) return 'Regular';
    return 'Reprobado';
  }

  void _confirmarEliminar(BuildContext context, Calificacion c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar calificación'),
        content: Text('¿Deseas eliminar a ${c.nombreEstudiante}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CalificacionProvider>().eliminar(c.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calificación eliminada')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalificacionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Calificaciones',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: provider.mostrarInactivos
                ? null
                : () => _mostrarFiltros(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Switch mostrar inactivos
          Container(
            color: const Color(0xFF1565C0).withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      provider.mostrarInactivos
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.mostrarInactivos
                          ? 'Mostrando inactivos'
                          : 'Solo activos',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1565C0)),
                    ),
                  ],
                ),
                Switch(
                  value: provider.mostrarInactivos,
                  onChanged: (_) => provider.toggleMostrarInactivos(),
                  activeColor: const Color(0xFF1565C0),
                ),
              ],
            ),
          ),

          // Barra de búsqueda (oculta si muestra inactivos)
          if (!provider.mostrarInactivos)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _busquedaController,
                decoration: InputDecoration(
                  hintText: 'Buscar por estudiante o materia...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _busquedaController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _busquedaController.clear();
                            provider.limpiarFiltros();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) => provider.setBusqueda(value),
              ),
            ),

          // Chip de filtro activo
          if (provider.filtroNota != 'todos' && !provider.mostrarInactivos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Chip(
                    label: Text(_labelFiltro(provider.filtroNota)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => provider.limpiarFiltros(),
                    backgroundColor: const Color(0xFF1565C0),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Lista
          Expanded(
            child: provider.cargando
                ? const Center(child: CircularProgressIndicator())
                : provider.calificaciones.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No hay calificaciones',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.calificaciones.length,
                        itemBuilder: (context, index) {
                          final c = provider.calificaciones[index];
                          final esInactivo = c.estado == 'I';

                          return Opacity(
                            opacity: esInactivo ? 0.5 : 1.0,
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: esInactivo
                                      ? const BorderSide(
                                          color: Colors.red, width: 1)
                                      : BorderSide.none),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: esInactivo
                                      ? Colors.grey
                                      : _colorNota(c.notaFinal),
                                  child: Text(
                                    c.notaFinal.toStringAsFixed(1),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(c.nombreEstudiante,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration: esInactivo
                                                  ? TextDecoration.lineThrough
                                                  : null)),
                                    ),
                                    if (esInactivo)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text('INACTIVO',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Materia: ${c.materia}'),
                                    Text('Profesor: ${c.profesor}'),
                                    if (!esInactivo)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _colorNota(c.notaFinal)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _etiquetaNota(c.notaFinal),
                                          style: TextStyle(
                                              color: _colorNota(c.notaFinal),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: esInactivo
                                    ? null
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility,
                                                color: Colors.blue),
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => DetalleScreen(
                                                    calificacion: c,
                                                    soloVer: true),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.orange),
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => DetalleScreen(
                                                    calificacion: c,
                                                    soloVer: false),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _confirmarEliminar(context, c),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: provider.mostrarInactivos
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DetalleScreen(
                      calificacion: null, soloVer: false),
                ),
              ),
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.add, color: Colors.white),
              label:
                  const Text('Nueva', style: TextStyle(color: Colors.white)),
            ),
    );
  }

  String _labelFiltro(String filtro) {
    switch (filtro) {
      case 'alta':
        return 'Nota: 7 - 10';
      case 'media':
        return 'Nota: 5 - 6.99';
      case 'baja':
        return 'Nota: 0 - 4.99';
      default:
        return 'Todos';
    }
  }

  void _mostrarFiltros(BuildContext context, CalificacionProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar por nota',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.green),
              title: const Text('Aprobado (7 - 10)'),
              onTap: () {
                provider.setFiltroNota('alta');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.orange),
              title: const Text('Regular (5 - 6.99)'),
              onTap: () {
                provider.setFiltroNota('media');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.red),
              title: const Text('Reprobado (0 - 4.99)'),
              onTap: () {
                provider.setFiltroNota('baja');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Todos'),
              onTap: () {
                provider.limpiarFiltros();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}