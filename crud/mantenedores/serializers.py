from rest_framework import serializers
from .models import *
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.hashers import check_password
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.exceptions import InvalidToken

class ProductoSerializer(serializers.ModelSerializer):
    precio_con_descuento = serializers.SerializerMethodField()

    class Meta:
        model = Producto
        fields = ['id', 'nombre', 'precio', 'precio_con_descuento', 'stock', 'categoria', 'estanteria', 'pasillo']

    def get_precio_con_descuento(self, obj):
        # obj.precio_con_descuento devuelve Decimal
        precio = obj.precio_con_descuento
        # Convertir a float para JSON (o str si prefieres mantener exactitud)
        try:
            return float(precio)
        except Exception:
            # fallback (siempre se envía algo)
            return str(precio)

class PromocionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Promocion
        fields = ['id', 'nombre', 'producto', 'descuento', 'fecha_inicio', 'fecha_fin']

class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = [
            'id',
            'username',
            'nombre',
            'apellido',
            'email',
            'telefono',
            'direccion',
            'fecha_nacimiento',
            'password'
        ]
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = Cliente.objects.create(**validated_data)
        user.set_password(password)  # Hashea la contraseña
        user.save()
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
        fields = ['id', 'nombre', 'pasillo']  # si quieres mostrar solo ID del pasillo
        # Para mostrar nombre del pasillo en lugar de ID:
        # fields = ['id', 'nombre', 'pasillo_nombre']
        # y defines un SerializerMethodField si quieres

class PasilloSerializer(serializers.ModelSerializer):
    class Meta:
        model = Pasillo
        fields = ['id', 'nombre']

class ClienteTokenSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    access = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)

    def validate(self, attrs):
        username = attrs.get('username')
        password = attrs.get('password')

        try:
            cliente = Cliente.objects.get(username=username)
        except Cliente.DoesNotExist:
            raise serializers.ValidationError("Usuario o contraseña incorrecta")

        if not check_password(password, cliente.password):
            raise serializers.ValidationError("Usuario o contraseña incorrecta")

        # Crear tokens JWT manualmente
        refresh = RefreshToken.for_user(cliente)  # Necesitas que Cliente herede de AbstractBaseUser
        access = refresh.access_token

        return {
            'access': str(access),
            'refresh': str(refresh),
        }
    
class CustomTokenRefreshSerializer(TokenRefreshSerializer):
    def validate(self, attrs):
        try:
            return super().validate(attrs)
        except Cliente.DoesNotExist:
            raise InvalidToken("El usuario no existe o fue eliminado")