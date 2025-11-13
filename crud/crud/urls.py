from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    # Incluye las rutas de la API (si las tienes separadas)
    path('api/', include('mantenedores.api_urls')),
    
    # Incluye todas las rutas de tu archivo mantenedores/urls.py
    path('', include('mantenedores.urls')),
]

# Esta configuración SÍ va aquí.
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)