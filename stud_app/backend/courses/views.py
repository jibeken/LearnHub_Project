from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Course
from .serializers import CourseSerializer
from users.serializers import UserSerializer


class CourseListCreateView(generics.ListCreateAPIView):
    serializer_class = CourseSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'teacher':
            # Препод видит курсы где он teacher
            return Course.objects.filter(teacher=user)
        else:
            # Студент видит курсы где он enrolled
            return Course.objects.filter(students=user)

    def perform_create(self, serializer):
        serializer.save(teacher=self.request.user)


class CourseDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = CourseSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'teacher':
            return Course.objects.filter(teacher=user)
        return Course.objects.filter(students=user)


class EnrollView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        try:
            course = Course.objects.get(pk=pk)
        except Course.DoesNotExist:
            return Response({'detail': 'Курс не найден.'}, status=status.HTTP_404_NOT_FOUND)
        
        course.students.add(request.user)
        return Response({'detail': 'Вы записались на курс.'})


class CourseStudentsView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        course_id = self.kwargs['pk']
        try:
            course = Course.objects.get(pk=course_id)
            return course.students.all()
        except Course.DoesNotExist:
            return []


class FindCourseByCodeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, code):
        try:
            course = Course.objects.get(code=code)
            serializer = CourseSerializer(course, context={'request': request})
            return Response(serializer.data)
        except Course.DoesNotExist:
            return Response({'detail': 'Курс не найден.'}, status=status.HTTP_404_NOT_FOUND)