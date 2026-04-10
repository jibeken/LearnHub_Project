from rest_framework import serializers
from users.serializers import UserSerializer
from .models import Post, PostFile  # Добавили PostFile

class PostFileSerializer(serializers.ModelSerializer):
    """Сериализатор для отображения прикрепленных файлов."""
    class Meta:
        model = PostFile
        fields = ['id', 'file', 'file_name', 'uploaded_at']

class CommentInlineSerializer(serializers.Serializer):
    id         = serializers.IntegerField()
    author     = UserSerializer(read_only=True)
    text       = serializers.CharField()
    created_at = serializers.DateTimeField()


class PostSerializer(serializers.ModelSerializer):
    author         = UserSerializer(read_only=True)
    comment_count  = serializers.SerializerMethodField()
    is_assignment  = serializers.SerializerMethodField()
    comments       = CommentInlineSerializer(many=True, read_only=True)
    # Добавляем отображение файлов в детальном виде
    attachments    = PostFileSerializer(many=True, read_only=True, source='files')

    class Meta:
        model  = Post
        fields = [
            'id', 'course', 'author', 'type', 'title', 'content',
            'file', 'attachments', 'due_date', 'points',
            'comment_count', 'comments',
            'is_assignment', 'created_at',
        ]
        read_only_fields = ['author', 'created_at']

    def get_comment_count(self, obj):
        return obj.comments.count()

    def get_is_assignment(self, obj):
        return obj.type == Post.Type.ASSIGNMENT

    def create(self, validated_data):
        # 1. Берем текущего юзера
        validated_data['author'] = self.context['request'].user
        
        # 2. Извлекаем файлы из запроса (ключ 'attachments' должен совпадать с Flutter)
        request = self.context.get('request')
        files = request.FILES.getlist('attachments')
        
        # 3. Создаем пост
        post = super().create(validated_data)
        
        # 4. Сохраняем каждый файл в таблицу PostFile
        for f in files:
            PostFile.objects.create(post=post, file=f)
            
        return post


class PostListSerializer(serializers.ModelSerializer):
    author         = UserSerializer(read_only=True)
    comment_count  = serializers.SerializerMethodField()
    is_assignment  = serializers.SerializerMethodField()
    # В списке тоже полезно видеть, есть ли файлы
    attachments    = PostFileSerializer(many=True, read_only=True, source='files')

    class Meta:
        model  = Post
        fields = [
            'id', 'course', 'author', 'type', 'title', 'content',
            'file', 'attachments', 'due_date', 'points',
            'comment_count', 'is_assignment', 'created_at',
        ]
        read_only_fields = ['author', 'created_at']

    def get_comment_count(self, obj):
        return obj.comments.count()

    def get_is_assignment(self, obj):
        return obj.type == Post.Type.ASSIGNMENT