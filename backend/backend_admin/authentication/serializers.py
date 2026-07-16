# https://www.django-rest-framework.org/tutorial/quickstart/#project-setup
# this is knownledge of django rest framework (drf)

#Serializer is a core component of Django REST Framework (DRF) that acts as a bridge for converting complex data types, such as Django QuerySets or Model instances, into native Python data types. These Python data structures can then be easily rendered into common formats such as JSON or XML, making them suitable for transmission to the client.

#At the same time, it also performs the reverse process, known as deserialization: receiving JSON data from the client, validating the input, and converting it into Python objects that can be saved to the database.

#The main types of serializers commonly used include:

#Serializer: The base serializer class that requires you to manually define each field and implement the data validation and persistence logic. It is suitable for returning customized or highly tailored data structures.

#ModelSerializer: The most commonly used serializer class, which automatically maps fields from the corresponding Django model. It saves development time by generating fields automatically and providing default implementations of the create() and update() methods.

"""
Is a Serializer similar to a DTO?

Yes. A Serializer in Django REST Framework (DRF) is conceptually very similar to a DTO (Data Transfer Object) used in other frameworks such as Spring Boot (Java), ASP.NET Core (.NET), or NestJS.

At their core, both serve as intermediary objects for transferring data between different layers of an application while defining the structure of the data exchanged with the client.

Core Similarities
Data Isolation: Both help decouple the database model from the data exposed to clients. You do not have to expose every column of a database table through your API.
Data Shaping: Both allow you to combine data from multiple models, hide sensitive fields (such as passwords), rename fields, or customize the response structure before sending it to the client.
Data Transfer: Both act as containers for transporting data across the network, typically in JSON format.
How DRF Serializer Goes Beyond a Traditional DTO

In traditional software architectures, a DTO is generally a plain data object that contains little or no business logic. By contrast, a DRF Serializer is much more powerful because it provides two major capabilities out of the box:

Automatic Serialization and Deserialization: A DTO usually requires a separate mapping library (such as MapStruct, AutoMapper, or similar tools) to convert between domain models and DTOs. DRF Serializers handle this conversion automatically, transforming Django model instances into JSON and converting incoming JSON back into Python objects.
Built-in Data Validation: DRF Serializers include comprehensive validation features, such as checking required fields, validating email formats, enforcing string length constraints, and supporting custom validation through methods like validate_<field_name>() or validate(). In many other frameworks, these validation responsibilities are typically handled by separate validator components or annotations rather than the DTO itself.
"""

from rest_framework import serializers
from .models import CustomUser

class UserSerializer(serializers.ModelSerializer):
    profile_picture_url = serializers.SerializerMethodField()

    class Meta: 
        model=  CustomUser
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'profile_picture', 'profile_picture_url', 'phone_number', 'is_verified', 'created_at']
        read_only_fields = ['id', 'email', 'created_at', 'is_verified', 'profile_picture_url']
    
    def get_profile_picture_url(self, obj):
        if obj.profile_picture: 
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_picture.url)
            else:
                return obj.profile_picture.url
        return None

