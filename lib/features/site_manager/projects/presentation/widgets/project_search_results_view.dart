import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../domain/entities/project_phase_card_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import 'project_card.dart';

class ProjectSearchResultsView extends StatefulWidget {
  final String query;
  final ProjectsRepository repository;
  final List<ProjectPhaseCardEntity> initialProjects;
  final ValueChanged<ProjectPhaseCardEntity> onProjectSelected;

  const ProjectSearchResultsView({
    super.key,
    required this.query,
    required this.repository,
    required this.initialProjects,
    required this.onProjectSelected,
  });

  @override
  State<ProjectSearchResultsView> createState() =>
      _ProjectSearchResultsViewState();
}

class _ProjectSearchResultsViewState extends State<ProjectSearchResultsView> {
  final ScrollController _scrollController = ScrollController();
  List<ProjectPhaseCardEntity> _results = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _executeSearch(widget.query);
  }

  @override
  void didUpdateWidget(covariant ProjectSearchResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _executeSearch(widget.query);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 100 && !_isLoadingMore && _hasMore) {
      _loadNextPage();
    }
  }

  void _executeSearch(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _results = widget.initialProjects;
        _isLoading = false;
        _isLoadingMore = false;
        _hasMore = false;
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchInitial(query.trim());
    });
  }

  Future<void> _fetchInitial(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final response = await widget.repository.getProjects(
        search: query,
        page: 1,
        limit: 10,
      );

      if (!mounted) return;
      setState(() {
        _results = response.items;
        _hasMore = response.meta.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    try {
      final response = await widget.repository.getProjects(
        search: widget.query.trim(),
        page: nextPage,
        limit: 10,
      );

      if (!mounted) return;
      // Deduplicate by phaseId
      final existingIds = _results.map((p) => p.phaseId).toSet();
      final newItems = response.items.where((p) => !existingIds.contains(p.phaseId));

      setState(() {
        _results = [..._results, ...newItems];
        _currentPage = nextPage;
        _hasMore = response.meta.hasMore;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.loc.error,
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => _fetchInitial(widget.query.trim()),
                child: Text(context.loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48.sp, color: const Color(0xFF999999)),
              SizedBox(height: 10.h),
              Text(
                context.loc.noProjectsFound,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: _results.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _results.length) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final project = _results[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: ProjectCard(
            project: project,
            onTap: () => widget.onProjectSelected(project),
          ),
        );
      },
    );
  }
}
