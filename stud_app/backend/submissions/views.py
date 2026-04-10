from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Submission, SubmissionFile
from .serializers import SubmissionSerializer, GradeSerializer


class SubmissionListCreateView(generics.ListCreateAPIView):
    serializer_class   = SubmissionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user    = self.request.user
        post_id = self.request.query_params.get('post')

        if user.is_teacher:
            qs = Submission.objects.filter(
                post__course__teacher=user
            ).select_related('student', 'post').prefetch_related('extra_files')
            if post_id:
                qs = qs.filter(post_id=post_id)
        else:
            qs = Submission.objects.filter(
                student=user
            ).select_related('student', 'post').prefetch_related('extra_files')
            if post_id:
                qs = qs.filter(post_id=post_id)
        return qs

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        submission = serializer.save()

        # Обработка дополнительных файлов (поле 'files' — список)
        extra_files = request.FILES.getlist('files')
        for f in extra_files:
            SubmissionFile.objects.create(
                submission=submission,
                file=f,
                file_name=f.name,
            )

        headers = self.get_success_headers(serializer.data)
        # Перечитываем с prefetch чтобы extra_files были в ответе
        submission.refresh_from_db()
        out = SubmissionSerializer(submission, context={'request': request})
        return Response(out.data, status=status.HTTP_201_CREATED, headers=headers)


class SubmissionDetailView(generics.RetrieveAPIView):
    serializer_class   = SubmissionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_teacher:
            return Submission.objects.filter(
                post__course__teacher=user
            ).prefetch_related('extra_files')
        return Submission.objects.filter(student=user).prefetch_related('extra_files')


class GradeSubmissionView(APIView):
    """Преподаватель выставляет оценку."""
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        if not request.user.is_teacher:
            return Response(
                {'detail': 'Только преподаватель может ставить оценки.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        try:
            submission = Submission.objects.get(pk=pk, post__course__teacher=request.user)
        except Submission.DoesNotExist:
            return Response({'detail': 'Не найдено.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = GradeSerializer(submission, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            SubmissionSerializer(submission, context={'request': request}).data
        )