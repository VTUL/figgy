import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'
import manifesto from 'manifesto.js'
import mixins from '../mixins/manifesto-filemanager-mixins'

Vue.use(Vuex)

const state = {
  id: '',
  startPage: '',
  thumbnail: '',
  images: [],
  selected: [],
  ogImages: [],
  changeList: []
}

const mutations = {
  SELECT (state, imgArray) {
    state.selected = imgArray
  },
  SET_STATE (state, ImageCollection) {
    state.id = ImageCollection.id
    state.startPage = ImageCollection.startpage
    state.thumbnail = ImageCollection.thumbnail
    state.images = ImageCollection.images
    state.ogImages = ImageCollection.images
    // state.images = [ ...ImageCollection.images ]
    // state.ogImages = [ ...ImageCollection.images ]
  },
  SAVE_STATE (state, reset) {
    alert('state saved!')
    state.ogImages = [ ...state.images ]
    state.changeList = [ ...reset ]
    state.selected = [ ...reset ]
  },
  SORT_IMAGES (state, value) {
    state.images = [ ...value ]
  },
  UPDATE_CHANGES (state, changeList) {
    state.changeList = [ ...changeList ]
  },
  UPDATE_IMAGES (state, images) {
    state.images = [ ...images ]
  },
  UPDATE_STARTPAGE (state, startPage) {
    state.startPage = startPage
  },
  UPDATE_THUMBNAIL (state, thumbnail) {
    state.thumbnail = thumbnail
  }
}

const actions = {
  incrementAsync ({ commit }) {
    setTimeout(() => {
      commit('INCREMENT')
    }, 200)
  },
  loadImageCollection (context, resource) {
    const manifest_uri = '/concern/'+ resource.class_name + '/' + resource.id + '/manifest'
    axios.get(manifest_uri).then((response) => {
      const manifestation = Object.assign(manifesto.create(JSON.stringify(response.data)), mixins)
      window.manifestation = manifestation
      context.commit('SET_STATE', manifestation.imageCollection(resource) )
    }, (err) => {
      console.log(err)
    })
  },
  handleSelect (context, imgArray) {
    context.commit('SELECT', imgArray)
  },
  saveState (context, body) {
    window.body = body
    let errors = []
    let token = document.getElementsByName('csrf-token')[0].getAttribute('content')

    axios.defaults.headers.common['X-CSRF-Token'] = token
    axios.defaults.headers.common['Accept'] = 'application/json'

    let file_set_promises = []
    for (let i = 0; i < body.file_sets.length; i++) {
      console.log(body.file_sets[i].id)
      file_set_promises.push(axios.patch('/concern/file_sets/' + body.file_sets[i].id, body.file_sets[i]))
    }

    axios.patch('/concern/ephemera_folders/' + body.resource.ephemera_folder.id, body.resource).then((response) => {
      console.log(response)
      axios.all(file_set_promises).then(axios.spread((...args) => {
        console.log(args)
        context.commit('SAVE_STATE', [])
      }, (err) => {
        alert(errors.join('\n'))
      }))
    }, (err) => {
      alert(errors.join('\n'))
    })
  },
  sortImages (context, value) {
    context.commit('SORT_IMAGES', value)
  },
  updateChanges (context, changeList) {
    context.commit('UPDATE_CHANGES', changeList)
  },
  updateImages (context, images) {
    context.commit('UPDATE_IMAGES', images)
  },
  updateStartPage (context, startPage) {
    context.commit('UPDATE_STARTPAGE', startPage)
  },
  updateThumbnail (context, thumbnail) {
    context.commit('UPDATE_THUMBNAIL', thumbnail)
  }
}

const getters = {
  imageIdList: state => {
    return state.images.map(image => image.id)
  }
}

const store = new Vuex.Store({
  state,
  mutations,
  actions,
  getters
})

export default store