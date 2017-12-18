import Vuex from 'vuex'
import { mount, createLocalVue } from 'vue-test-utils'
import Controls from '@/components/Controls'
import Fixtures from '@/test/fixtures/image-collection'
const localVue = createLocalVue()
localVue.use(Vuex)

describe('Controls.vue', () => {
  let wrapper
  let options
  let actions
  let getters
  let state
  let store

  beforeEach(() => {
    actions = {
      saveState: jest.fn()
    }
    getters = {
      orderChanged: () => false,
      stateChanged: () => false
    }
    // state = {
    //   images: Fixtures.imageCollection,
    //   selected: Fixtures.selected,
    //   changeList: Fixtures.changeList,
    //   thumbnail: Fixtures.thumbnail,
    //   startPage: Fixtures.startPage
    // }
    store = new Vuex.Store({
      getters,
      actions
    })

    options = {
      computed: {
        orderChanged: function () {
          return getters.orderChanged
        },
        isDisabled: function () {
          if (getters.stateChanged) {
            return false
          } else {
            return true
          }
        },
        // fileSetPayload: function () {
        //   var changed = state.images.filter(image => state.changeList.indexOf(image.id) !== -1 )
        //   var payload = changed.map((file) => {
        //     return {id: file.id, title: file.label, page_type: file.page_type }
        //   })
        //   return payload
        // }
      }
    }
  })

  it('will not allow save when nothing has changed', () => {
    const wrapper = mount(Controls, { options, store, localVue })
    wrapper.find('#save_btn').trigger('click')
    expect(actions.saveState).not.toHaveBeenCalled()
  })

  // todo: make sure saveState button can be tested
  // it('allows save once something has changed', () => {
  //   getters = {
  //     orderChanged: () => true,
  //     stateChanged: () => true
  //   }
  //   store = new Vuex.Store({
  //     getters,
  //     actions
  //   })
  //   const wrapper = mount(Controls, { options, store, localVue })
  //   console.log(wrapper.vm.isDisabled) // false
  //   wrapper.find('#save_btn').trigger('click')
  //   expect(actions.saveState).toHaveBeenCalled() // why isn't it called?
  // })

  it('has the expected html structure', () => {
    const wrapper = mount(Controls, { options, store, localVue })
    expect(wrapper.element).toMatchSnapshot()
  })

})
