from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('users.urls')),
    path('api/courses/', include('courses.urls')),
    path('api/posts/', include('posts.urls')),
    path('api/submissions/', include('submissions.urls')), # This already handles submissions
    path('api/comments/', include('comments.urls')),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # REMOVED the line that was causing the NameError
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)