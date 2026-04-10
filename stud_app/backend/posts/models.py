from django.db import models
from users.models import User
from courses.models import Course


class Post(models.Model):
    class Type(models.TextChoices):
        ANNOUNCEMENT = 'announcement', 'Объявление'
        MATERIAL     = 'material',     'Материал'
        ASSIGNMENT   = 'assignment',   'Задание'

    course     = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='posts')
    author     = models.ForeignKey(User,   on_delete=models.CASCADE, related_name='posts')
    type       = models.CharField(max_length=20, choices=Type.choices, default=Type.ANNOUNCEMENT)
    title      = models.CharField(max_length=255)
    content    = models.TextField()
    # Одиночный file оставляем для обратной совместимости
    file       = models.FileField(upload_to='post_files/', null=True, blank=True)
    due_date   = models.DateTimeField(null=True, blank=True)
    points     = models.PositiveSmallIntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title


class PostFile(models.Model):
    """Прикреплённые к посту файлы (изображения, аудио, документы)."""
    post      = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='files')
    file      = models.FileField(upload_to='post_attachments/')
    file_name = models.CharField(max_length=255, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.file_name and self.file:
            self.file_name = self.file.name.split('/')[-1]
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.post.title} — {self.file_name}'