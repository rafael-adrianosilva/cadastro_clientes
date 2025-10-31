// importe necessário
import 'package:flutter/material.dart';

class Cliente{
  final String nome;
  final String email;
  final String senha;

  // Construtor do cliente
  Cliente({
    required this.nome,
    required this.email,
    required this.senha,
  });
  @override
  String toString(){
    return 'Cliente: $nome, Email: $email';
  }
}

class GerenciadorClientes{
  // Variável estática que guarda a única cópia desta classe
  static final GerenciadorClientes _instancia = GerenciadorClientes._interno();
  //impede a criação de novas instâncias
  GerenciadorClientes._interno();
  //sempre retorna a instância existente
  factory GerenciadorClientes() => _instancia;
  //lista <ul> que armazena todos os clientes cadastrados
  final List<Cliente> _clientes = [];
  //para acessar a lista de clientes (retorna uma cópia imutável) 
  List<Cliente> get clientes => List.unmodifiable(_clientes);
  //Tentar cadastrar um cliente novo
  bool cadastrar(Cliente cliente){
    // vamos checar se já existe um email cadastrado
    if(_clientes.any((c) => c.email.toLowerCase() == cliente.email.toLowerCase())){
      print('Erro: email ${cliente.email} já cadastrado');
      return false; //Cadastro falhou
    }
    _clientes.add(cliente); //Adicionar o cliente
    print('Novo cliente cadastrado: ${cliente.nome}');
    return true; //Cadastroooooouuuuuu
  }

  Cliente ? login(String email, String senha){
    return _clientes.firstWhere(
      //é uma função anônima
      //o c representa cada elemento(cada cliente) da lista _clientes
      (c) => c.email.toLowerCase() == email.toLowerCase() && c.senha == senha,
      orElse: () => Null as Cliente, //retorna nulo se não encontrar os dados
    );
  }

}