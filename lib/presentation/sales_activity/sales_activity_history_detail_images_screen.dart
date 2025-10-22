import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/sales_activity/history_visit/history_visit_detail/list_image/sales_activity_history_visit_detail_list_image_bloc.dart';
import '../../models/sales_activity/history_detail.dart';

class SalesActivityHistoryDetailImagesScreen extends StatefulWidget {
  final HistoryDetail historyDetail;
  const SalesActivityHistoryDetailImagesScreen({super.key, required this.historyDetail});

  @override
  State<SalesActivityHistoryDetailImagesScreen> createState() => _SalesActivityHistoryDetailImagesScreenState();
}

class _SalesActivityHistoryDetailImagesScreenState extends State<SalesActivityHistoryDetailImagesScreen> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<SalesActivityHistoryVisitDetailListImageBloc>().add(FetchSalesActivityImages(
      entityId: widget.historyDetail.entityId,
      trId: widget.historyDetail.trId,
      seqId: widget.historyDetail.seqId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Images History Visit',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<SalesActivityHistoryVisitDetailListImageBloc, SalesActivityHistoryVisitDetailListImageState>(
          builder: (context, state) {
            if (state is HistoryImagesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryImagesError) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is HistoryImagesSuccess) {
              return Padding(
                padding: EdgeInsets.all(8.w),
                child: GridView.builder(
                  itemCount: state.images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final image = state.images[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        "https://v2.kencana.org/storage/sales-activity/VIVA/${image.imgUrl}",
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
    );
  }
}