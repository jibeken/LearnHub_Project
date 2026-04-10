from rest_framework import generics, permissions
from .models import Comment
from .serializers import CommentSerializer


class IsAuthorOrTeacherOrReadOnly(permissions.BasePermission):
    """Автор или учитель курса могут удалять комментарии."""

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        # Автор комментария
        if obj.author == request.user:
            return True
        # Учитель курса, к которому относится пост
        if request.user.is_teacher:
            return obj.post.course.teacher == request.user
        return False


class CommentListCreateView(generics.ListCreateAPIView):
    serializer_class   = CommentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        post_id = self.request.query_params.get('post')
        if post_id:
            return Comment.objects.filter(
                post_id=post_id
            ).select_related('author', 'post')
        return Comment.objects.none()

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


class CommentDeleteView(generics.DestroyAPIView):
    serializer_class   = CommentSerializer
    permission_classes = [permissions.IsAuthenticated, IsAuthorOrTeacherOrReadOnly]

    def get_queryset(self):
        # Возвращаем все комментарии — права проверяются в has_object_permission
        return Comment.objects.select_related('author', 'post__course')