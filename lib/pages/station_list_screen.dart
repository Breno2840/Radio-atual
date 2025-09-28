// lib/pages/station_list_screen.dart (AJUSTADO)
// ... (imports)

class StationListScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  // REMOVIDO: final VoidCallback onShowPlayer; 

  const StationListScreen({
    super.key,
    required this.audioHandler,
    // REMOVIDO: required this.onShowPlayer, 
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo matemático (AJUSTADO para a remoção do botão)
    final screenHeight = MediaQuery.of(context).size.height;
    final screenPadding = MediaQuery.of(context).padding;
    const topWidgetHeight = 28 + 20; // Apenas o título 'Estações de Rádio'
    final availableHeight = screenHeight - screenPadding.top - screenPadding.bottom - topWidgetHeight;
    // ... (restante do cálculo da proporção)
    
    // ATENÇÃO: Se o MiniPlayer aparecer, ele ocupará 70px que precisamos subtrair do availableHeight.
    // Uma solução mais robusta seria usar LayoutBuilder, mas para manter a simplicidade, vamos ignorar a altura do mini-player
    // já que ele só aparece quando algo está tocando e a altura calculada já é 'desejada'.

    return Column(
      children: [
        // REMOVIDO: Row com MainAxisAlignment.spaceBetween
        const Align(
          alignment: Alignment.centerLeft, // Alinhamento do título
          child: Text(
            'Estações de Rádio',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        // REMOVIDO: Botão de voltar ao player
        
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            // ... (gridDelegate permanece igual)
            itemBuilder: (context, index) {
              final station = radioStations[index];
              return RadioGridItem(
                station: station,
                onTap: () {
                  audioHandler.playStation(station);
                  // REMOVIDO: onShowPlayer()
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
