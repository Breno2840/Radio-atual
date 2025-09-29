// lib/models/radio_station.dart

class RadioStation {
  final String name;
  final String frequency;
  final String band;
  final String location;
  final String streamUrl;
  final String artUrl;

  const RadioStation({
    required this.name,
    required this.frequency,
    required this.band,
    required this.location,
    required this.streamUrl,
    required this.artUrl,
  });
}

// Lista completa e atualizada de estações de rádio
const List<RadioStation> radioStations = [
  // NOVAS RÁDIOS ADICIONADAS
  RadioStation(
    name: 'Rádio Jaraguá',
    frequency: '101.3',
    band: 'FM',
    location: 'Jaraguá do Sul, SC',
    streamUrl: 'https://wz7.servidoresbrasil.com:8066/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/75a6dedd-0db9-423f-aa2f-511ab921f9e0/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Cidade Verde',
    frequency: '93.5',
    band: 'FM',
    location: 'Teresina, PI',
    streamUrl: 'https://ssl1.transmissaodigital.com:20010/stream', // O ponto e vírgula foi removido no final
    artUrl: 'https://425w010y9m.ucarecd.net/c80b1460-27e9-433d-8c34-7a5922646a9f/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Capital',
    frequency: '101.9',
    band: 'FM',
    location: 'Cuiabá, MT',
    streamUrl: 'https://radio.saopaulo01.com.br/8214/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/04d5ede0-c6b7-4adb-95fc-27c001cd9d25/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Cultura',
    frequency: '90.7',
    band: 'FM',
    location: 'Cuiabá, MT',
    streamUrl: 'http://sc4.dnip.com.br:11260/stream', // O ponto e vírgula foi removido no final
    artUrl: 'https://425w010y9m.ucarecd.net/f2a605e7-811a-4205-950d-dfe7de14a1c3/-/preview/1000x1000/',
  ),
  
  // RÁDIOS ANTERIORES
  RadioStation(
    name: 'Rádio Jovem Pan',
    frequency: '100.9',
    band: 'FM',
    location: 'São Paulo, SP',
    streamUrl: 'https://stream.zeno.fm/c45wbq2us3buv',
    artUrl: 'https://425w010y9m.ucarecd.net/9f5576a9-38da-48b4-9fab-67b09984ae0b/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Cultura',
    frequency: '1460',
    band: 'AM',
    location: 'Amarante, PI',
    streamUrl: 'https://stm2.aovivodigital.com.br:10250/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/677f45db-9ea5-4bf0-b211-698b420e4cb7/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Tropical',
    frequency: '94.1',
    band: 'FM',
    location: 'Boa Vista, RR',
    streamUrl: 'https://tropical.jmvstream.com/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/65e6d639-3c24-4415-97e4-f180dbcc4bbc/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'FM O Dia',
    frequency: '92.7',
    band: 'FM',
    location: 'Teresina, PI',
    streamUrl: 'https://tropical.jmvstream.com/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/88343274-c74b-42a8-a392-409b3b9467a6/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Meio Norte',
    frequency: '99.9',
    band: 'FM',
    location: 'Teresina, PI',
    streamUrl: 'https://webradio.amsolution.com.br/radio/8280/meionorte',
    artUrl: 'https://425w010y9m.ucarecd.net/4a548754-8e87-4fdf-b6c4-f3b4e4586ae5/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Alvorada',
    frequency: '87.9',
    band: 'FM',
    location: 'Rosário Oeste, MT',
    streamUrl: 'http://stm1.painelvox.xyz:6682/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/1b82a179-c174-4745-9523-e606f4e93fa1/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Jornal',
    frequency: '91.3',
    band: 'FM',
    location: 'Aracaju, SE',
    streamUrl: 'https://str1.streamhostpg.com.br:8124/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/3b19f973-45f3-4601-ae62-76fe0bb38f29/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Clube News',
    frequency: '90.9',
    band: 'FM',
    location: 'Teresina, PI',
    streamUrl: 'https://servidor14-3.brlogic.com:7540/live',
    artUrl: 'https://425w010y9m.ucarecd.net/c1e6f1e8-1f27-4a92-a453-c8efe192d244/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Canção Nova',
    frequency: '89.1',
    band: 'FM',
    location: 'Cachoeira Paulista, SP',
    streamUrl: 'https://streaming.fox.srv.br:8074/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/286ec7b0-c023-4156-b5ae-9d71c938d403/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Aparecida',
    frequency: '104.3',
    band: 'FM',
    location: 'Aparecida, SP',
    streamUrl: 'https://aparecida.jmvstream.com/stream',
    artUrl: 'https://425w010y9m.ucarecd.net/531f5224-9d7f-468e-8be1-fac4888f7691/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio BandNews',
    frequency: '96.9',
    band: 'FM',
    location: 'São Paulo, SP',
    streamUrl: 'https://playerservices.streamtheworld.com/api/livestream-redirect/BANDNEWSFM_SPAAC.aac?dist=radios.com.br',
    artUrl: 'https://425w010y9m.ucarecd.net/f7fa89c7-e3f2-4368-a0d1-95866dc6c44e/-/preview/1000x1000/',
  ),
  RadioStation(
    name: 'Rádio Jangadeiro',
    frequency: '88.9',
    band: 'FM',
    location: 'Fortaleza, CE',
    streamUrl: 'https://fmfortaleza.jmvstream.com/FMFortaleza_live',
    artUrl: 'https://425w010y9m.ucarecd.net/06018b3e-22be-45e6-b305-97e12f104b9d/-/preview/1000x1000/',
  ),
];
