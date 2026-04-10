from rest_framework import generics, permissions
from .models import Post
from .serializers import PostSerializer, PostListSerializer


class IsTeacherOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return request.user.is_authenticated
        return request.user.is_authenticated and request.user.is_teacher

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.author == request.user


class PostListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsTeacherOrReadOnly]

    def get_serializer_class(self):
        # При создании и детальном просмотре — полный сериализатор с комментариями
        if self.request.method == 'POST':
            return PostSerializer
        return PostListSerializer

    def get_queryset(self):
        user      = self.request.user
        params    = self.request.query_params
        course_id = params.get('course')
        post_type = params.get('type')       # ?type=assignment
        deadlines = params.get('deadlines')  # ?deadlines=true — только задания с дедлайном

        # Учитель видит только свои курсы, студент — только свои записанные
        if user.is_teacher:
            qs = Post.objects.filter(course__teacher=user)
        else:
            qs = Post.objects.filter(course__students=user, course__is_active=True)

        if course_id:
            qs = qs.filter(course_id=course_id)

        if post_type:
            qs = qs.filter(type=post_type)

        # Удобный фильтр для дедлайнов студента
        if deadlines == 'true':
            qs = qs.filter(type=Post.Type.ASSIGNMENT, due_date__isnull=False)

        return qs


class PostDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset           = Post.objects.all()
    serializer_class   = PostSerializer   # детальный вид — с комментариями
    permission_classes = [IsTeacherOrReadOnly]