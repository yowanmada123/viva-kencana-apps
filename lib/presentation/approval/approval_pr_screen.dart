// approval_pr_screen.dart
import 'dart:developer';

import 'package:vivakencanaapp/bloc/approval_pr/approval_pr_list/approval_pr_list_bloc.dart';
import 'package:vivakencanaapp/bloc/approval_pr/approve_pr/approve_pr_bloc.dart';
import 'package:vivakencanaapp/bloc/auth/authentication/authentication_bloc.dart';
import 'package:vivakencanaapp/data/repository/approval_pr_repository.dart';
// import 'package:vivakencanaapp/models/approval_pr/approval_pr.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_fdpi.dart';
// import 'package:vivakencanaapp/models/fdpi/approval_pr/approval_pr.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';
import 'package:vivakencanaapp/presentation/widgets/approval/approval_pr_card.dart';
// import 'package:vivakencanaapp/presentation/widgets/approval/aprrove_bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../bloc/authorization/credentials/credentials_bloc.dart';

class ApprovalPrScreen extends StatefulWidget {
  final String title;
  final String entityId;
  const ApprovalPrScreen({
    super.key,
    required this.title,
    required this.entityId,
  });

  @override
  ApprovalPrScreenState createState() => ApprovalPrScreenState();
}

class ApprovalPrScreenState extends State<ApprovalPrScreen> {
  final PageController _pageController = PageController();
  final List<ScrollController> _scrollControllers = [];
  int _currentPage = 0;
  bool _isAnimated = false;

  @override
  void initState() {
    log('Access to presentation/approval/approval_pr_screen.dart');
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (int i = 0; i < 3; i++) {
      _scrollControllers.add(ScrollController());
    }
  }

  void _handleApproval(
    int index,
    List<ApprovalPrFSunrise> poList,
    BuildContext context,
  ) {
    if (index >= poList.length) return;

    final current = poList[index];

    // Langsung approve (BE yang validasi levelnya)
    context.read<ApprovePrBloc>().add(
      ApprovePrLoadEvent(
        prId: current.prId,
        status: "approve",
        entityId: widget.entityId.toLowerCase(),
      ),
    );
  }

  void _handleReject(
    int index,
    List<ApprovalPrFSunrise> poList,
    BuildContext context,
  ) {
    if (index >= poList.length) return;

    final current = poList[index];

    // Langsung reject (BE yang validasi levelnya)
    context.read<ApprovePrBloc>().add(
      ApprovePrLoadEvent(
        prId: current.prId,
        status: "reject",
        entityId: widget.entityId.toLowerCase(),
      ),
    );
  }

  // void _showNoPermissionSnackBar(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text("Anda tidak memiliki permission untuk approve PR"),
  //     ),
  //   );
  // }

  ScrollController _getController(int index) {
    return _scrollControllers[index % 3];
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ApprovalPrListBloc(
                approvalPRRepository: context.read<ApprovalPRRepository>(),
              )..add(
                GetApprovalPRListEvent(entityId: widget.entityId.toLowerCase()),
              ),
        ),
        BlocProvider(
          create:
              (context) => ApprovePrBloc(
                approvalPRRepository: context.read<ApprovalPRRepository>(),
              ),
        ),
      ],
      child: BlocListener<ApprovePrBloc, ApprovePrState>(
        listener: (context, state) {
          if (state is ApprovePrLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Processing..."),
                duration: Duration(seconds: 1),
              ),
            );
          }

          if (state is ApprovePrSuccess) {
            context.read<ApprovalPrListBloc>().add(
              RemoveListByPrId(prId: state.prId),
            );

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Notifikasi"),
                  content: Text(state.message),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop(); // Menutup dialog
                      },
                    ),
                  ],
                );
              },
            );
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(state.message),
            //     backgroundColor: Colors.green,
            //   ),
            // );
          }

          if (state is ApprovePrFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Poppins",
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: BlocConsumer<ApprovalPrListBloc, ApprovalPrListState>(
              listener: (context, state) {
                if (state is ApprovalPrListFailureState) {
                  if (state.error is UnauthorizedException) {
                    context.read<AuthenticationBloc>().add(
                      SetAuthenticationStatus(isAuthenticated: false),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Session Anda telah habis. Silakan login kembali",
                        ),
                        duration: Duration(seconds: 5),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color(0xffEB5757),
                      ),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    return;
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is ApprovalPrListInitial ||
                    state is ApprovalPrListLoadingState) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is ApprovalPrListFailureState) {
                  return Center(child: Text(state.message));
                }
                if (state is ApprovalPrListSuccessState) {
                  if (_currentPage >= state.data.length &&
                      state.data.isNotEmpty) {
                    _currentPage = state.data.length - 1;
                    _pageController.animateToPage(
                      _currentPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }

                  if (state.data.isEmpty) {
                    return Center(
                      child: Text(
                        "Approval PR Tidak Tersedia",
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) => true,
                    child: PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: state.data.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return ApprovalPrCard(
                          requests: state.data[index],
                          scrollController: _getController(index),
                          onReachBottom: () async {
                            if (_isAnimated) return;
                            setState(() => _isAnimated = true);

                            final nextPage = index + 1;
                            if (nextPage < state.data.length) {
                              await _pageController.animateToPage(
                                nextPage,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }

                            setState(() => _isAnimated = false);
                          },
                          onReachTop: () async {
                            if (_isAnimated) return;
                            setState(() => _isAnimated = true);

                            final prevPage = index - 1;
                            if (prevPage >= 0) {
                              await _pageController.animateToPage(
                                prevPage,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }

                            setState(() => _isAnimated = false);
                          },
                          onApprove:
                              () => _handleApproval(
                                _currentPage,
                                state.data,
                                context,
                              ),
                          onReject:
                              () => _handleReject(
                                _currentPage,
                                state.data,
                                context,
                              ),
                        );
                      },
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          // bottomNavigationBar:
          //     BlocBuilder<ApprovalPrListBloc, ApprovalPrListState>(
          //       builder: (context, state) {
          //         // log("This Work");
          //         if (state is! ApprovalPrListSuccessState) {
          //           log("A");

          //           return SizedBox.shrink();
          //         }
          //         final poList = state.data;

          //         // 2. Jika list kosong → button disembunyikan
          //         if (poList.isEmpty) {
          //           log("List kosong → button disembunyikan");
          //           return SizedBox.shrink();
          //         }

          //         // 3. Cek apakah currentPage masih valid
          //         if (_currentPage < 0 || _currentPage >= poList.length) {
          //           log("Current page diluar range → button disembunyikan");
          //           return SizedBox.shrink();
          //         }

          //         // final currentPr = poList[_currentPage];
          //         log("B");

          //         return ApprovalBottomBar(
          //           isLoading: false,
          //           onApprove:
          //               () =>
          //                   _handleApproval(_currentPage, state.data, context),
          //           onReject:
          //               () => _handleReject(_currentPage, state.data, context),
          //           canApprove: true,
          //         );
          //       },
          //     ),
        ),
      ),
    );
  }
}
