from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection

# ==================== FUNÇÕES DE AUTENTICAÇÃO ====================

def valida_login(email, senha):
    """
    Chama a procedure pr_valida_login do MySQL
    Retorna: status (string com a mensagem)
    """
    try:
        with connection.cursor() as cursor:
            # Chama a procedure
            cursor.callproc('pr_valida_login', [email, senha, 0])
            
            # Pega o OUT parameter @_pr_valida_login_2 (índice 2 = terceiro parâmetro)
            cursor.execute("SELECT @_pr_valida_login_2")
            status_result = cursor.fetchone()
            status = status_result[0] if status_result else 'Erro desconhecido'
            
            return status
            
    except Exception as e:
        print(f"ERRO DETALHADO: {e}")  # Para debug no terminal
        return f'Erro ao validar login: {str(e)}'


def usuarios(request):
    mensagem = None

    # Caso o botão "Desbloquear" tenha sido clicado
    if request.method == "POST":
        email = request.POST.get("email")
        try:
            with connection.cursor() as cursor:
                cursor.execute("CALL pr_desbloquear_usuario(%s, @p_status)", [email])
                cursor.execute("SELECT @p_status")
                status = cursor.fetchone()[0]

            if status == "Sucesso":
                mensagem = f"Usuário {email} desbloqueado com sucesso!"
            else:
                mensagem = f"Erro ao tentar desbloquear o usuário {email}."
        except Exception as e:
            mensagem = f"Erro: {e}"

    # Lista todos os usuários
    with connection.cursor() as cursor:
        cursor.execute("SELECT nome, email, bloqueado FROM usuarios")
        usuarios_lista = cursor.fetchall()  # [(nome, email, bloqueado), ...]

    return render(request, "telas/usuarios.html", {
        "usuarios": usuarios_lista,
        "mensagem": mensagem
    })

# Mudar a senha do usuário
from django.db import connection
from django.shortcuts import render

def troca_senha(request):
    if request.method == "POST":
        email = request.POST.get("email")
        senha_atual = request.POST.get("senha_atual")
        senha_nova = request.POST.get("senha_nova")

        try:
            cursor = connection.cursor()

            # Chama a procedure
            cursor.execute("CALL pr_troca_senha(%s, %s, %s, @p_status)", [email, senha_atual, senha_nova])

            # Captura o valor de saída
            cursor.execute("SELECT @p_status")
            status = cursor.fetchone()[0]

            if status == 'Sucesso':
                mensagem = "Senha alterada com sucesso!"
            elif status == 'Erro':
                mensagem = "Senha atual incorreta!"
            else:
                mensagem = f"Ocorreu um erro: {status}"

            cursor.close()
            return render(request, "telas/trocar_senha.html", {"mensagem": mensagem})

        except Exception as e:
            return render(request, "telas/trocar_senha.html", {"mensagem": f"Erro ao trocar senha: {e}"})
    else:
        return render(request, "telas/trocar_senha.html")



# ==================== VIEWS DE AUTENTICAÇÃO ====================

def login(request):
    """View de login - chama pr_valida_login"""
    if request.method == 'POST':
        email = request.POST.get('email', '').strip()
        senha = request.POST.get('password', '').strip()

        if not email or not senha:
            messages.error(request, 'Preencha email e senha!')
            return redirect('login')

        try:
            # Chama a procedure de validação
            status = valida_login(email, senha)

            # Verifica se foi sucesso
            if 'sucesso' in status.lower():
                # Busca dados do usuário para a sessão
                with connection.cursor() as cursor:
                    cursor.execute(
                        "SELECT id, nome, email FROM usuarios WHERE email = %s AND usuario_ativo = 'S'", 
                        [email]
                    )
                    usuario = cursor.fetchone()

                if usuario:
                    # Armazena na sessão
                    request.session['usuario'] = {
                        'id': usuario[0],
                        'nome': usuario[1],
                        'email': usuario[2]
                    }
                    messages.success(request, 'Login realizado com sucesso!')
                    return redirect('home')
                else:
                    messages.error(request, 'Usuário não encontrado ou inativo.')
            else:
                # Mostra a mensagem retornada pela procedure
                messages.error(request, status)

        except Exception as e:
            messages.error(request, f'Erro no sistema: {str(e)}')

        return redirect('login')

    return render(request, 'telas/login.html')


def home(request):
    """Página home - requer login"""
    if 'usuario' not in request.session:
        messages.warning(request, 'Faça login para acessar esta página!')
        return redirect('login')
    
    usuario = request.session['usuario']
    return render(request, 'telas/home.html', {
        'titulo': 'Home',
        'usuario': usuario
    })


def logout(request):
    """Logout - limpa a sessão (somente se estiver logado)"""
    if 'usuario' not in request.session:
        messages.warning(request, 'Você precisa estar logado para sair!')
        return redirect('login')
    
    request.session.flush()
    messages.info(request, 'Você saiu do sistema.')
    return redirect('login')


def cadastrar(request):
    """Cadastro de novo usuário"""
    if request.method == 'POST':
        nome = request.POST.get('fullName', '').strip()
        email = request.POST.get('email', '').strip()
        senha = request.POST.get('password', '').strip()

        if not nome or not email or not senha:
            messages.error(request, 'Preencha todos os campos!')
            return redirect('cadastrar')

        try:
            with connection.cursor() as cursor:
                cursor.callproc('pr_cadastra_usuario', [nome, email, senha, nome, 0])
                cursor.execute("SELECT @_pr_cadastra_usuario_4")
                status = cursor.fetchone()[0]
                
                if status == 'Sucesso':
                    messages.success(request, 'Usuário cadastrado com sucesso!')
                    return redirect('cadastrar')
                else:
                    messages.error(request, 'Erro ao cadastrar usuário.')
                    
        except Exception as e:
            messages.error(request, f'Erro: {str(e)}')
            
        return redirect('cadastrar')

    return render(request, 'telas/cadastrar.html')


def desbloquear(request):
    """Desbloqueia usuário - usa pr_desbloquear_usuario"""
    if 'usuario' not in request.session:
        return redirect('login')
    
    if request.method == 'POST':
        email = request.POST.get('email', '').strip()
        
        if not email:
            messages.error(request, 'Informe o email!')
            return redirect('desbloquear')
        
        try:
            status = desbloquear_usuario(email)
            if status == 'Sucesso':
                messages.success(request, f'Usuário {email} desbloqueado com sucesso!')
            else:
                messages.error(request, f'Erro ao desbloquear: {status}')
        except Exception as e:
            messages.error(request, f'Erro: {str(e)}')

    return render(request, 'telas/desbloquear.html')


def trocar_senha(request):
    """Troca senha do usuário logado - usa pr_troca_senha"""
    if 'usuario' not in request.session:
        return redirect('login')
    
    if request.method == 'POST':
        senha_atual = request.POST.get('senha_atual', '').strip()
        senha_nova = request.POST.get('senha_nova', '').strip()
        senha_confirma = request.POST.get('senha_confirma', '').strip()
        
        if not senha_atual or not senha_nova or not senha_confirma:
            messages.error(request, 'Preencha todos os campos!')
            return redirect('trocar_senha')
        
        if senha_nova != senha_confirma:
            messages.error(request, 'As senhas não coincidem!')
            return redirect('trocar_senha')
        
        try:
            email = request.session['usuario']['email']
            status = trocar_senha(email, senha_atual, senha_nova)
            
            if status == 'Sucesso':
                messages.success(request, 'Senha alterada com sucesso!')
                return redirect('home')
            else:
                messages.error(request, 'Senha atual incorreta!')
        except Exception as e:
            messages.error(request, f'Erro: {str(e)}')
    
    return render(request, 'telas/trocar_senha.html')


# ==================== VIEWS DE LIVROS ====================

def cad_livro(request):
    """Cadastro de livro"""
    if 'usuario' not in request.session:
        return redirect('login')
    
    if request.method == 'POST':
        titulo = request.POST.get('titulo', '').strip()
        autor = request.POST.get('autor', '').strip()
        quantidade = request.POST.get('quantidade', 0)
        quant_disponivel = request.POST.get('quant_disponivel', 0)
        categoria = request.POST.get('categoria', '').strip()
        usuario = request.session['usuario']['nome']

        # Validação básica no Django antes de enviar ao banco
        if not titulo or not autor or not categoria:
            messages.error(request, 'Preencha todos os campos obrigatórios!')
            return redirect('cad_livro')

        try:
            with connection.cursor() as cursor:
                cursor.callproc('pr_cadastra_livro', 
                    [titulo, autor, int(quantidade), int(quant_disponivel), categoria, usuario, 0])
                cursor.execute("SELECT @_pr_cadastra_livro_6")
                status = cursor.fetchone()[0]
                
                if status == 'Sucesso':
                    messages.success(request, 'Livro cadastrado com sucesso!')
                    return redirect('catalogo')
                else:
                    messages.error(request, 'Erro ao cadastrar livro.')
        except Exception as e:
            erro_mysql = str(e)
            # Mapeamento das mensagens da trigger
            if 'quantidade do livro não pode ser negativa' in erro_mysql:
                messages.error(request, 'A quantidade do livro não pode ser negativa.')
            elif 'quantidade disponível não pode ser negativa' in erro_mysql:
                messages.error(request, 'A quantidade disponível não pode ser negativa.')
            elif 'quantidade disponível não pode ser maior' in erro_mysql:
                messages.error(request, 'A quantidade disponível não pode ser maior que a quantidade total.')
            else:
                # Mensagem genérica caso o erro não corresponda à trigger
                messages.error(request, f'Erro ao cadastrar livro: {erro_mysql}')
            
        return redirect('cad_livro')

    return render(request, 'telas/cad_livro.html')


def catalogo(request):
    """Lista livros ativos"""
    if 'usuario' not in request.session:
        return redirect('login')
    
    livros = []
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT id, titulo, autor, quantidade, quant_disponivel, categoria 
                FROM livros 
                WHERE livro_ativo = 'S'
                ORDER BY titulo
            """)
            livros = cursor.fetchall()
    except Exception as e:
        messages.error(request, f'Erro ao carregar catálogo: {str(e)}')

    return render(request, 'telas/catalogo.html', {'livros': livros})


def editar_livro(request, livro_id):
    """Edita livro existente"""
    if 'usuario' not in request.session:
        return redirect('login')
    
    if request.method == 'POST':
        titulo = request.POST.get('titulo', '').strip()
        autor = request.POST.get('autor', '').strip()
        quantidade = request.POST.get('quantidade', 0)
        quant_disponivel = request.POST.get('quant_disponivel', 0)
        categoria = request.POST.get('categoria', '').strip()
        usuario = request.session['usuario']['nome']

        try:
            with connection.cursor() as cursor:
                cursor.callproc('pr_atualiza_livro',
                    [livro_id, titulo, autor, int(quantidade), 
                     int(quant_disponivel), categoria, usuario, 0])
                cursor.execute("SELECT @_pr_atualiza_livro_7")
                status = cursor.fetchone()[0]
                
                if status == 'Sucesso':
                    messages.success(request, 'Livro atualizado com sucesso!')
                    return redirect('catalogo')
                else:
                    messages.error(request, 'Erro ao atualizar livro.')
        except Exception as e:
            erro_mysql = str(e)
            # Mapeamento das mensagens da trigger
            if 'quantidade do livro não pode ser negativa' in erro_mysql:
                messages.error(request, 'A quantidade do livro não pode ser negativa.')
            elif 'quantidade disponível não pode ser negativa' in erro_mysql:
                messages.error(request, 'A quantidade disponível não pode ser negativa.')
            elif 'quantidade disponível não pode ser maior' in erro_mysql:
                messages.error(request, 'A quantidade disponível não pode ser maior que a quantidade total.')
            else:
                # Mensagem genérica caso o erro não corresponda à trigger
                messages.error(request, f'Erro ao atualizar livro: {erro_mysql}')

    # Carrega dados do livro
    livro = None
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT id, titulo, autor, quantidade, quant_disponivel, categoria, livro_ativo
                FROM livros WHERE id = %s
            """, [livro_id])
            livro = cursor.fetchone()
    except Exception as e:
        messages.error(request, f'Erro ao carregar livro: {str(e)}')

    return render(request, 'telas/editar_livro.html', {'livro': livro})


def exclui_livro(request, livro_id):
    """Soft delete de livro"""
    if 'usuario' not in request.session:
        return redirect('login')
    
    try:
        usuario = request.session['usuario']['nome']
        with connection.cursor() as cursor:
            cursor.callproc('pr_soft_delete_livro', [livro_id, usuario, 0])
            cursor.execute("SELECT @_pr_soft_delete_livro_2")
            status = cursor.fetchone()[0]
            
            if status == 'Sucesso':
                messages.success(request, 'Livro excluído com sucesso!')
            else:
                messages.error(request, 'Erro ao excluir livro.')
    except Exception as e:
        messages.error(request, f'Erro: {str(e)}')

    return redirect('catalogo')


# Cadastrar Empréstimo
def cad_emprestimo(request):
    # Buscar usuários e livros ativos
    with connection.cursor() as cursor:
        cursor.execute("SELECT id, nome FROM usuarios WHERE usuario_ativo = 'S' AND bloqueado = 'N'")
        usuarios = [{'id': row[0], 'nome': row[1]} for row in cursor.fetchall()]
        cursor.execute("SELECT id, titulo FROM livros WHERE livro_ativo = 'S' AND quant_disponivel > 0")
        livros = [{'id': row[0], 'titulo': row[1]} for row in cursor.fetchall()]
    # Se for uma requisição POST, tenta cadastrar o empréstimo
    if request.method == "POST":
        data_emprestimo = request.POST.get("data_emprestimo")
        id_usuario = request.POST.get("id_usuario")
        id_livro = request.POST.get("id_livro")
        nome_responsavel = request.session.get('usuario_nome', 'Administrador')
        try:
            with connection.cursor() as cursor:
                # Cria variável de saída
                cursor.execute("SET @p_status = '';")
                # Chama a procedure com os 5 parâmetros (4 IN, 1 OUT)
                cursor.callproc("pr_cadastra_emprestimo", [
                    data_emprestimo,
                    id_usuario,
                    id_livro,
                    nome_responsavel,
                    '@p_status'
                ])
                # Recupera o valor de saída da procedure
                cursor.execute("SELECT @p_status;")
                p_status = cursor.fetchone()[0]

            connection.commit()
            # Verifica o status retornado
            messages.success(request, "Empréstimo cadastrado com sucesso!")
            return redirect("emprestimos")
        except Exception as e:
            erro_mysql = str(e)
            if 'Usuário informado não encontrado' in erro_mysql:
                messages.error(request, "Usuário informado não encontrado.")
            elif 'Livro informado não existe' in erro_mysql:
                messages.error(request, "Livro informado não existe.")
            elif 'Livro sem exemplares disponíveis' in erro_mysql:
                messages.error(request, "Livro sem exemplares disponíveis.")
            elif 'data de devolução não pode ser anterior' in erro_mysql:
                messages.error(request, "A data de devolução não pode ser anterior à data de empréstimo.")
            elif 'data de empréstimo não pode ser uma data futura' in erro_mysql:
                messages.error(request, "A data de empréstimo não pode ser uma data futura.")
            else:
                # Mensagem genérica caso o erro seja diferente
                messages.error(request, f"Erro ao atualizar empréstimo: {erro_mysql}")
    # Renderiza o template com os dados dos usuários e livros
    return render(request, "telas/cad_emprestimo.html", {"usuarios": usuarios, "livros": livros})



#Lista de empréstimos
def emprestimos(request):
    """
    Exibe a lista de empréstimos com informações de livro, usuário e datas.
    """
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT e.id, l.titulo AS livro, u.nome AS usuario, e.data_emprestimo, e.data_devolucao
            FROM emprestimos e
            INNER JOIN livros l ON e.id_livro = l.id
            INNER JOIN usuarios u ON e.id_usuario = u.id
            WHERE e.emprestimo_ativo = 'S'  -- Apenas empréstimos ativos
            ORDER BY e.data_emprestimo DESC;  -- Ordena por data de empréstimo, mais recentes primeiro
        """)
        emprestimos = cursor.fetchall()  # Recupera todos os empréstimos que atendem à consulta

    # Passa os dados dos empréstimos para o template 'emprestimos.html'
    return render(request, 'telas/emprestimos.html', {'emprestimos': emprestimos})


#  Cadastrar data de devolução
def cad_devolucao(request, id_emprestimo):
    """
    Cadastra devolução de um empréstimo chamando a procedure pr_cadastra_devolucao.
    """
    nome_responsavel = request.session.get('usuario_nome', 'Administrador')

    try:
        with connection.cursor() as cursor:
            cursor.callproc('pr_cadastra_devolucao', [id_emprestimo, nome_responsavel])
        messages.success(request, 'Devolução registrada com sucesso!')
    except Exception as e:
        messages.error(request, f'Erro ao cadastrar devolução: {e}')

    return render(request, 'telas/cad_devolucao.html', {'emprestimos': emprestimos})

# Exclusão de empréstimo
def excluir_emprestimo(request, id_emprestimo):
    """
    Realiza o soft delete de um empréstimo, chamando a procedure pr_soft_delete_emprestimo.
    """
    nome_responsavel = request.session.get('usuario_nome', 'Administrador')
    try:
        with connection.cursor() as cursor:
            # Cria variável de saída para capturar o status retornado pela procedure
            cursor.callproc('pr_soft_delete_emprestimo', [id_emprestimo, nome_responsavel, None])

            # Se a procedure retornar resultado (por exemplo, SELECT dentro dela)
            for result in cursor.stored_results():
                resultado = result.fetchall()
        connection.commit()
        messages.success(request, "Empréstimo excluído com sucesso!")
    except Exception as e:
        messages.error(request, f"Erro ao excluir empréstimo: {e}")

    return redirect('emprestimos')


# Editar Empréstimo
def editar_emprestimo(request, id_emprestimo):
    """
    Edita as informações de um empréstimo chamando a procedure pr_atualiza_emprestimo.
    Captura e exibe mensagens de sucesso ou erro (inclusive as da trigger tg_emprestimosBU).
    """
    # Buscar listas de usuários e livros
    with connection.cursor() as cursor:
        cursor.execute("SELECT id, nome FROM usuarios WHERE usuario_ativo = 'S' AND bloqueado = 'N'")
        usuarios = [{'id': row[0], 'nome': row[1]} for row in cursor.fetchall()]

        cursor.execute("SELECT id, titulo FROM livros WHERE livro_ativo = 'S'")
        livros = [{'id': row[0], 'titulo': row[1]} for row in cursor.fetchall()]

    # Buscar dados do empréstimo
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT id, data_emprestimo, data_devolucao, emprestimo_ativo, id_usuario, id_livro 
            FROM emprestimos 
            WHERE id = %s
        """, [id_emprestimo])
        row = cursor.fetchone()

    if not row:
        messages.error(request, "Empréstimo não encontrado.")
        return redirect('emprestimos')

    emprestimo = {
        'id': row[0],
        'data_emprestimo': row[1],
        'data_devolucao': row[2],
        'emprestimo_ativo': row[3],
        'id_usuario': row[4],
        'id_livro': row[5]
    }

    # Caso o formulário seja enviado
    if request.method == "POST":
        data_emprestimo = request.POST.get("data_emprestimo")
        data_devolucao = request.POST.get("data_devolucao")
        emprestimo_ativo = request.POST.get("emprestimo_ativo", "S")
        id_usuario = request.POST.get("id_usuario")
        id_livro = request.POST.get("id_livro")
        nome_responsavel = request.session.get('usuario_nome', 'Administrador')

        try:
            with connection.cursor() as cursor:
                # Cria variável de saída
                cursor.execute("SET @p_status = '';")

                # Chama a procedure
                cursor.callproc("pr_atualiza_emprestimo", [
                    id_emprestimo,
                    data_emprestimo,
                    data_devolucao,
                    emprestimo_ativo,
                    id_usuario,
                    id_livro,
                    nome_responsavel,
                    '@p_status'
                ])

                # Recupera o valor do parâmetro de saída
                cursor.execute("SELECT @p_status;")
                p_status = cursor.fetchone()[0]

            connection.commit()


            messages.success(request, "Empréstimo atualizado com sucesso!")
            return redirect("emprestimos")

        except Exception as e:
            # Captura mensagens da trigger (como 'Livro sem exemplares disponíveis.', etc.)
            erro_mysql = str(e)
            if 'Usuário informado não encontrado' in erro_mysql:
                messages.error(request, "Usuário informado não encontrado.")
            elif 'Livro informado não existe' in erro_mysql:
                messages.error(request, "Livro informado não existe.")
            elif 'Livro sem exemplares disponíveis' in erro_mysql:
                messages.error(request, "Livro sem exemplares disponíveis.")
            elif 'data de devolução não pode ser anterior' in erro_mysql:
                messages.error(request, "A data de devolução não pode ser anterior à data de empréstimo.")
            elif 'data de empréstimo não pode ser uma data futura' in erro_mysql:
                messages.error(request, "A data de empréstimo não pode ser uma data futura.")
            elif 'data de devolução não pode ser uma data futura' in erro_mysql:
                messages.error(request, "A data de devolução não pode ser uma data futura.")
            else:
                # Mensagem genérica caso o erro seja diferente
                messages.error(request, f"Erro ao atualizar empréstimo: {erro_mysql}")

    return render(request, "telas/editar_emprestimo.html", {
        "emprestimo": emprestimo,
        "usuarios": usuarios,
        "livros": livros
    })


def sobre(request):
    """Página sobre"""
    return render(request, 'telas/sobre.html')