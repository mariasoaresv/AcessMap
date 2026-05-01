import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

class MarkerValidationService {
  static Future<String> detectContext(
    mp.MapboxMap controller,
    mp.Point point,
  ) async {
    try {
      final screenCoord = await controller.pixelForCoordinate(point);

      // Consulta o que tem embaixo do clique
      final features = await controller.queryRenderedFeatures(
        mp.RenderedQueryGeometry.fromScreenCoordinate(screenCoord),
        mp.RenderedQueryOptions(),
      );

      if (features.isNotEmpty) {
        final String layerId =
            // ignore: invalid_null_aware_operator
            features.first?.queriedFeature?.sourceLayer ?? '';

        // ignore: avoid_print
        print(
          "Layer ID encontrado: $layerId",
        ); 

        if (layerId.contains('building') || layerId.contains('landuse'))
          return 'estabelecimento';
        if (layerId.contains('road') || layerId.contains('street'))
          return 'rota';
        if (layerId.contains('sidewalk') || layerId.contains('path'))
          return 'calcada';
      }

      return 'calcada';
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao consultar mapa: $e");
      return 'calcada';
    }
  }

  static String getContextForCategory(String category) {
    if (['rampa', 'obstaculo', 'perigo'].contains(category)) return 'calcada';
    if (['acessivel', 'media', 'ruim'].contains(category)) return 'rota';
    if (['estbom', 'estmedio', 'estruim'].contains(category))
      return 'estabelecimento';
    return 'vaga';
  }

  static bool canPlaceMarker(String category, String locationContext) {
    if (category == 'vaga') return true;

    String expectedContext = getContextForCategory(category);
    return locationContext == expectedContext;
  }


  static String getErrorMessage(String category) {
    switch (category) {
      case 'estbom':
      case 'estmedio':
      case 'estruim':
        return "Este marcador só pode ser colocado em estabelecimentos.";
      case 'rampa':
      case 'obstaculo':
      case 'perigo':
        return "Este marcador só pode ser colocado em calçadas.";
      case 'acessivel':
      case 'media':
      case 'ruim':
        return "Este marcador só pode ser colocado em rotas.";
      default:
        return "Categoria inválida para este local.";
    }
  }
}
