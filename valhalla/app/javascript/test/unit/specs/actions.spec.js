import actions from '@/store/vuex/actions'
import state from '@/store/vuex/state'

jest.mock('axios');

describe('actions', () => {
  it('loadImageCollection', () => {
    let data
    let mockCommit = (state, payload) => {
      data = payload
    }
    actions.loadImageCollection({ commit: mockCommit })
      .then(() => {
         expect(data.id).toBe('foo')
      })
  })
})
