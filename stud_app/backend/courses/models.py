import random
import string
from django.db import models
from users.models import User


class Course(models.Model):
    title       = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    cover       = models.ImageField(upload_to='course_covers/', null=True, blank=True)
    code        = models.CharField(max_length=10, unique=True, blank=True)
    teacher     = models.ForeignKey(User, on_delete=models.CASCADE, related_name='teaching_courses')
    students    = models.ManyToManyField(User, related_name='enrolled_courses', blank=True)
    created_at  = models.DateTimeField(auto_now_add=True)
    updated_at  = models.DateTimeField(auto_now=True)
    is_active   = models.BooleanField(default=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title

    @property
    def student_count(self):
        return self.students.count()

    def save(self, *args, **kwargs):
        if not self.code:
            self.code = self._generate_code()
        super().save(*args, **kwargs)

    def _generate_code(self):
        while True:
            code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            if not Course.objects.filter(code=code).exists():
                return code