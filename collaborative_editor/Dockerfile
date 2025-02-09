FROM python:3.9-slim-buster
ENV PYTHONUNBUFFERED 1
COPY . /app
WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--bind=0.0.0.0:8000", "collaborative_editor.wsgi:application"]  # Correct path
