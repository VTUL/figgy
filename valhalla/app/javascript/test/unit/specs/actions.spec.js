import actions from '@/store/vuex/actions'
import state from '@/store/vuex/state'

jest.mock('axios');

describe('actions', () => {
  it('loadImageCollection', () => {
    let data
    let resource = {"id":"9a25e0ce-4f64-4995-bae5-29140a453fa3","class_name":"ephemera_folders"}
    let mockCommit = (state, payload) => {
      data = payload
    }
    actions.loadImageCollection({ commit: mockCommit }, resource)
      .then(() => {
         expect(data.id).toBe('foo')
      })
  })
})
