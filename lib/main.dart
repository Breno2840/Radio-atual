// lib/main.dart (Atualizado para incluir o Mini-Player no Scaffold)
// ... (todos os imports permanecem iguais)
import 'widgets/mini_player.dart'; // NOVO IMPORT
// ...

class MyApp extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  const MyApp({super.key, required this.audioHandler});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ... (variáveis e _updateBackgroundColors permanecem iguais)
  Color _startColor = const Color(0xFF1D244D);
  Color _endColor = const Color(0xFF000000);
  Uri? _lastArtUri;
  
  // Função para mudar a tela para o Player. Será passada para o Mini-Player
  void _goToPlayerScreen() {
    // Isso forçará o StreamBuilder a reconstruir com o PlayerScreen
    setState(() {
      // Usaremos uma variável de estado para controlar se a tela cheia está ativa
      // Se não for o MainScreen, ele sempre volta para a tela de grade.
      // Vamos simplificar e usar o Navigator para a tela cheia.
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Rádio',
      theme: ThemeData.dark(),
      home: StreamBuilder<MediaItem?>(
        stream: widget.audioHandler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          
          if (mediaItem != null && mediaItem.artUri != _lastArtUri) {
            _lastArtUri = mediaItem.artUri;
            _updateBackgroundColors(mediaItem.artUri!);
          }
          
          final startColor = mediaItem != null ? _startColor : const Color(0xFF1D244D);
          final endColor = mediaItem != null ? _endColor : const Color(0xFF000000);
          
          RadioStation? playingStation;
          if (mediaItem != null) {
            playingStation = radioStations.firstWhere(
              (station) => station.streamUrl == mediaItem.id,
              orElse: () => radioStations.first
            );
          }
          
          // O Scaffold principal agora fica aqui para podermos usar o bottomNavigationBar
          return AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [startColor, endColor]
              )
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent, // Permite que o gradiente do AnimatedContainer apareça
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MainScreen(audioHandler: widget.audioHandler),
                ),
              ),
              
              // NOVIDADE: O Mini-Player
              bottomNavigationBar: mediaItem != null && playingStation != null 
                  ? MiniPlayer(
                      audioHandler: widget.audioHandler,
                      mediaItem: mediaItem,
                      station: playingStation,
                      onTap: () {
                        // Navega para a tela cheia do player
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => PlayerScreen(
                              audioHandler: widget.audioHandler,
                              mediaItem: mediaItem,
                              station: playingStation!,
                              // Precisamos de uma função 'onClose' para fechar a tela
                              onClose: () => Navigator.of(ctx).pop(), 
                            ),
                          ),
                        );
                      },
                    )
                  : null, // Não mostra o mini-player se não houver rádio tocando
            ),
          );
        },
      ),
    );
  }
}
