import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- Dados de Exemplo (Substitua pelos seus dados reais da rádio) ---
// Use o URL real da capa da rádio aqui:
const String currentRadioImageUrl = 'https://picsum.photos/300/300'; 
const String radioName = 'Nome da Sua Rádio';
// --------------------------------------------------------------------

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // Cores iniciais seguras para evitar o gradiente branco inicial
  Color _dominantColor = Colors.grey.shade900;
  Color _secondaryColor = Colors.black;

  @override
  void initState() {
    super.initState();
    // Inicia a extração de cor imediatamente ao carregar a tela
    _updatePalette();
  }

  // FUNÇÃO CORRIGIDA PARA EXTRAÇÃO DE COR E ATUALIZAÇÃO DO ESTADO
  Future<void> _updatePalette() async {
    // 1. Obtém a imagem (usando Cache)
    final ImageProvider imageProvider = CachedNetworkImageProvider(currentRadioImageUrl);

    // 2. Extrai a paleta de cores de forma ASSÍNCRONA
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      imageProvider,
      maximumColorCount: 10,
    );

    // 3. ATUALIZA O ESTADO (setState) para reconstruir o gradiente com a cor real
    if (mounted) {
      setState(() {
        // Pega a cor dominante. Se falhar, usa a cor escura padrão.
        _dominantColor = paletteGenerator.dominantColor?.color ?? Colors.grey.shade900;
        
        // Pega a cor escura para o gradiente
        _secondaryColor = paletteGenerator.darkMutedColor?.color ?? Colors.black;
      });
    }
  }

  // FUNÇÃO CORRIGIDA PARA NAVEGAÇÃO
  void _goToRadioList(BuildContext context) {
    // Ação que o botão deve executar: Navegar para a lista de rádios
    Navigator.of(context).push(
      MaterialPageRoute(
        // **IMPORTANTE:** TROQUE 'RadioListScreen' PELA SUA TELA REAL DE LISTA
        builder: (context) => const RadioListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CRUCIAL: Permite que o gradiente preencha toda a tela, atrás da AppBar
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Tocando Agora', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Transparente
        elevation: 0,
        
        // ÍCONE MAIS BONITO E AÇÃO CORRIGIDA
        leading: IconButton(
          // ÍCONE NOVO (Ex: Lista de estações)
          icon: const Icon(Icons.list_alt, color: Colors.white), 
          onPressed: () {
            // Chama a função de navegação, que agora funciona
            _goToRadioList(context);
          },
        ),
      ),
      body: Container(
        // CONTAINER COM O GRADIENTE DINÂMICO
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Usa as variáveis de estado que serão atualizadas
            colors: [_dominantColor, _secondaryColor], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // A Imagem da Rádio com sombra que usa a cor dominante
              CachedNetworkImage(
                imageUrl: currentRadioImageUrl,
                imageBuilder: (context, imageProvider) => Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.5),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
              ),
              const SizedBox(height: 30),
              Text(
                radioName,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              // ... outros elementos da sua tela ...
            ],
          ),
        ),
      ),
    );
  }
}
