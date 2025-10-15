import 'package:flutter/material.dart';
import 'lib/notification_item.dart'; // Importa el modelo de datos

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Lista de notificaciones de ejemplo
  final List<NotificationItem> _notifications = [
    NotificationItem(
      icon: Icons.local_offer,
      title: '¡Nueva Oferta!',
      body: 'El producto "Leche Entera" tiene un 15% de descuento.',
      time: 'Hace 5m',
    ),
    NotificationItem(
      icon: Icons.info,
      title: 'Mantenimiento Programado',
      body: 'La app estará en mantenimiento esta noche de 2 a 3 AM.',
      time: 'Hace 2h',
      isRead: true,
    ),
    NotificationItem(
      icon: Icons.new_releases,
      title: 'Nuevos Productos',
      body: 'Hemos añadido nuevos productos en la sección de Lácteos.',
      time: 'Ayer',
    ),
  ];

  /// Marca todas las notificaciones como leídas
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  /// Elimina todas las notificaciones
  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          // Botones de acción solo si hay notificaciones
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Marcar todo como leído',
              onPressed: _markAllAsRead,
            ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Borrar todo',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _notifications.isEmpty
          // Muestra un mensaje si la lista está vacía
          ? _buildEmptyState()
          // Muestra la lista de notificaciones
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
    );
  }

  /// Construye la UI para el estado vacío (sin notificaciones)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Construye la UI para una sola tarjeta de notificación
  Widget _buildNotificationTile(NotificationItem notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Indicador de no leído
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      notification.icon,
                      size: 30,
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Contenido de la notificación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Hora
              Text(
                notification.time,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
