from rest_framework import serializers
from users.serializers import UserSerializer
from .models import Submission, SubmissionFile


class SubmissionFileSerializer(serializers.ModelSerializer):
    url = serializers.SerializerMethodField()

    class Meta:
        model  = SubmissionFile
        fields = ['id', 'file_name', 'url', 'uploaded_at']

    def get_url(self, obj):
        request = self.context.get('request')
        if obj.file and request:
            return request.build_absolute_uri(obj.file.url)
        return None


class SubmissionSerializer(serializers.ModelSerializer):
    student    = UserSerializer(read_only=True)
    is_graded  = serializers.SerializerMethodField()
    file_name  = serializers.SerializerMethodField()
    file_url   = serializers.SerializerMethodField()
    extra_files = SubmissionFileSerializer(many=True, read_only=True)

    class Meta:
        model  = Submission
        fields = [
            'id', 'post', 'student',
            'file', 'file_url', 'file_name',
            'extra_files',
            'text',
            'grade', 'feedback', 'status', 'is_graded',
            'submitted_at', 'updated_at',
        ]
        read_only_fields = [
            'student', 'grade', 'feedback', 'status',
            'submitted_at', 'updated_at',
        ]

    def get_is_graded(self, obj):
        return obj.status == Submission.Status.GRADED

    def get_file_name(self, obj):
        if obj.file:
            return obj.file.name.split('/')[-1]
        return None

    def get_file_url(self, obj):
        request = self.context.get('request')
        if obj.file and request:
            return request.build_absolute_uri(obj.file.url)
        return None

    def create(self, validated_data):
        validated_data['student'] = self.context['request'].user
        submission, created = Submission.objects.update_or_create(
            post    = validated_data['post'],
            student = validated_data['student'],
            defaults={
                'file':   validated_data.get('file'),
                'text':   validated_data.get('text', ''),
                'status': Submission.Status.PENDING,
                'grade':  None,
                'feedback': '',
            }
        )
        return submission


class GradeSerializer(serializers.ModelSerializer):
    """Только для преподавателя — выставить оценку."""

    class Meta:
        model  = Submission
        fields = ['grade', 'feedback', 'status']

    def validate_grade(self, value):
        if value is not None and value < 0:
            raise serializers.ValidationError('Оценка не может быть отрицательной.')
        return value