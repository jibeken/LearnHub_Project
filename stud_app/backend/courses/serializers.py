from rest_framework import serializers
from users.serializers import UserSerializer
from .models import Course


class CourseSerializer(serializers.ModelSerializer):
    teacher = UserSerializer(read_only=True)
    student_count = serializers.SerializerMethodField()
    is_enrolled = serializers.SerializerMethodField()

    class Meta:
        model = Course
        fields = ['id', 'title', 'description', 'cover', 'code', 'teacher',
                  'student_count', 'is_enrolled', 'is_active', 'created_at'] 

    def get_is_enrolled(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.students.filter(id=request.user.id).exists()
        return False

    def get_student_count(self, obj):
        if hasattr(obj, 'student_count') and isinstance(obj.student_count, int):
            return obj.student_count
        return obj.students.count()


class CourseCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = ['title', 'description', 'cover', 'is_active']

    def create(self, validated_data):
        validated_data['teacher'] = self.context['request'].user
        return super().create(validated_data)
