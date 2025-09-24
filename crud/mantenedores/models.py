from django.utils import timezone
from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.auth.models import AbstractUser, Group, Permission
from django.db import models

class Categoria(models.Model):
    nombre = models.CharField(max_length=100)

    def __str__(self):
        return self.nombre
    
class Estanteria(models.Model):
    nombre = models.CharField(max_length=100)

    def __str__(self):
        return self.nombre
    
class Pasillo(models.Model):
    nombre = models.CharField(max_length=100)

    def __str__(self):
        return self.nombre

class Producto(models.Model):
    nombre = models.CharField(max_length=100)
    categoria = models.ForeignKey(Categoria, on_delete=models.CASCADE)
    estanteria = models.ForeignKey(Estanteria, on_delete=models.CASCADE)
    pasillo = models.ForeignKey(Pasillo, on_delete=models.CASCADE)
    precio = models.DecimalField(max_digits=10, decimal_places=2)
    @property
    def precio_con_descuento(self):
        hoy = timezone.now().date()  # convertimos a date
        promocion_activa = Promocion.objects.filter(
            producto=self,
            fecha_inicio__lte=hoy,
            fecha_fin__gte=hoy
        ).first()
        if promocion_activa:
            descuento = self.precio * (promocion_activa.descuento / 100)
            return self.precio - descuento
        return self.precio
    stock = models.IntegerField(default=0)

    def __str__(self):
        return self.nombre

class Cliente(models.Model):
    nombre = models.CharField(max_length=100)
    apellido = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    telefono = models.CharField(max_length=20, blank=True, null=True)
    direccion = models.TextField(blank=True, null=True)
    fecha_nacimiento = models.DateField(blank=True, null=True)
    fecha_registro = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.nombre} {self.apellido}"

class Sucursal(models.Model):
    nombre = models.CharField(max_length=100)
    direccion = models.CharField(max_length=200)

    def __str__(self):
        return self.nombre

class Usuario(AbstractUser):
    # Campos adicionales opcionales
    rol = models.CharField(max_length=50, choices=[('admin', 'Administrador'), ('staff', 'Staff')], default='staff')
    
    sucursal = models.ForeignKey(
        'Sucursal',  # o el modelo que tengas para sucursales
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    # Evitar conflicto con auth.User
    groups = models.ManyToManyField(
        Group,
        related_name='mantenedores_usuarios',
        blank=True,
        help_text='Grupos a los que pertenece este usuario.',
        verbose_name='grupos'
    )
    user_permissions = models.ManyToManyField(
        Permission,
        related_name='mantenedores_usuarios_permissions',
        blank=True,
        help_text='Permisos específicos para este usuario.',
        verbose_name='permisos de usuario'
    )

    def __str__(self):
        return self.username
    
class Proveedor(models.Model):
    nombre = models.CharField(max_length=100)
    contacto = models.CharField(max_length=100, blank=True, null=True)
    telefono = models.CharField(max_length=20, blank=True, null=True)
    email = models.EmailField(blank=True, null=True)
    direccion = models.CharField(max_length=200, blank=True, null=True)

    def __str__(self):
        return self.nombre

class Promocion(models.Model):
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    producto = models.ForeignKey(Producto, on_delete=models.CASCADE)
    descuento = models.DecimalField(
    max_digits=5, 
    decimal_places=2, 
    validators=[MinValueValidator(0), MaxValueValidator(100)],
    help_text="Descuento en %")
    fecha_inicio = models.DateField()
    fecha_fin = models.DateField()

    def __str__(self):
        return f"{self.nombre} ({self.descuento}%)"