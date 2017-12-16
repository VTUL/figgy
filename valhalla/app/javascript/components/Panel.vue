<template>
  <div class="formPanel actions">
    <!-- Resource Form-->
    <resource-form v-if="selectedTotal === 0" id="noneSelected" class="formContent"/>
    <!-- Multiple Selected Form-->
    <filesets-form v-if="selectedTotal > 1" id="multiSelected"/>
    <!-- Single Selected Form-->
    <fileset-form v-if="selectedTotal === 1" id="singleSelected"/>
  </div>
</template>

<script>
import ResourceForm from './ResourceForm'
import FilesetForm from './FilesetForm'
import FilesetsForm from './FilesetsForm'

export default {
  name: 'panel',
  components: {
    'resource-form': ResourceForm,
    'fileset-form': FilesetForm,
    'filesets-form': FilesetsForm
  },
  computed: {
    selectedTotal () {
      return this.$store.state.selected.length
    }
  }
}
</script>
