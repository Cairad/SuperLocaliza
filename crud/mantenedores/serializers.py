# mantenedores/serializers.py

from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer, TokenRefreshSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.validators import UnicodeUsernameValidator
from .models import * # Importa todos tus modelos

# -------------------------------------------------------------------
# --- NUEVOS SERIALIZERS PARA AUTENTICACIÓN DE CLIENTES (APP MÓVIL) ---
# -------------------------------------------------------------------

class ClienteTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Serializer para el login de Clientes.
    Valida las credenciales contra el modelo Cliente.
    """
    def validate(self, attrs):
        username = attrs.get(self.username_field)
        password = attrs.get('password')

        try:
            cliente = Cliente.objects.get(username=username)
        except Cliente.DoesNotExist:
            raise serializers.ValidationError("Usuario o contraseña incorrecta")

        if not cliente.check_password(password):
            raise serializers.ValidationError("Usuario o contraseña incorrecta")
        
        refresh = self.get_token(cliente)

        data = {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }
        return data

class ClienteTokenRefreshSerializer(TokenRefreshSerializer):
    """
    Serializer para el refresco de token de Clientes.
    Valida el token contra el modelo Cliente en lugar del AUTH_USER_MODEL.
    """
    def validate(self, attrs):
        refresh = RefreshToken(attrs['refresh'])
        
        try:
            # Verificamos que el user_id del token exista en la tabla Cliente.
            user_id = refresh.get('user_id')
            Cliente.objects.get(id=user_id)
            
            # Si el cliente existe, generamos un nuevo access token
            data = {'access': str(refresh.access_token)}
            return data
        except Cliente.DoesNotExist:
            raise serializers.ValidationError("Token inválido o sesión de cliente expirada.")
        except Exception as e:
            raise serializers.ValidationError(str(e))


# ---------------------------------------------------------
# --- OTROS SERIALIZERS DE TU APLICACIÓN (SIN CAMBIOS) ---
# ---------------------------------------------------------

class ProductoSerializer(serializers.ModelSerializer):
    categoria = serializers.StringRelatedField()
    pasillo = serializers.StringRelatedField()
    estante = serializers.StringRelatedField(source='estanteria')
    
    # --- VERIFICA ESTOS DOS CAMPOS ---
    precio_con_descuento = serializers.ReadOnlyField()
    descuento_activo = serializers.SerializerMethodField()

    class Meta:
        model = Producto
        fields = [
            'id', 'nombre', 'precio', 'categoria', 'estante', 'pasillo', 'descripcion',
            'precio_con_descuento', # <-- Asegúrate que esté en la lista
            'descuento_activo'      # <-- Y este también
        ]
    
    def get_descuento_activo(self, obj):
        """
        Busca una promoción activa para el producto y devuelve el porcentaje de descuento.
        """
        from django.utils import timezone
        hoy = timezone.now().date()
        promocion = obj.promocion_set.filter(fecha_inicio__lte=hoy, fecha_fin__gte=hoy).first()
        if promocion:
            return promocion.descuento
        return None

class PromocionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Promocion
        fields = ['id', 'nombre', 'producto', 'descuento', 'fecha_inicio', 'fecha_fin']

class ClienteSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        max_length=150,
        validators=[UnicodeUsernameValidator()],
    )

    class Meta:
        model = Cliente
        fields = ['id', 'username', 'nombre', 'apellido', 'email', 'telefono', 'fecha_nacimiento', 'password']
        extra_kwargs = {'password': {'write_only': True}}
    
    def validate_username(self, value):
        # --- LÓGICA CORREGIDA ---
        # Verifica si estamos actualizando una instancia existente o creando una nueva.
        if self.instance:
            # Si es una actualización, excluye al propio usuario de la búsqueda de duplicados.
            if Cliente.objects.filter(username=value).exclude(pk=self.instance.pk).exists():
                raise serializers.ValidationError("Este nombre de usuario ya está en uso.")
        else:
            # Si es una creación, simplemente verifica si el username ya existe.
            if Cliente.objects.filter(username=value).exists():
                raise serializers.ValidationError("Este nombre de usuario ya está en uso.")
        return value

    def create(self, validated_data):
        # Usar el manager 'create_user' es una mejor práctica que ya tenías en tu modelo.
        user = Cliente.objects.create_user(**validated_data)
        return user

class ProveedorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proveedor
        fields = ['id', 'nombre', 'email', 'telefono']

class SucursalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sucursal
        fields = ['id', 'nombre', 'direccion']

class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categoria
        fields = ['id', 'nombre']

class EstanteriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Estanteria
        fields = ['id', 'nombre', 'pasillo']

class PasilloSerializer(serializers.ModelSerializer):
    class Meta:
        model = Pasillo
        fields = ['id', 'nombre']

class ChangePasswordSerializer(serializers.Serializer):
    """
    Serializer para el cambio de contraseña.
    """
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)
    new_password_confirm = serializers.CharField(required=True)

    def validate(self, data):
        if data['new_password'] != data['new_password_confirm']:
            raise serializers.ValidationError({"new_password": "Las contraseñas nuevas no coinciden."})
        return data