from rest_framework import serializers
from .models import Producto, Promocion, Cliente, Proveedor, Sucursal, Categoria, Estanteria, Pasillo

class ProductoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Producto
        fields = ['id', 'nombre', 'precio', 'stock', 'categoria']

class PromocionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Promocion
        fields = ['id', 'nombre', 'producto', 'descuento', 'fecha_inicio', 'fecha_fin']

class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = ['id', 'nombre', 'email', 'telefono']

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