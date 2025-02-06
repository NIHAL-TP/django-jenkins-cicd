
from django.urls import path
from . import views  # Import your views

urlpatterns = [
    path('', views.file_list, name='file_list'), # Example: Root URL maps to file_list view
    path('file/<int:file_id>/', views.edit_file, name='edit_file'),
    path('file/<int:file_id>/unlock/', views.unlock_file, name='unlock_file'),
    path('create/', views.create_file, name='create_file'),
]
