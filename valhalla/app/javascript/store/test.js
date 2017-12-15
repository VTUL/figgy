import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  count: 0
}

// export `mutations` as a named export
export const mutations = {
  increment: state => state.count++
}

export default new Vuex.Store({
  state,
  mutations
})
