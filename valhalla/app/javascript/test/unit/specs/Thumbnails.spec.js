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
  let store

  beforeEach(() => {
    actions = {
      actionClick: jest.fn(),
      actionInput: jest.fn()
    }
    store = new Vuex.Store({
      state: {
        images: Fixtures.imageCollection,
        selected: Fixtures.selected,
        ogImages: Fixtures.imageCollection,
        changeList: Fixtures.changeList
      },
      actions
    })

    options = {
      computed: {
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
    const wrapper = shallow(Thumbnails, { options, store, localVue })
    let expanded = wrapper.find('.thumbnail')
    const thumb = expanded.html().replace(/(<(pre|script|style|textarea)[^]+?<\/\2)|(^|>)\s+|\s+(?=<|$)/g, "$1$3")
    expect(thumb).toEqual('<div class="thumbnail" style="max-width: 200px;"><img src="http://example.com" class="thumb"><div class="caption" style="padding: 9px;">baz</div></div>')
  })

  it('has the expected html structure', () => {
    const wrapper = shallow(Thumbnails, { options, store, localVue })
    expect(wrapper.element).toMatchSnapshot()
  })

  // it('selectedImageUrl function has the expected value', () => {
  //   expect(wrapper.vm.selectedImageUrl).toEqual("http://localhost:3000/image-service/50b5e49b-ade7-4278-8265-4f72081f26a5/full/400,/0/default.jpg")
  // })

})
