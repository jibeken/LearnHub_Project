from django.urls import path
from .views import SubmissionListCreateView, SubmissionDetailView, GradeSubmissionView

urlpatterns = [
    path('', SubmissionListCreateView.as_view(), name='submission-list'),
    path('<int:pk>/', SubmissionDetailView.as_view(), name='submission-detail'),
    path('<int:pk>/grade/', GradeSubmissionView.as_view(), name='submission-grade'),
]