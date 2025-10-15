from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .authentication import ClienteJWTAuthentication 
from django.contrib.auth.hashers import make_password
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .forms import *

from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated, AllowAny 
from .serializers import *
from .models import *

# Create your views here.
@login_required
def productos_list(request):
    productos = Producto.objects.all()
    form = ProductoForm()

    if request.method == 'POST':
        if "crear_producto" in request.POST:
            form = ProductoForm(request.POST)
            if form.is_valid():
                form.save()
                return redirect('productos_list')

        if "editar_producto" in request.POST:
            producto = get_object_or_404(Producto, id=request.POST.get("id"))
            form = ProductoForm(request.POST, instance=producto)
            if form.is_valid():
                form.save()
                return redirect('productos_list')

        if "eliminar_producto" in request.POST:
            producto = get_object_or_404(Producto, id=request.POST.get("id"))
            producto.delete()
            return redirect('productos_list')
        
    categorias = Categoria.objects.all()
    estanteria = Estanteria.objects.all()
    pasillo = Pasillo.objects.all()

    return render(request, 'core/productos_list.html', {
    'productos': productos,
    'form': form,
    'categorias': categorias,
    'estanteria': estanteria,
    'pasillo': pasillo,
    })

@login_required
def categoria_list(request):
    categorias = Categoria.objects.all()  # 🔹 lista plural
    form = CategoriaForm()                 # 🔹 form para crear categoría

    if request.method == 'POST':
        if "crear_categoria" in request.POST:
            form = CategoriaForm(request.POST)
            if form.is_valid():
                form.save()
                return redirect('categoria_list')

        if "editar_categoria" in request.POST:
            categoria = get_object_or_404(Categoria, id=request.POST.get("id"))
            form_editar = CategoriaForm(request.POST, instance=categoria)
            if form_editar.is_valid():
                form_editar.save()
                return redirect('categoria_list')

        if "eliminar_categoria" in request.POST:
            categoria = get_object_or_404(Categoria, id=request.POST.get("id"))
            categoria.delete()
            return redirect('categoria_list')

    return render(request, 'core/categoria_list.html', {
        'categorias': categorias,  # 🔹 pasar la lista
        'form': form               # 🔹 pasar el form
    })

@login_required
def estanteria_list(request):
    estanterias = Estanteria.objects.all()  # 🔹 lista plural
    form = EstanteriaForm()                 # 🔹 form para crear categoría

    if request.method == 'POST':
        if "crear_estanteria" in request.POST:
            form = EstanteriaForm(request.POST)
            if form.is_valid():
                form.save()
                return redirect('estanteria_list')

        if "editar_estanteria" in request.POST:
            estanteria = get_object_or_404(Estanteria, id=request.POST.get("id"))
            form_editar = EstanteriaForm(request.POST, instance=estanteria)
            if form_editar.is_valid():
                form_editar.save()
                return redirect('estanteria_list')

        if "eliminar_estanteria" in request.POST:
            estanteria = get_object_or_404(Estanteria, id=request.POST.get("id"))
            estanteria.delete()
            return redirect('estanteria_list')

    return render(request, 'core/estanteria_list.html', {
        'estanterias': estanterias,  # 🔹 pasar la lista
        'form': form               # 🔹 pasar el form
    })

@login_required
def pasillo_list(request):
    pasillos = Pasillo.objects.all()  # 🔹 lista plural
    form = PasilloForm()                 # 🔹 form para crear categoría

    if request.method == 'POST':
        if "crear_pasillo" in request.POST:
            form = PasilloForm(request.POST)
            if form.is_valid():
                form.save()
                return redirect('pasillo_list')

        if "editar_pasillo" in request.POST:
            pasillo = get_object_or_404(Pasillo, id=request.POST.get("id"))
            form_editar = PasilloForm(request.POST, instance=pasillo)
            if form_editar.is_valid():
                form_editar.save()
                return redirect('pasillo_list')

        if "eliminar_pasillo" in request.POST:
            pasillo = get_object_or_404(Pasillo, id=request.POST.get("id"))
            pasillo.delete()
            return redirect('pasillo_list')

    return render(request, 'core/pasillo_list.html', {
        'pasillos': pasillos,  # 🔹 pasar la lista
        'form': form               # 🔹 pasar el form
    })

@login_required
def clientes_list(request):
    clientes = Cliente.objects.all()
    form = ClienteForm()  # Form para crear

    if request.method == 'POST':
        # Crear cliente
        if "crear_cliente" in request.POST:
            form = ClienteForm(request.POST)
            if form.is_valid():
                cliente = form.save(commit=False)
                # Guardar la contraseña de forma segura
                cliente.password = make_password(form.cleaned_data['password'])
                cliente.save()
                return redirect('cliente_list')

        # Editar cliente
        if "editar_cliente" in request.POST:
            cliente = get_object_or_404(Cliente, id=request.POST.get("id"))
            form_editar = ClienteForm(request.POST, instance=cliente)
            if form_editar.is_valid():
                cliente_editado = form_editar.save(commit=False)
                # Solo actualizar la contraseña si se ingresó una nueva
                password = form_editar.cleaned_data.get('password')
                if password:
                    cliente_editado.password = make_password(password)
                cliente_editado.save()
                return redirect('cliente_list')


        # Eliminar cliente
        if "eliminar_cliente" in request.POST:
            cliente = get_object_or_404(Cliente, id=request.POST.get("id"))
            cliente.delete()
            return redirect('cliente_list')

    # Crear un form de edición para cada cliente
    for c in clientes:
        c.form_editar = ClienteForm(instance=c)

    return render(request, 'core/clientes_list.html', {
        'clientes': clientes,
        'form': form,
    })

@login_required
def sucursal_list(request):
    sucursales = Sucursal.objects.all()  # 🔹 lista plural
    form = SucursalForm()                 # 🔹 form para crear categoría

    if request.method == 'POST':
        if "crear_sucursal" in request.POST:
            form = SucursalForm(request.POST)
            if form.is_valid():
                form.save()
                return redirect('sucursal_list')

        if "editar_sucursal" in request.POST:
            sucursal = get_object_or_404(Sucursal, id=request.POST.get("id"))
            form_editar = SucursalForm(request.POST, instance=sucursal)
            if form_editar.is_valid():
                form_editar.save()
                return redirect('sucursal_list')

        if "eliminar_sucursal" in request.POST:
            sucursal = get_object_or_404(Sucursal, id=request.POST.get("id"))
            sucursal.delete()
            return redirect('sucursal_list')

    return render(request, 'core/sucursal_list.html', {
        'sucursales': sucursales,  # 🔹 pasar la lista
        'form': form               # 🔹 pasar el form
    })

@login_required
def usuarios_list(request):
    usuarios = Usuario.objects.all()
    form = UsuarioForm()  # Para crear

    # Generar forms de edición y meterlos dentro del usuario
    for u in usuarios:
        u.form_editar = UsuarioForm(instance=u)

    if request.method == 'POST':
        if "crear_usuario" in request.POST:
            form = UsuarioForm(request.POST)
            if form.is_valid():
                usuario = form.save(commit=False)
                if form.cleaned_data['password']:
                    usuario.set_password(form.cleaned_data['password'])
                usuario.save()
                return redirect('usuarios_list')

        if "editar_usuario" in request.POST:
            usuario = get_object_or_404(Usuario, id=request.POST.get("id"))
            form = UsuarioForm(request.POST, instance=usuario)
            if form.is_valid():
                usuario = form.save(commit=False)
                if form.cleaned_data['password']:
                    usuario.set_password(form.cleaned_data['password'])
                usuario.save()
                return redirect('usuarios_list')

        if "eliminar_usuario" in request.POST:
            usuario = get_object_or_404(Usuario, id=request.POST.get("id"))
            usuario.delete()
            return redirect('usuarios_list')

    return render(request, 'core/usuarios_list.html', {
        'usuarios': usuarios,
        'form': form,  # solo crear
    })

@login_required
def proveedores_list(request):
    proveedores = Proveedor.objects.all()
    form = ProveedorForm()

    if request.method == 'POST':
        if "crear_proveedor" in request.POST:
            form = ProveedorForm(request.POST)
            if form.is_valid():
                form.save()
                return redirect('proveedores_list')

        if "editar_proveedor" in request.POST:
            proveedor = get_object_or_404(Proveedor, id=request.POST.get("id"))
            form = ProveedorForm(request.POST, instance=proveedor)
            if form.is_valid():
                form.save()
                return redirect('proveedores_list')

        if "eliminar_proveedor" in request.POST:
            proveedor = get_object_or_404(Proveedor, id=request.POST.get("id"))
            proveedor.delete()
            return redirect('proveedores_list')

    # inyectar form_editar en cada proveedor
    for p in proveedores:
        p.form_editar = ProveedorForm(instance=p)

    return render(request, 'core/proveedores_list.html', {
        'proveedores': proveedores,
        'form': form,
    })

@login_required
def promociones_list(request):
    promociones = Promocion.objects.all()
    form = PromocionForm()

    if request.method == 'POST':
        if "crear_promocion" in request.POST:
            form = PromocionForm(request.POST)
            if form.is_valid():
                form.save()
                return redirect('promociones_list')

        if "editar_promocion" in request.POST:
            promocion = get_object_or_404(Promocion, id=request.POST.get("id"))
            form = PromocionForm(request.POST, instance=promocion)
            if form.is_valid():
                form.save()
                return redirect('promociones_list')

        if "eliminar_promocion" in request.POST:
            promocion = get_object_or_404(Promocion, id=request.POST.get("id"))
            promocion.delete()
            return redirect('promociones_list')

    # Crear forms individuales para edición en cada modal
    for p in promociones:
        p.form_editar = PromocionForm(instance=p)

    return render(request, 'core/promociones_list.html', {
        'promociones': promociones,
        'form': form,
    })

@login_required
def dashboard(request):
    # Traer algunos datos para mostrar resúmenes
    total_productos = Producto.objects.count()
    total_promociones = Promocion.objects.count()
    total_proveedores = Proveedor.objects.count()
    total_clientes = Cliente.objects.count()
    total_sucursales = Sucursal.objects.count()

    # Puedes limitar la cantidad de items que se muestran en mini-cards
    ultimos_productos = Producto.objects.all().order_by('-id')[:5]
    ultimas_promociones = Promocion.objects.all().order_by('-id')[:5]

    return render(request, 'core/dashboard.html', {
        'total_productos': total_productos,
        'total_promociones': total_promociones,
        'total_proveedores': total_proveedores,
        'total_clientes': total_clientes,
        'total_sucursales': total_sucursales,
        'ultimos_productos': ultimos_productos,
        'ultimas_promociones': ultimas_promociones,
    })
    return render(request, 'core/dashboard.html', {})

# -------------------------------------------------------------
# --- SERIALIZERS
# -------------------------------------------------------------

class ClienteTokenObtainPairView(TokenObtainPairView):
    """Vista para que los Clientes obtengan su token."""
    serializer_class = ClienteTokenObtainPairSerializer

class ClienteTokenRefreshView(TokenRefreshView):
    """Vista para que los Clientes refresquen su token."""
    serializer_class = ClienteTokenRefreshSerializer

class ProductoViewSet(ModelViewSet):
    queryset = Producto.objects.all()
    serializer_class = ProductoSerializer
    
    # --- 2. APLICA LA AUTENTICACIÓN Y PERMISOS ---
    authentication_classes = [ClienteJWTAuthentication]
    permission_classes = [IsAuthenticated]

class PromocionViewSet(ModelViewSet):
    queryset = Promocion.objects.all()
    serializer_class = PromocionSerializer
    authentication_classes = [ClienteJWTAuthentication]
    permission_classes = [IsAuthenticated]

class ClienteViewSet(ModelViewSet):
    queryset = Cliente.objects.all()
    serializer_class = ClienteSerializer
    authentication_classes = [ClienteJWTAuthentication]
    
    def get_permissions(self):
        if self.action == 'create': # Permite el registro sin token
            return [AllowAny()]
        return [IsAuthenticated()]
    # --- MÉTODO NUEVO: Acción para cambiar la contraseña ---
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def set_password(self, request, pk=None):
        cliente = self.get_object()
        serializer = ChangePasswordSerializer(data=request.data)

        if serializer.is_valid():
            # Verifica la contraseña antigua
            if not cliente.check_password(serializer.data.get("old_password")):
                return Response({"old_password": ["La contraseña actual es incorrecta."]}, status=status.HTTP_400_BAD_REQUEST)
            
            # Establece la nueva contraseña (el método set_password se encarga de hashearla)
            cliente.set_password(serializer.data.get("new_password"))
            cliente.save()
            return Response({"status": "Contraseña actualizada con éxito"}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class ProveedorViewSet(ModelViewSet):
    queryset = Proveedor.objects.all()
    serializer_class = ProveedorSerializer

class SucursalViewSet(ModelViewSet):
    queryset = Sucursal.objects.all()
    serializer_class = SucursalSerializer

class CategoriaViewSet(ModelViewSet):
    queryset = Categoria.objects.all()
    serializer_class = CategoriaSerializer

class EstanteriaViewSet(ModelViewSet):
    queryset = Estanteria.objects.all()
    serializer_class = EstanteriaSerializer

class PasilloViewSet(ModelViewSet):
    queryset = Pasillo.objects.all()
    serializer_class = PasilloSerializer