import random
import string
from django.db import migrations, models


def generate_unique_codes(apps, schema_editor):
    Course = apps.get_model('courses', 'Course')
    used = set()
    for course in Course.objects.all():
        while True:
            code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            if code not in used:
                used.add(code)
                course.code = code
                course.save()
                break


class Migration(migrations.Migration):

    dependencies = [
        # Укажи предыдущую миграцию — посмотри как называется 0002_*.py у тебя
        ('courses', '0002_initial'),
    ]

    operations = [
        # Сначала добавляем поле БЕЗ unique, с дефолтом
        migrations.AddField(
            model_name='course',
            name='code',
            field=models.CharField(max_length=10, blank=True, default=''),
        ),
        # Заполняем уникальными кодами существующие записи
        migrations.RunPython(generate_unique_codes, migrations.RunPython.noop),
        # Теперь делаем unique
        migrations.AlterField(
            model_name='course',
            name='code',
            field=models.CharField(max_length=10, unique=True, blank=True),
        ),
    ]