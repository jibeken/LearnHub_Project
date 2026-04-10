from django.urls import path
from .views import (
    CourseListCreateView, CourseDetailView,
    EnrollView, CourseStudentsView, FindCourseByCodeView,
)

urlpatterns = [
    path('', CourseListCreateView.as_view(), name='course-list'),
    path('<int:pk>/', CourseDetailView.as_view(), name='course-detail'),
    path('<int:pk>/enroll/', EnrollView.as_view(), name='course-enroll'),
    path('<int:pk>/students/', CourseStudentsView.as_view(), name='course-students'),
    path('find/<str:code>/', FindCourseByCodeView.as_view(), name='course-find-by-code'),
]