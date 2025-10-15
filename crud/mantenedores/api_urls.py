from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import * # Importa todas tus vistas

# Router para los endpoints de datos (productos, clientes, etc.)
router = DefaultRouter()
router.register(r'productos', ProductoViewSet)
router.register(r'promociones', PromocionViewSet)
router.register(r'clientes', ClienteViewSet)
router.register(r'proveedores', ProveedorViewSet)
router.register(r'sucursales', SucursalViewSet)
router.register(r'categorias', CategoriaViewSet)
router.register(r'estanterias', EstanteriaViewSet)
router.register(r'pasillos', PasilloViewSet)

# URL Patterns
urlpatterns = [
    # --- NUEVAS URLs de Autenticación para CLIENTES (APP MÓVIL) ---
    path('clientes/token/', ClienteTokenObtainPairView.as_view(), name='cliente_token_obtain_pair'),
    path('clientes/token/refresh/', ClienteTokenRefreshView.as_view(), name='cliente_token_refresh'),

    # --- URLs para el resto de los datos de la API ---
    path('', include(router.urls)),
]