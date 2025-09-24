from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import *
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

router = DefaultRouter()
router.register(r'productos', ProductoViewSet)
router.register(r'promociones', PromocionViewSet)
router.register(r'clientes', ClienteViewSet)
router.register(r'proveedores', ProveedorViewSet)
router.register(r'sucursales', SucursalViewSet)
router.register(r'categorias', CategoriaViewSet)
router.register(r'estanterias', EstanteriaViewSet)
router.register(r'pasillos', PasilloViewSet)


urlpatterns = [
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('', include(router.urls)),
]
