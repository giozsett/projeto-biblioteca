from django.urls import path
from . import views

urlpatterns = [
    path('home/', views.home, name='home'),  # Página home
    
    path('', views.login, name='login'),  # Página de login    
    path('cadastrar/', views.cadastrar, name='cadastrar'),  # Página de cadastro de usuário
    path('troca_senha/', views.troca_senha, name='troca_senha'),  # Página de troca de senha
    path('usuarios/', views.usuarios, name='usuarios'),  # Página de listagem e desbloqueio de usuários
    
    path('cad_livro/', views.cad_livro, name='cad_livro'),  # Página para cadastro de livro
    
    path('catalogo/', views.catalogo, name='catalogo'),  # Página de visualização dos livros no catálogo    
    path('editar_livro/<int:livro_id>/', views.editar_livro, name='editar_livro'),  # Editar livro
    path('excluir_livro/<int:livro_id>/', views.exclui_livro, name='exclui_livro'),  # Excluir livro (soft delete)
    
    # URLs do cadastro, edição e exclusão de empréstimos de livros
    path('cad_emprestimo/', views.cad_emprestimo, name='cad_emprestimo'),
    path('emprestimos/', views.emprestimos, name='emprestimos'),
    path('editar_emprestimo/<int:id_emprestimo>', views.editar_emprestimo, name='editar_emprestimo'),
    path('excluir_emprestimo/<int:id_emprestimo>', views.excluir_emprestimo, name='excluir_emprestimo'),
    path('cad_devolucao/<int:id_emprestimo>', views.cad_devolucao, name='cad_devolucao'),
    
    path('sobre/', views.sobre, name='sobre'),  # Página sobre
]
