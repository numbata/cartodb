<template>
  <Page>
    <StickySubheader :is-visible="Boolean(selectedDatasets.length && isScrollPastHeader)">
      <h2 class="title is-caption">
        {{ $t('BulkActions.selected', {count: selectedDatasets.length}) }}
      </h2>
      <DatasetBulkActions
        :selectedDatasets="selectedDatasets"
        :areAllDatasetsSelected="areAllDatasetsSelected"
        @selectAll="selectAll"
        @deselectAll="deselectAll"></DatasetBulkActions>
    </StickySubheader>

    <DatasetsList
      ref="datasetsList"
      class="grid__content"
      :hasBulkActions="true"
      :canHoverCard="true"
      :maxVisibleDatasets="maxVisibleDatasets"
      @applyFilter="applyFilter"
      @applyOrder="applyOrder"
      @selectionChange="updateSelected" />
    <Pagination v-if="shouldShowPagination" :page=currentPage :numPages=numPages @pageChange="goToPage"></Pagination>
  </Page>
</template>

<script>

import { mapState } from 'vuex';
import { checkFilters } from 'new-dashboard/router/hooks/check-navigation';
import Page from 'new-dashboard/components/Page';
import Pagination from 'new-dashboard/components/Pagination';
import DatasetBulkActions from 'new-dashboard/components/BulkActions/DatasetBulkActions.vue';
import StickySubheader from '../components/StickySubheader';
import DatasetsList from 'new-dashboard/components/DatasetsList.vue';

export default {
  name: 'DataPage',
  components: {
    DatasetBulkActions,
    StickySubheader,
    Page,
    Pagination,
    DatasetsList
  },
  data () {
    return {
      isScrollPastHeader: false,
      maxVisibleDatasets: 12,
      selectedDatasets: []
    };
  },
  beforeMount () {
    if (this.$store.getters['user/isViewer']) {
      // Redirect to shared datasets page if user is viewer
      return this.$router.replace({ name: 'datasets', params: { filter: 'shared' } });
    }
  },
  mounted () {
    this.stickyScrollPosition = this.getHeaderBottomPageOffset();
    this.$onScrollChange = this.onScrollChange.bind(this);
    document.addEventListener('scroll', this.$onScrollChange, { passive: true });
  },
  beforeDestroy () {
    document.removeEventListener('scroll', this.$onScrollChange, { passive: true });
  },
  beforeRouteUpdate (to, from, next) {
    checkFilters('datasets', 'datasets', to, from, next);
  },
  computed: {
    ...mapState({
      numPages: state => state.datasets.numPages,
      currentPage: state => state.datasets.page,
      datasets: state => state.datasets.list,
      isFetchingDatasets: state => state.datasets.isFetching,
      numResults: state => state.datasets.metadata.total_entries
    }),
    isNotificationVisible () {
      return this.$store.getters['user/isNotificationVisible'];
    },
    areAllDatasetsSelected () {
      return Object.keys(this.datasets).length === this.selectedDatasets.length;
    },
    shouldShowPagination () {
      return !this.isFetchingDatasets && this.numResults > 0 && this.numPages > 1;
    }
  },
  methods: {
    updateSelected (selected) {
      this.selectedDatasets = selected;
    },
    goToPage (page) {
      this.deselectAll();
      window.scroll({ top: 0, left: 0 });

      this.$router.push({
        name: 'datasets',
        params: this.$route.params,
        query: {...this.$route.query, page}
      });
    },
    applyFilter (filter) {
      this.$router.push({ name: 'datasets', params: { filter } });
    },
    applyOrder (orderParams) {
      this.deselectAll();
      this.$router.push({
        name: 'datasets',
        params: this.$route.params,
        query: {
          ...this.$route.query,
          page: 1,
          order: orderParams.order,
          order_direction: orderParams.direction
        }
      });
    },
    selectAll () {
      this.$refs.datasetsList.selectAll();
    },
    deselectAll () {
      this.$refs.datasetsList.deselectAll();
    },
    onScrollChange () {
      this.isScrollPastHeader = window.pageYOffset > this.stickyScrollPosition;
    },
    getHeaderBottomPageOffset () {
      const headerContainer = this.$refs.datasetsList.getHeaderContainer();
      const headerBoundingClientRect = headerContainer.$el.getBoundingClientRect();
      const notificationHeight = this.isNotificationVisible ? 60 : 0;
      return headerBoundingClientRect.top - notificationHeight;
    }
  }
};
</script>
