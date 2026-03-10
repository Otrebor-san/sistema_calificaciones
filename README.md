# 📚 Sistema de Calificaciones

Aplicación móvil desarrollada en **Flutter** para gestionar calificaciones estudiantiles.

## 🚀 Tecnologías utilizadas
- Flutter (Dart)
- SQLite (sqflite) — persistencia local
- Provider — gestión de estado (patrón MVVM)
- Material Design 3

## 📋 Funcionalidades
- ✅ Listar calificaciones activas
- ✅ Crear nueva calificación
- ✅ Ver detalle de calificación
- ✅ Editar calificación existente
- ✅ Eliminación lógica (estado A/I)
- ✅ Búsqueda por nombre o materia
- ✅ Filtro por rango de nota (Aprobado / Regular / Reprobado)

## 🗂 Estructura del proyecto
```
lib/
├── main.dart
├── database/
│   └── database_helper.dart
├── models/
│   └── calificacion.dart
├── providers/
│   └── calificacion_provider.dart
└── screens/
    ├── lista_screen.dart
    └── detalle_screen.dart
```

## 🛠 Cómo correr el proyecto
1. Clona el repositorio
2. Ejecuta `flutter pub get`
3. Ejecuta `flutter run`

## 📊 Modelo de datos
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id    | INTEGER | Auto incrementable |
| nombreEstudiante | TEXT | Nombre del estudiante |
| materia | TEXT | Materia cursada |
| profesor | TEXT | Nombre del profesor |
| notaFinal | REAL | Nota entre 0 y 10 |
| estado | TEXT | A = Activo, I = Inactivo |


## 🎨 Interfaz
- 🟢 Verde — Aprobado (7 - 10)
- 🟠 Naranja — Regular (5 - 6.99)
- 🔴 Rojo — Reprobado (0 - 4.99)