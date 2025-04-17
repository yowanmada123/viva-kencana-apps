import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../bloc/auth/authentication/authentication_bloc.dart';

import '../../bloc/fdpi/map/map_bloc.dart';
import '../../data/repository/fdpi_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../../models/fdpi/house.dart';

class FDPICoordinatesScreen extends StatelessWidget {
  final String idCluster;
  final String clusterImg;
  final String clusterName;

  const FDPICoordinatesScreen({
    super.key,
    required this.idCluster,
    required this.clusterImg,
    required this.clusterName,
  });

  @override
  Widget build(BuildContext context) {
    final fdpiRepository = context.read<FdpiRepository>();

    return LandscapeOrientationWrapper(
      child: BlocProvider(
        create: (context) {
          return MapBloc(fdpiRepository: fdpiRepository)
            ..add(LoadMap(idCluster));
        },
        child: MapCoordinatsView(
          clusterImg: clusterImg,
          clusterName: clusterName,
        ),
      ),
    );
  }
}

class MapCoordinatsView extends StatelessWidget {
  final String clusterImg;
  final String clusterName;

  const MapCoordinatsView({
    super.key,
    required this.clusterImg,
    required this.clusterName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          clusterName,
          style: TextStyle(fontFamily: "Poppins", color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLoadFailure) {
            if (state.exception is UnauthorizedException) {
              context.read<AuthenticationBloc>().add(
                SetAuthenticationStatus(isAuthenticated: false),
              );
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoadSuccess) {
            return MapView(clusterImg: clusterImg, units: state.units);
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class MapView extends StatefulWidget {
  final String clusterImg;
  final List<House> units;

  const MapView({super.key, required this.clusterImg, required this.units});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final LatLngBounds _imageBounds = LatLngBounds(
    const LatLng(0.0, 0.0), // Always start at 0,0
    const LatLng(1, 1.5),
  );
  final LayerHitNotifier _hitNotifier = ValueNotifier(null);

  Color _getColorWithOpacity(String hexColor, double opacity) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add fully opaque alpha if missing
    }
    return Color(int.parse(hexColor, radix: 16)).withOpacity((opacity));
  }

  List<Polygon> _mapToPolygons(List<House> units) {
    return units
        .where(
          (unit) => unit.coordinates != null && unit.coordinates!.isNotEmpty,
        )
        .map((unit) {
          return Polygon(
            points: unit.coordinates!,
            color: _getColorWithOpacity(unit.color, 0.15),
            borderColor: _getColorWithOpacity(unit.color, 1.0),
            borderStrokeWidth: 1.0,
            hitValue: unit, // Each polygon gets its associated House object
          );
        })
        .toList();
  }

  void _handlePolygonTap() {
    final hitResult = _hitNotifier.value;
    if (hitResult == null || hitResult.hitValues.isEmpty) {
      return;
    }

    final tappedUnit = hitResult.hitValues.first;
    print('Tapped unit ID: ${tappedUnit}');
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        crs: const CrsSimple(), // Required for custom coordinates
        initialCenter: _imageBounds.center,
        initialZoom: 0,
        minZoom: 0,
        maxZoom: 2,
        onTap: (_, __) => _handlePolygonTap(),
      ),
      children: [
        OverlayImageLayer(
          overlayImages: [
            OverlayImage(
              bounds: _imageBounds,
              opacity: 1.0,
              imageProvider: CachedNetworkImageProvider(
                'https://v2.kencana.org/storage/${widget.clusterImg}',
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _handlePolygonTap,
          child: PolygonLayer(
            hitNotifier: _hitNotifier,
            polygonCulling: true,
            polygons: _mapToPolygons(widget.units),
          ),
        ),
      ],
    );
  }
}

class LandscapeOrientationWrapper extends StatefulWidget {
  final Widget child;

  const LandscapeOrientationWrapper({super.key, required this.child});

  @override
  State<LandscapeOrientationWrapper> createState() =>
      _LandscapeOrientationWrapperState();
}

class _LandscapeOrientationWrapperState
    extends State<LandscapeOrientationWrapper> {
  @override
  void initState() {
    super.initState();
    // Set landscape when widget initializes
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset to portrait when widget disposes
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
