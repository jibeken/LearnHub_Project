from django.db import models
from users.models import User
from posts.models import Post


class Submission(models.Model):
    class Status(models.TextChoices):
        PENDING  = 'pending',  'На проверке'
        GRADED   = 'graded',   'Оценено'
        RETURNED = 'returned', 'Возвращено на доработку'

    post         = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='submissions')
    student      = models.ForeignKey(User, on_delete=models.CASCADE, related_name='submissions')
    # Оставляем одиночный file для обратной совместимости, но основное — SubmissionFile
    file         = models.FileField(upload_to='submissions/', null=True, blank=True)
    text         = models.TextField(blank=True)
    grade        = models.PositiveSmallIntegerField(null=True, blank=True)
    feedback     = models.TextField(blank=True)
    status       = models.CharField(max_length=10, choices=Status.choices, default=Status.PENDING)
    submitted_at = models.DateTimeField(auto_now_add=True)
    updated_at   = models.DateTimeField(auto_now=True)

    class Meta:
        ordering       = ['-submitted_at']
        unique_together = ['post', 'student']

    def __str__(self):
        return f'{self.student} → {self.post}'

    @property
    def file_name(self):
        if self.file:
            return self.file.name.split('/')[-1]
        return None


class SubmissionFile(models.Model):
    """Дополнительные файлы к сабмишну (фото, документы и т.д.)"""
    submission = models.ForeignKey(
        Submission, on_delete=models.CASCADE, related_name='extra_files'
    )
    file       = models.FileField(upload_to='submission_files/')
    file_name  = models.CharField(max_length=255, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.file_name and self.file:
            self.file_name = self.file.name.split('/')[-1]
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.submission} — {self.file_name}'