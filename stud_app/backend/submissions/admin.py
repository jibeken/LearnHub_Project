from django.contrib import admin
from .models import Submission

@admin.register(Submission)
class SubmissionAdmin(admin.ModelAdmin):
    list_display = ['student', 'post', 'status', 'grade', 'submitted_at']
    list_filter = ['status']