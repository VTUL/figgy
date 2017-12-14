<template>
  <draggable v-model="thumbnails" tag="div" name="list-complete" class="img_gallery">
      <div @click.capture="select(thumbnail.id, $event)"
            v-bind:style="{'max-width': thumbPixelWidth + 'px' }"
            class="thumbnail"
            v-bind:class="{ hasChanged: hasChanged(thumbnail.id), selected: isSelected(thumbnail) }"
            v-for="thumbnail in thumbnails" :key="thumbnail.id">
        <img :src="thumbnail.url" class="thumb">
        <div v-bind:style="{'padding': captionPixelPadding + 'px' }" class="caption">
          {{thumbnail.label}}
        </div>
      </div>
  </draggable>
</template>

<script>
import draggable from 'vuedraggable'
export default {
  name: 'thumbnails',
  components: {
    draggable
  },
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
      },
      set (value) {
        this.$store.dispatch('sortImages', value)
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
    getImageById: function (id) {
      var elementPos = this.getImageIndexById(id)
      return this.thumbnails[elementPos]
    },
    getImageIndexById: function (id) {
      return this.thumbnails.map(function (image) {
        return image.id
      }).indexOf(id)
    },
    hasChanged: function (id) {
      if (this.changeList.indexOf(id) > -1) {
        return true
      } else {
        return false
      }
    },
    isSelected: function (thumbnail) {
      if (this.selected.indexOf(thumbnail) > -1) {
        return true
      } else {
        return false
      }
    },
    select: function (id, event) {
      var selected = []
      if (event.metaKey) {
        selected = this.selected
        selected.push(this.getImageById(id))
        this.$store.dispatch('handleSelect', selected)
      } else {
        if (this.selected.length === 1 && event.shiftKey) {
          var first = this.getImageIndexById(this.selected[0].id)
          var second = this.getImageIndexById(id)
          var min = Math.min(first, second)
          var max = Math.max(first, second)
          for (var i = min; i <= max; i++) {
            selected.push(this.thumbnails[i])
          }
          this.$store.dispatch('handleSelect', selected)
        } else {
          this.$store.dispatch('handleSelect', [this.getImageById(id)])
        }
      }
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
