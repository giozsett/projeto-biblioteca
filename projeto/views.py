from django.shortcuts import render, redirect
from django.urls import reverse
from django.http import HttpResponseRedirect
from django.contrib.auth.forms import AuthenticationForm

def index(request):
    return render(request, 'index.html', {'titulo': 'index'})

def login(request):
    form = AuthenticationForm(request, data=request.POST or None)
    if request.method == 'POST':
        if form.is_valid():
            return redirect('login.html')  # sua lógica permanece igual
    return render(request, 'navbar/login.html')  # só esse ajuste
