import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vivakencanaapp/bloc/auth/authentication/authentication_bloc.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';

import '../../bloc/fdpi/residence/residence_bloc.dart';
import '../../data/repository/fdpi_repository.dart';
import 'fdpi_coordinates_screen.dart';

class FDPITResidencesScreen extends StatelessWidget {
  final String idProvince;
  final String idCity;
  final String status;

  const FDPITResidencesScreen({
    super.key,
    required this.idProvince,
    required this.idCity,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final fdpiRepository = context.read<FdpiRepository>();

    return BlocProvider(
      create: (context) {
        return ResidenceBloc(fdpiRepository: fdpiRepository)
          ..add(LoadResidence(idProvince, idCity, status));
      },
      child: ResidenceListView(),
    );
  }
}

class ResidenceListView extends StatelessWidget {
  ResidenceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1E4694),
        title: const Text('FDPI', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(
          color: Colors.white, // This makes back button white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ResidenceBloc, ResidenceState>(
          listener: (context, state) {
            if (state is ResidenceLoadFailure) {
              if (state is UnauthorizedException) {
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
            if (state is ResidenceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ResidenceLoadSuccess) {
              return MasonryGridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                itemCount: state.residences.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FDPICoordinatesScreen(
                                  idCluster: state.residences[index].idSite,
                                  clusterImg:
                                      state.residences[index].imgCluster,
                                  clusterName: state.residences[index].siteName,
                                ),
                          ),
                        ),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state
                              .residences[index]
                              .imgClusterThumbnail
                              .isNotEmpty) ...[
                            AspectRatio(
                              aspectRatio:
                                  16 / 9, // Your desired ratio (width/height)
                              child: Image(
                                image: CachedNetworkImageProvider(
                                  'https://v2.kencana.org/storage/${state.residences[index].imgClusterThumbnail}',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.residences[index].siteName}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 11,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 4),
                                if (state
                                    .residences[index]
                                    .siteAddress
                                    .isNotEmpty) ...[
                                  Text(
                                    '${state.residences[index].siteAddress}',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 9,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                                Text(
                                  '${state.residences[index].remark ?? '-'}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 9,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
