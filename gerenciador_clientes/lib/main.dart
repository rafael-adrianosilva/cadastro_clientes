import 'package:flutter/material.dart';
import 'package:gerenciador_clientes/modelos/cliente.dart'; // importa nosso modelo de BD

//instanciando nosso BD
final GerenciadorClientes gerenciadorClientes = GerenciadorClientes();

void main(){
  gerenciadorClientes.cadastrar(
    Cliente(nome: 'Admin', email: 'admin@email.com', senha: 'admin'),
  );
  runApp(const AplicativoClientes());
}

class AplicativoClientes extends StatelessWidget{
  const AplicativoClientes ({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Sistema de Clientes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true
      ),
      home: TelaPrincipal(
        cliente: Cliente(nome: 'DEV', email: 'dev@gmail.com', senha: '0'),
      )
    );
  }
}

class TelaPrincipal extends StatelessWidget{
  final Cliente cliente;

  const TelaPrincipal({super.key, required this.cliente});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Principal (Em Construção)')),
        body: Center(
            child: Text(
              'Bem Vindo, ${cliente.nome}!!',
              style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class TelaLogin extends StatelessWidget{
  const TelaLogin({super.key});
    @override
    Widget build(BuildContext context) => const Scaffold(body: Center(
      child: Text('Login...'),
    )
  );
}

class TelaCadastro extends StatelessWidget {
  const TelaCadastro({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Cadastro...')),
  );
}