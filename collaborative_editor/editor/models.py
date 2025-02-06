from django.db import models
from django.conf import settings

class File(models.Model):
    name = models.CharField(max_length=255)
    content = models.TextField(blank=True, null=True)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    locked_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='locked_files')
    last_modified = models.DateTimeField(auto_now=True)

    def __str__(self):  # For better representation in the admin panel
        return self.name
