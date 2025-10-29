from django.shortcuts import render, redirect
from django.urls import reverse
from django.http import HttpResponseRedirect
from django.contrib.auth.forms import AuthenticationForm
from django.db import models

def index(request):
    return render(request, 'index.html', {'titulo': 'index'})

def login(request):
    form = AuthenticationForm(request, data=request.POST or None)
    if request.method == 'POST':
        if form.is_valid():
            return redirect('login.html')  # sua lógica permanece igual
    return render(request, 'telas/login.html')  # só esse ajuste

def cadastrar(request):
    return render(request, 'telas/cadastrar.html')

def cad_livro(request):
    return render(request, 'telas/cad_livro.html')

def catalogo(request):
    return render(request, 'telas/catalogo.html')
