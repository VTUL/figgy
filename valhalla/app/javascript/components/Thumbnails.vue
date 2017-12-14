<template>
  <div v-model="thumbnails" tag="div" name="list-complete" class="img_gallery">
      <div @click.capture="select(thumbnail.id, $event)"
            v-bind:style="{'max-width': thumbPixelWidth + 'px' }"
            class="thumbnail"
            v-bind:class="{ hasChanged: hasChanged(thumbnail.id) }"
            v-for="thumbnail in thumbnails" :key="thumbnail.id">
        <img :src="thumbnail.url" class="thumb">
        <div v-bind:style="{'padding': captionPixelPadding + 'px' }" class="caption">
          {{thumbnail.label}}
        </div>
      </div>
  </div>
</template>

<script>
export default {
  name: 'thumbnails',
  data: function () {
    return {
      thumbPixelWidth: 200,
      captionPixelPadding: 9
    }
  },
  computed: {
    thumbnails: {
      get () {
        return this.$store.state.images
      }
    },
    changeList: {
      get () {
        return this.$store.state.changeList
      }
    },
    selected: {
      get () {
        return this.$store.state.selected
      }
    }
  },
  methods: {
    hasChanged: function (id) {
      if (this.changeList.indexOf(id) > -1) {
        return true
      } else {
        return false
      }
    },
    isSelected: function (thumbnail) {
      return false
      // if (this.selected.indexOf(thumbnail) > -1) {
      //   return true
      // } else {
      //   return false
      // }
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.thumbnail {
  display: inline-block;
  max-width: 200px;
  margin: 10px;
}

.img_gallery {
  overflow: auto;
  height: calc(100% - 40px);
  border-radius: 4px;
  margin-bottom: 40px;
  clear: both;
}

.selected {
  border: 2px solid #9ecaed;
  box-shadow: 0 0 10px #9ecaed;
}

.hasChanged {
  background-color: Tomato
}

.thumbnail .caption {
  pointer-events: none;
  overflow: hidden;
}

.thumb {
  pointer-events: none;
}

</style>
