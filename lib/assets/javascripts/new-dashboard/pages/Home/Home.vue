<template>
  <Page class="page--welcome">
    <Welcome />
    <RecentSection class="section" v-if="isSectionActive('RecentSection') && hasRecentContent" @sectionChange="changeSection" @contentChanged="onContentChanged"/>
    <TagsSection class="section tags-section" v-if="isSectionActive('TagsSection')" @sectionChange="changeSection"/>
    <MapsSection class="section" @contentChanged="onContentChanged"/>
    <DatasetsSection class="section section--noBorder" @contentChanged="onContentChanged"/>
    <QuotaSection></QuotaSection>

    <router-view name="onboarding-modal"/>
  </Page>
</template>

<script>
import Welcome from './WelcomeSection/Welcome.vue';
import TagsSection from './TagsSection/TagsSection.vue';
import RecentSection from './RecentSection/RecentSection.vue';
import MapsSection from './MapsSection/MapsSection.vue';
import DatasetsSection from './DatasetsSection/DatasetsSection.vue';
import QuotaSection from './QuotaSection/QuotaSection.vue';
import Page from 'new-dashboard/components/Page';

export default {
  name: 'Home',
  components: {
    Welcome,
    TagsSection,
    RecentSection,
    MapsSection,
    DatasetsSection,
    QuotaSection,
    Page
  },
  beforeMount () {
    this.$store.dispatch('recentContent/fetch');

    this.$store.dispatch('maps/resetFilters');
    this.$store.dispatch('datasets/resetFilters');

    this.$store.dispatch('maps/setResultsPerPage', 6);
    this.$store.dispatch('datasets/setResultsPerPage', 6);

    // If user is viewer, show shared maps and datasets
    if (this.$store.getters['user/isViewer']) {
      this.$store.dispatch('maps/filter', 'shared');
      this.$store.dispatch('datasets/filter', 'shared');
    }

    this.$store.dispatch('maps/fetch');
    this.$store.dispatch('datasets/fetch');
  },
  data () {
    return {
      activeSection: this.$route.query.section || 'RecentSection'
    };
  },
  computed: {
    hasRecentContent () {
      return this.$store.getters['recentContent/hasRecentContent'] ||
        this.$store.state.recentContent.isFetching;
    },
    isFirstTimeViewingDashboard () {
      return this.$store.state.config.isFirstTimeViewingDashboard;
    }
  },
  methods: {
    isSectionActive (activeSection) {
      return activeSection === this.activeSection;
    },
    changeSection (nextActiveSection) {
      this.activeSection = nextActiveSection;
    },
    onContentChanged () {
      this.$store.dispatch('recentContent/fetch');
      this.$store.dispatch('maps/fetch');
      this.$store.dispatch('datasets/fetch');
    }
  }
};
</script>

<style scoped lang="scss">
@import 'new-dashboard/styles/variables';

header.is-user-notification + section.page--welcome {
  padding: 0;
}

.section {
  position: relative;

  &--maps {
    z-index: $z-index__stack-context--first;
  }

  &--datasets {
    z-index: $z-index__stack-context--second;
  }
}

.tags-section {
  padding-bottom: 104px;
}
</style>
