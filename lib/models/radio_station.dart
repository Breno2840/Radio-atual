// lib/models/radio_station.dart
class RadioStation {
  final String name;
  final String streamUrl;
  final String artUrl;
  final String frequency;
  final String location;

  RadioStation({
    required this.name,
    required this.streamUrl,
    required this.artUrl,
    required this.frequency,
    required this.location,
  });
}

// A lista de dados também vai para cá, facilitando o acesso.
final List<RadioStation> radioStations = [
  RadioStation(name: 'Radio Jovem Pan', streamUrl: 'https://stream.zeno.fm/c45wbq2us3buv', artUrl: 'https://425w010y9m.ucarecd.net/9f5576a9-38da-48b4-9fab-67b09984ae0b/-/preview/1000x1000/', frequency: '100.9 FM', location: 'São Paulo, SP'),
  RadioStation(name: 'Rádio Cultura', streamUrl: 'https://stm2.aovivodigital.com.br:10250/stream', artUrl: 'https://425w010y9m.ucarecd.net/677f45db-9ea5-4bf0-b211-698b420e4cb7/-/preview/1000x1000/', frequency: '1460 AM', location: 'Amarante, PI'),
  RadioStation(name: 'Rádio Tropical', streamUrl: 'https://tropical.jmvstream.com/stream', artUrl: 'https://425w010y9m.ucarecd.net/65e6d639-3c24-4415-97e4-f180dbcc4bbc/-/preview/1000x1000/', frequency: '94.1 FM', location: 'Boa Vista, RR'),
  RadioStation(name: 'FM O Dia', streamUrl: 'https://tropical.jmvstream.com/stream', artUrl: 'https://425w010y9m.ucarecd.net/88343274-c74b-42a8-a392-409b3b9467a6/-/preview/1000x1000/', frequency: '92.7 FM', location: 'Teresina, PI'),
  RadioStation(name: 'Meio Norte', streamUrl: 'https://webradio.amsolution.com.br/radio/8280/meionorte', artUrl: 'https://425w010y9m.ucarecd.net/4a548754-8e87-4fdf-b6c4-f3b4e4586ae5/-/preview/1000x1000/', frequency: '99.9 FM', location: 'Teresina, PI'),
  RadioStation(name: 'Rádio Alvorada', streamUrl: 'http://stm1.painelvox.xyz:6682/stream', artUrl: 'https://425w010y9m.ucarecd.net/1b82a179-c174-4745-9523-e606f4e93fa1/-/preview/1000x1000/', frequency: '87.9 FM', location: 'Rosário Oeste, MT'),
  RadioStation(name: 'Rádio Jornal', streamUrl: 'https://str1.streamhostpg.com.br:8124/stream', artUrl: 'https://425w010y9m.ucarecd.net/3b19f973-45f3-4601-ae62-76fe0bb38f29/-/preview/1000x1000/', frequency: '91.3 FM', location: 'Aracaju, SE'),
  RadioStation(name: 'Rádio Clube News', streamUrl: 'https://servidor14-3.brlogic.com:7540/live', artUrl: 'https://425w010y9m.ucarecd.net/c1e6f1e8-1f27-4a92-a453-c8efe192d244/-/preview/1000x1000/', frequency: '90.9 FM', location: 'Teresina, PI'),
  RadioStation(name: 'Rádio Canção Nova', streamUrl: 'https://streaming.fox.srv.br:8074/stream', artUrl: 'https://425w010y9m.ucarecd.net/286ec7b0-c023-4156-b5ae-9d71c938d403/-/preview/1000x1000/', frequency: '89.1 FM', location: 'Cachoeira Paulista, SP'),
  RadioStation(name: 'Rádio Aparecida', streamUrl: 'https://aparecida.jmvstream.com/stream', artUrl: 'https://425w010y9m.ucarecd.net/531f5224-9d7f-468e-8be1-fac4888f7691/-/preview/1000x1000/', frequency: '104.3 FM', location: 'Aparecida, SP'),
];
