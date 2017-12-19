import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)
import actions from '@/store/vuex/actions'

describe('actions', () => {
  let store
  let saveStateMock
  beforeEach(() => {
    saveStateMock = jest.fn()
    store = new Vuex.Store({
      state: { data: {} },
      mutations: {
        SAVE_STATE: saveStateMock
      },
      actions: {
        saveState: actions.saveState
      }
    })
  })
  it('tests using a mock mutation but real store', () => {
    store.hotUpdate({
      mutations: { SAVE_STATE: saveStateMock }
    })
    return store.dispatch('saveState')
      .then((res) => {
        expect(saveStateMock.mock.calls[0][1])
          .toEqual({ title: 'Mock with Jest' })
        expect(setDataMock.mock.calls).toHaveLength(1)
      })
  })
})
