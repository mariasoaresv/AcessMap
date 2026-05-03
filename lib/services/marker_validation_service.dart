// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

class MarkerValidationService {
  static Future<String> detectContext(
    mp.MapboxMap controller,
    mp.Point point,
  ) async {
    print(
      "DEBUG: detectContext iniciado para: ${point.coordinates.lng}, ${point.coordinates.lat}",
    );

    try {
      final screenCoord = await controller.pixelForCoordinate(point);

      final rect = mp.ScreenBox(
        min: mp.ScreenCoordinate(x: screenCoord.x - 3, y: screenCoord.y - 3),
        max: mp.ScreenCoordinate(x: screenCoord.x + 3, y: screenCoord.y + 3),
      );

      final features = await controller.queryRenderedFeatures(
        mp.RenderedQueryGeometry.fromScreenBox(rect),
        mp.RenderedQueryOptions(),
      );

      if (features.isNotEmpty) {
        final firstFeature = features.first?.queriedFeature;
        String layerId = '';

        if (firstFeature?.sourceLayer != null) {
          layerId = firstFeature!.sourceLayer!;
        } else if (firstFeature?.feature != null) {
          final dynamic layerData = firstFeature!.feature["layer"];

          if (layerData != null) {
            layerId = (layerData is Map)
                ? (layerData["id"]?.toString() ?? '')
                : layerData.toString();
          }
        }

        print("DEBUG: Camada identificada: '$layerId'");

        if (layerId.contains('building') ||
            layerId.contains('structure') ||
            layerId.contains('landuse')) {
          return 'estabelecimento';
        }
        if (layerId.contains('road') ||
            layerId.contains('street') ||
            layerId.contains('bridge') ||
            layerId.contains('tunnel')) {
          return 'rota';
        }
      } else {
        print("DEBUG: Nenhuma feature encontrada no local do clique.");
      }

      return 'calcada';
    } catch (e) {
      print("ERRO no MarkerValidationService: $e");
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
        return "Local inválido para esta categoria.";
    }
  }
}
