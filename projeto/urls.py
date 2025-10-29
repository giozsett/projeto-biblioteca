from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('login/', views.login, name='login'),
    path('cadastrar/', views.cadastrar, name='cadastrar'),
    path('cad_livro/', views.cad_livro, name='cad_livro'),
    path('catalago', views.catalogo, name='catalogo'),
]