// screens/location_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivakencanaapp/data/repository/fdpi_repository.dart';
import 'package:vivakencanaapp/bloc/fdpi/location/location_bloc.dart';
import 'package:vivakencanaapp/models/fdpi/province.dart';
import 'package:vivakencanaapp/models/fdpi/city.dart';
import 'package:vivakencanaapp/models/fdpi/status.dart';
import 'package:vivakencanaapp/presentation/fdpi/fdpi_residences_screen.dart';

class FDPIMenuScreen extends StatelessWidget {
  const FDPIMenuScreen({super.key});

  VoidCallback _navigateToFdpiResidenceScreen(BuildContext context, LocationState state) {
    // Handle form submission
    final province = state.selectedProvince?.idProvince ?? "";
    final city = state.selectedCity?.idCity ?? "";
    final status = state.selectedStatus?.name ?? "Aktif";
    
    return () {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => FDPITResidencesScreen(
            idProvince: province,
            idCity: city,
            status: status
          )
        )
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final fdpiRepository = context.read<FdpiRepository>();

    return BlocProvider(
      create: 
        (context) => 
          LocationBloc(fdpiRepository: fdpiRepository)
          ..add(LoadProvinces())
          ..add(LoadStatusResidence()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1E4694),
          title: const Text(
            'FDPI', 
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // This makes back button white
          ),
          
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              if (state.status == LocationStatus.initial ||
                  state.status == LocationStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == LocationStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'Error'));
              }

              return Column(
                children: [
                  // Province Dropdown
                  _buildProvinceDropdown(context, state),
                  const SizedBox(height: 20),
                  // City Dropdown
                  _buildCityDropdown(context, state),
                  const SizedBox(height: 20),
                  // Status Dropdown
                  _buildStatusDropdown(context, state),
                  const SizedBox(height: 20),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _navigateToFdpiResidenceScreen(context, state),
                    child: const Text('Submit'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown(BuildContext context, LocationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Province', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<Province>(
          isExpanded: true,
          value: state.selectedProvince,
          hint: const Text('Select Province'),
          items: state.provinces.map((province) {
            return DropdownMenuItem<Province>(
              value: province,
              child: Text(province.province),
            );
          }).toList(),
          onChanged: (province) {
            context.read<LocationBloc>().add(ProvinceChanged(province));
          },
        ),
      ],
    );
  }

  Widget _buildCityDropdown(BuildContext context, LocationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<City>(
          isExpanded: true,
          value: state.selectedCity,
          hint: const Text('Select City'),
          items: state.cities.map((city) {
            return DropdownMenuItem<City>(
              value: city,
              child: Text(city.cityName),
            );
          }).toList(),
          onChanged: state.selectedProvince == null
              ? null
              : (city) {
                  context.read<LocationBloc>().add(CityChanged(city));
                },
        ),
        if (state.selectedProvince != null && state.cities.isEmpty)
          const Text(
            'No cities available for this province',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context, LocationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<Status>(
          isExpanded: true,
          value: state.selectedStatus,
          hint: const Text('Select Status'),
          items: state.statuses.map((status) {
            return DropdownMenuItem<Status>(
              value: status,
              child: Text(status.name),
            );
          }).toList(),
          onChanged: (status) {
            context.read<LocationBloc>().add(StatusChanged(status));
          },
        ),
      ],
    );
  }
}