# mantenedores/authentication.py

from rest_framework_simplejwt.authentication import JWTAuthentication
from .models import Cliente

class ClienteJWTAuthentication(JWTAuthentication):
    """
    Clase de autenticación personalizada para validar tokens de 'Cliente'.
    """
    def get_user(self, validated_token):
        """
        Sobreescribe el método original para buscar el usuario en el modelo 'Cliente'.
        """
        try:
            user_id = validated_token['user_id']
        except KeyError:
            return None # El token no tiene user_id, es inválido.

        try:
            # Busca el usuario por su ID en la tabla Cliente.
            return Cliente.objects.get(id=user_id)
        except Cliente.DoesNotExist:
            return None # El usuario ya no existe.