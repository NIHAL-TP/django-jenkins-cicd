from django.shortcuts import render, get_object_or_404, redirect
from .models import File
from django.http import HttpResponseForbidden, JsonResponse
from django.contrib.auth.decorators import login_required
from django.utils import timezone

@login_required
def edit_file(request, file_id):
    file = get_object_or_404(File, pk=file_id)

    if file.locked_by and file.locked_by != request.user:
        return HttpResponseForbidden("File is currently locked by another user.")

    if request.method == 'POST':  # For saving
        new_content = request.POST.get('content')
        file.content = new_content
        file.last_modified = timezone.now()
        file.save()
        return JsonResponse({'success': True, 'last_modified': file.last_modified.isoformat()})

    file.locked_by = request.user  # Lock when opening
    file.save()

    context = {'file': file}
    return render(request, 'editor/edit_file.html', context)

@login_required
def unlock_file(request, file_id):
    file = get_object_or_404(File, pk=file_id)
    if file.locked_by == request.user:
        file.locked_by = None
        file.save()
    return redirect('edit_file', file_id=file_id)

@login_required
def file_list(request):
    files = File.objects.filter(owner=request.user)  # Filter by current user
    return render(request, 'editor/file_list.html', {'files': files})

@login_required
def create_file(request):
    if request.method == 'POST':
        file_name = request.POST.get('file_name')
        new_file = File.objects.create(name=file_name, owner=request.user)
        return redirect('edit_file', file_id=new_file.id)
    return render(request, 'editor/create_file.html')
