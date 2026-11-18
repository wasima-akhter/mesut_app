import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/constants/route_constants.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../../../../core/pagination/app_pagination_footer.dart';
import '../../../../../core/widgets/states/app_empty_widget.dart';
import '../../../../../core/widgets/states/app_screen_state_view.dart';
import '../../data/repositories/projects_repository_impl.dart';
import '../../domain/entities/project_phase_card_entity.dart';
import '../providers/site_manager_projects_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_filter_bottom_sheet.dart';
import '../widgets/project_header.dart';
import '../widgets/project_search_delegate.dart';
import '../widgets/project_skeleton_loader.dart';
import '../widgets/project_tabs_bar.dart';

class SiteManagerProjectsPage extends ConsumerStatefulWidget {
  const SiteManagerProjectsPage({super.key});

  @override
  ConsumerState<SiteManagerProjectsPage> createState() =>
      _SiteManagerProjectsPageState();
}

class _SiteManagerProjectsPageState
    extends ConsumerState<SiteManagerProjectsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(siteManagerProjectsProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(siteManagerProjectsProvider.notifier).loadMore();
    }
  }

  void _openSearch(
    BuildContext context,
    List<ProjectPhaseCardEntity> projects,
  ) {
    final repository = ref.read(projectsRepositoryProvider);
    showSearch(
      context: context,
      delegate: ProjectSearchDelegate(
        repository: repository,
        initialProjects: projects,
        onProjectSelected: (project) {
          context.push(
            RouteConstants.siteManagerProjectDetail,
            extra: project.projectId.isNotEmpty
                ? project.projectId
                : project.phaseId,
          );
        },
      ),
    );
  }

  void _openFilters(BuildContext context, SiteManagerProjectsState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProjectFilterBottomSheet(
          initialPhases: state.filterState.phases,
          initialCities: state.filterState.cities,
          initialPriority: state.filterState.priority,
          initialCustomerCategory: state.filterState.customerCategory,
          initialSortBy: state.filterState.sortBy,
          onApply:
              ({
                required List<String> phases,
                required List<String> cities,
                required String priority,
                required String customerCategory,
                required String sortBy,
              }) {
                ref
                    .read(siteManagerProjectsProvider.notifier)
                    .setFilter(
                      phases: phases,
                      cities: cities,
                      priority: priority,
                      customerCategory: customerCategory,
                      sortBy: sortBy,
                    );
              },
        );
      },
    );
  }

  void _addProject(BuildContext context) {
    context.push(RouteConstants.siteManagerCreateproject);
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(siteManagerProjectsProvider);
    final projects = projectsState.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: ProjectHeader(
                onOpenSearch: () => _openSearch(context, projects),
                onOpenFilters: () => _openFilters(context, projectsState),
              ),
            ),
            const SizedBox(height: 12),
            ProjectTabsBar(
              selectedTab: projectsState.selectedTab,
              onSelectTab: (tab) =>
                  ref.read(siteManagerProjectsProvider.notifier).selectTab(tab),
            ),
            const SizedBox(height: 11),
            Expanded(
              child: AppScreenStateView(
                status: projectsState.status,
                errorMessage: projectsState.errorMessage,
                errorObject: projectsState.errorObject,
                loadingShimmer: const ProjectSkeletonLoader(),
                emptyPlaceholder: AppEmptyWidget(
                  message: context.loc.noProjectsFound,
                  onRetry: () => ref
                      .read(siteManagerProjectsProvider.notifier)
                      .loadInitial(),
                ),
                onRetry: () => ref
                    .read(siteManagerProjectsProvider.notifier)
                    .loadInitial(),
                child: PendingPollEffect(
                  hasPending: anyLocalizationPending(
                    projects.map((p) => p.localization),
                  ),
                  onPoll: () => ref
                      .read(siteManagerProjectsProvider.notifier)
                      .loadInitial(isRefresh: true),
                  child: RefreshIndicator(
                    color: const Color(0xFFC8102E),
                    onRefresh: () => ref
                        .read(siteManagerProjectsProvider.notifier)
                        .loadInitial(isRefresh: true),
                    child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final project = projects[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ProjectCard(
                                project: project,
                                onTap: () {
                                  context.push(
                                    RouteConstants.siteManagerProjectDetail,
                                    extra: project.projectId.isNotEmpty
                                        ? project.projectId
                                        : project.phaseId,
                                  );
                                },
                              ),
                            );
                          }, childCount: projects.length),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: AppPaginationFooter(
                          hasMore: projectsState.hasMore,
                          isLoadingMore: projectsState.isLoadingMore,
                          itemCount: projects.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
                    ],
                  ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProject(context),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}
