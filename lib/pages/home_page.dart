import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:image_picker/image_picker.dart';
import '../services/search_service.dart';
import '../widgets/barra_pesquisa.dart';
import '../services/marker_validation_service.dart';

class AnnotationClickListener extends mp.OnPointAnnotationClickListener {
  final void Function(mp.PointAnnotation annotation) onClick;
  AnnotationClickListener({required this.onClick});

  @override
  void onPointAnnotationClick(mp.PointAnnotation annotation) {
    onClick(annotation);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  mp.MapboxMap? mapboxMapController;
  mp.PointAnnotationManager? pointAnnotationManager;
  mp.PointAnnotation? _tempAnnotation;

  final Map<String, String> iconTypes = {
    'acessivel': 'Rota Acessível',
    'rampa': 'Rampa de Acesso',
    'vaga': 'Vaga Exclusiva (PCD)',
    'obstaculo': 'Obstáculo',
    'perigo': 'Perigo',
    'estbom': 'Estabelecimento Acessível',
    'estmedio': 'Estabelecimento Parcialmente acessível',
    'estruim': 'Estabelecimento Inacessível',
    'media': 'Rota com Acessibilidade Média',
    'ruim': 'Rota com Acessibilidade Ruim',
  };

  final Map<String, Map<String, dynamic>> _markersInfo = {};

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _searchAddress(val),
    );
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final resultados = await SearchService.buscar(query);
    setState(() {
      _searchResults = resultados;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          mp.MapWidget(
            onMapCreated: (controller) {
              mapboxMapController = controller;
              _initMapManager();
              _centerCameraOnUser();
            },
            styleUri: mp.MapboxStyles.DARK,
            onLongTapListener: (gesture) => _startAddMarkerFlow(gesture.point),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(59, 45, 134, 218),
              ),
            ),

          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Icon(
                                Icons.search,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Expanded(
                              child: SearchBarCustom(
                                onChanged: _onSearchChanged,
                                controller: _searchController,
                                onSearch: () {
                                  _searchAddress(_searchController.text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10),
                        ],
                      ),
                      child: IconButton(
                        icon: Image.asset('assets/icons/logo.png'),
                        onPressed: () => _centerCameraOnUser(),
                      ),
                    ),
                  ],
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(
                          _searchResults[i]['properties']['name'] ?? 'Local',
                        ),
                        onTap: () {
                          final coords =
                              _searchResults[i]['geometry']['coordinates'];
                          mapboxMapController?.setCamera(
                            mp.CameraOptions(
                              zoom: 16,
                              center: mp.Point(
                                coordinates: mp.Position(coords[0], coords[1]),
                              ),
                            ),
                          );
                          setState(() => _searchResults = []);
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home_outlined), onPressed: () {}),
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelp,
            ),
          ],
        ),
      ),
    );
  }

  void _initMapManager() async {
    mapboxMapController?.compass.updateSettings(
      mp.CompassSettings(enabled: false),
    );

    mapboxMapController?.scaleBar.updateSettings(
      mp.ScaleBarSettings(enabled: false),
    );

    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    pointAnnotationManager = await mapboxMapController?.annotations
        .createPointAnnotationManager();
    pointAnnotationManager?.addOnPointAnnotationClickListener(
      AnnotationClickListener(
        onClick: (annotation) {
          final data = _markersInfo[annotation.id];
          if (data != null) _showMarkerDetails(annotation, data);
        },
      ),
    );
  }

  Future<void> _startAddMarkerFlow(mp.Point point) async {
    String contextoDetectado = await MarkerValidationService.detectContext(
      mapboxMapController!,
      point,
    );

    final Uint8List imageData = await _loadAssetImage("acessivel");
    mp.PointAnnotationOptions tempOptions = mp.PointAnnotationOptions(
      geometry: point,
      image: imageData,
      iconSize: 3.0,
      iconAnchor: mp.IconAnchor.BOTTOM,
      isDraggable: true,
    );
    _tempAnnotation = await pointAnnotationManager?.create(tempOptions);

    if (!mounted) return;

    _openBottomSheetForMarker("acessivel", contextoDetectado);
  }

  void _openBottomSheetForMarker(String initialKey, String contextoDetectado) {
    String selectedKey = initialKey;
    TextEditingController desc = TextEditingController();
    XFile? photo;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nova Marcação",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Image.asset('assets/icons/$selectedKey.png', height: 60),
              DropdownButton<String>(
                value: selectedKey,
                isExpanded: true,
                items: iconTypes.keys
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(iconTypes[k]!),
                      ),
                    )
                    .toList(),
                onChanged: (val) async {
                  if (val != null && _tempAnnotation != null) {
                    setModal(() => selectedKey = val);

                    final oldGeom = _tempAnnotation!.geometry;
                    await pointAnnotationManager!.delete(_tempAnnotation!);

                    final Uint8List newImg = await _loadAssetImage(val);
                    _tempAnnotation = await pointAnnotationManager!.create(
                      mp.PointAnnotationOptions(
                        geometry: oldGeom,
                        image: newImg,
                        iconSize: 3.0,
                        iconAnchor: mp.IconAnchor.BOTTOM,
                        isDraggable: true,
                      ),
                    );
                  }
                },
              ),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  photo == null ? "Adicionar Foto" : "Foto Selecionada",
                ),
                onPressed: () async {
                  final p = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (p != null) setModal(() => photo = p);
                },
              ),
              if (photo != null) Image.file(File(photo!.path), height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      pointAnnotationManager?.delete(_tempAnnotation!);
                      _tempAnnotation = null;
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String contexto =
                          MarkerValidationService.getContextForCategory(
                            selectedKey,
                          );
                      bool sucesso = await _finalize(
                        selectedKey,
                        desc.text,
                        photo,
                        contexto,
                      );

                      if (sucesso) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Salvar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _finalize(
    String key,
    String desc,
    XFile? photo,
    String contexto,
  ) async {
    if (desc.trim().isEmpty || photo == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Atenção"),
          content: const Text(
            "Por favor, preencha a descrição e adicione uma imagem do local!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return false;
    }

    if (_tempAnnotation == null) return false;

    bool valido = MarkerValidationService.canPlaceMarker(key, contexto);

    if (!valido) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(MarkerValidationService.getErrorMessage(key))),
      );
      return false;
    }

    _tempAnnotation!.isDraggable = false;

    _markersInfo[_tempAnnotation!.id] = {
      'iconKey': key,
      'title': iconTypes[key],
      'desc': desc,
      'photo': photo.path,
    };
    await pointAnnotationManager?.update(_tempAnnotation!);
    _tempAnnotation = null;
    return true;
  }

  void _showMarkerDetails(
    mp.PointAnnotation annotation,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    data['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(annotation),
                ),
              ],
            ),
            Image.asset('assets/icons/${data['iconKey']}.png', height: 60),
            Text(data['desc'], textAlign: TextAlign.center),
            if (data['photo'] != null)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      body: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.file(File(data['photo'])),
                        ),
                      ),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(data['photo']),
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Fechar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(mp.PointAnnotation annotation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Ponto?"),
        content: const Text("Tem certeza que deseja remover este marcador?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await pointAnnotationManager?.delete(annotation);
              _markersInfo.remove(annotation.id);

              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelp() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Ajuda"),
      content: const Text("Segure o dedo no mapa para adicionar pontos."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("OK"),
        ),
      ],
    ),
  );

  Future<void> _centerCameraOnUser() async {
    Position pos = await Geolocator.getCurrentPosition();
    mapboxMapController?.setCamera(
      mp.CameraOptions(
        zoom: 16,
        center: mp.Point(coordinates: mp.Position(pos.longitude, pos.latitude)),
      ),
    );
  }

  Future<Uint8List> _loadAssetImage(String name) async {
    final data = await rootBundle.load("assets/icons/$name.png");
    return data.buffer.asUint8List();
  }
}
