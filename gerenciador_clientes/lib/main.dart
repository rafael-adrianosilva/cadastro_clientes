import 'package:flutter/material.dart';
import 'package:gerenciador_clientes/modelos/cliente.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // importa nosso modelo de BD

//instanciando nosso BD
final ServicoClientes servicoClientes = ServicoClientes();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter está pronto.

  // Inicializa o Firebase (OBRIGATÓRIO).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      home: TelaLogin( // Agora está começando no login
        // Só muda isso aqui dbx
        // cliente: Cliente(nome: 'DEV', email: 'dev@gmail.com', senha: '0'),
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
        title: const Text('Área do Cliente'),
        automaticallyImplyLeading: false,
        actions: [
          //Botão de Sair (Logout).
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navega~çao: Limpa a pilha e volta para a tela de login.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TelaLogin()),
                (Route<dynamic> route) => false, // condição que remove todas as rotas.
              );
            },
            tooltip: 'Sair do Sistema',
          )
        ],
      ),
        body: Center(
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // ...coisas do seu código
    const Text('Clientes cadastrados (BD Firebase):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    // Lista de Clientes conectada ao Firebase
// Lista de Clientes Cadastrados
StreamBuilder<List<Cliente>>(
  stream: servicoClientes.clientesStream,
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Text('Erro ao carregar clientes.');
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final clientes = snapshot.data ?? [];
    return Expanded(
      child: ListView.builder(
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final c = clientes[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(c.nome),
            subtitle: Text(c.email),
          );
        },
      ),
    );
  },
),
            ],
          ),
        ),
      ),
    );
  }
}

// ATUALIZE O PLACEHOLDER DA TELA DE LOGIN PARA INCLUIR A NAVEGAÇÃO
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _EstadoTelaLogin();
}

class _EstadoTelaLogin extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';

  void _fazerLogin() async { // AGORA É ASYNC
  // Valida os campos... (código omitido, mas continua o mesmo)

  if (_chaveForm.currentState!.validate()) {
    setState(() => _mensagemErro = '');

    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    // CHAMA O SERVIÇO FIREBASE e AGUARDA O RESULTADO
    final clienteLogado = await servicoClientes.login(email, senha); // <-- AWAIT AQUI!

    if (clienteLogado != null) {
      // Se sucesso, navega...
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TelaPrincipal(cliente: clienteLogado),
        ),
      );
    } else {
      // Login falhou...
      setState(() {
        _mensagemErro = 'E-mail ou senha incorretos.';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso ao Sistema')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _chaveForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Bem-vindo!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              // Campo E-mail
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (valor) => (valor == null || !valor.contains('@')) ? 'E-mail inválido.' : null,
              ),
              const SizedBox(height: 16),
              // Campo Senha
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (valor) => (valor == null || valor.length < 6) ? 'A senha deve ter 6+ caracteres.' : null,
              ),
              const SizedBox(height: 20),
              // Mensagem de Erro
              if (_mensagemErro.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_mensagemErro, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              // Botão de Login
              ElevatedButton.icon(
                onPressed: _fazerLogin,
                icon: const Icon(Icons.login),
                label: const Text('Entrar'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 10),
              // Botão para Cadastrar
              TextButton(
                onPressed: () {
                  // Navega para a tela de cadastro.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaCadastro()),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se aqui.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // BOA PRÁTICA: Liberar os controladores
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _EstadoTelaCadastro();
}

class _EstadoTelaCadastro extends State<TelaCadastro> {
  final _chaveForm = GlobalKey<FormState>(); // Chave para validar o formulário.
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';

  void _fazerCadastro() async { // AGORA É ASYNC
  if (_chaveForm.currentState!.validate()) {
    setState(() => _mensagemErro = '');

    final novoCliente = Cliente(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    // CHAMA O SERVIÇO FIREBASE e AGUARDA O RESULTADO
    final sucesso = await servicoClientes.cadastrar(novoCliente); // <-- AWAIT AQUI!

    if (sucesso) {
      // Se sucesso: exibe mensagem e volta para a tela de Login.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cadastro realizado com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      // Se falhar (e-mail duplicado).
      setState(() {
        _mensagemErro = 'E-mail já cadastrado. Tente outro!';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cadastro de Cliente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _chaveForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Crie sua conta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (valor) => (valor == null || valor.isEmpty) ? 'Campo obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              // Campo E-mail
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                validator: (valor) => (valor == null || !valor.contains('@')) ? 'E-mail inválido.' : null,
              ),
              const SizedBox(height: 16),
              // Campo Senha
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                validator: (valor) => (valor == null || valor.length < 6) ? 'A senha deve ter 6+ caracteres.' : null,
              ),
              const SizedBox(height: 20),
              // Mensagem de Erro
              if (_mensagemErro.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_mensagemErro, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              // Botão de Cadastro
              ElevatedButton.icon(
                onPressed: _fazerCadastro,
                icon: const Icon(Icons.app_registration),
                label: const Text('Cadastrar'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // BOA PRÁTICA: Liberar os controladores quando o widget for removido
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
