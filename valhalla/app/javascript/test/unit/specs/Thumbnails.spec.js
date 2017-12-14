import Vue from 'vue'
import Vuex from 'vuex'
import { mount, shallow, createLocalVue } from 'vue-test-utils'
import Thumbnails from '@/components/Thumbnails'
import Fixtures from '@/test/fixtures/image-collection'
const localVue = createLocalVue()
localVue.use(Vuex)

describe('Thumbnails.vue', () => {
  let wrapper
  let options
  let actions
  let state
  let store

  beforeEach(() => {
    actions = {
      handleSelect: jest.fn(),
      sortImages: jest.fn()
    }
    state = {
      images: Fixtures.imageCollection,
      selected: Fixtures.selected,
      ogImages: Fixtures.imageCollection,
      changeList: Fixtures.changeList
    }
    store = new Vuex.Store({
      state,
      actions
    })

    options = {
      computed: {
        thumbnails: {
          get () {
            return state.imageCollection
          }
        },
        thumbnails: {
          get () {
            return state.imageCollection
          }
        },
        changelist: {
          get () {
            return state.changeList
          }
        },
        selected: {
          get () {
            return state.selected
          }
        }
      }
    }

  })

  it('renders a $store.state value return from computed', () => {
    const wrapper = mount(Thumbnails, { options, store, localVue })
    let expanded = wrapper.find('.thumbnail')
    const thumb = expanded.html().replace(/(<(pre|script|style|textarea)[^]+?<\/\2)|(^|>)\s+|\s+(?=<|$)/g, "$1$3")
    expect(thumb).toEqual('<div class="thumbnail" style="max-width: 200px;"><img src="http://example.com" class="thumb"><div class="caption" style="padding: 9px;">baz</div></div>')
  })

  it('has the expected html structure', () => {
    const wrapper = mount(Thumbnails, { options, store, localVue })
    expect(wrapper.element).toMatchSnapshot()
  })

  it('allows the selection of a thumbnail', () => {
    const wrapper = mount(Thumbnails, { options, store, localVue })
    wrapper.find('.thumbnail').trigger('click')
    expect(state.selected).toHaveLength(1)
    expect(actions.handleSelect).toHaveBeenCalled()
  })

  it('allows the selection of multiple thumbnails via Shift+click', () => {
    const wrapper = mount(Thumbnails, { options, store, localVue })
    wrapper.findAll('.thumbnail').at(0).trigger('click')
    wrapper.findAll('.thumbnail').at(1).trigger('click.capture', {
      shiftKey: true
    })
    expect(state.selected).toHaveLength(2)
  })

  // Todo: once the above can pass write one for selection of multiples via META+click


})
