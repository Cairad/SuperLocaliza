from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('producto', views.productos_list, name='productos_list'),
    path('categoria/', views.categoria_list, name='categoria_list'),
    path('estanteria/', views.estanteria_list, name='estanteria_list'),
    path('pasillo/', views.pasillo_list, name='pasillo_list'),
    path('cliente/', views.clientes_list, name='cliente_list'),
    path('sucursal/', views.sucursal_list, name='sucursal_list'),
    path('usuario/', views.usuarios_list, name='usuarios_list'),
    path('proveedor/', views.proveedores_list, name='proveedores_list'),
    path('promocion/', views.promociones_list, name='promociones_list'),
    path('api/token/refresh/', views.CustomTokenRefreshView.as_view(), name='token_refresh'),

    path('login/', auth_views.LoginView.as_view(template_name='core/login.html'), name='login'),
    path('logout/', auth_views.LogoutView.as_view(next_page='login'), name='logout'),
    path('', views.dashboard, name='dashboard'),
]
