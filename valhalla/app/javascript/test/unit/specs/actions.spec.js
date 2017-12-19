import actions from '@/store/vuex/actions'
import { body } from '@/test/fixtures/image-collection'

jest.mock('axios')

describe('actions', () => {
  it('loadImageCollection', () => {
    let data
    let resource = {"id":"9a25e0ce-4f64-4995-bae5-29140a453fa3","class_name":"ephemera_folders"}
    let mockCommit = (state, payload) => {
      data = payload
    }
    actions.loadImageCollection({ commit: mockCommit }, resource)
      .then(() => {
         expect(data.id).toBe('9a25e0ce-4f64-4995-bae5-29140a453fa3')
         expect(data.images.length).toBe(6)
      })
      .catch(
      (error) => {
        console.log(error);
      }
    )
  })

  // it('saveState', () => {
  //   let data
  //   console.log(body)
  //   let mockCommit = (state, payload) => {
  //     data = payload
  //   }
  //   actions.saveState({ commit: mockCommit }, body)
  //     .then(() => {
  //        console.log(data)
  //        expect(data).toBe('foo')
  //     })
  // })
})

// saveState (context, body) {
//   window.body = body
//   let errors = []
//   let token = document.getElementsByName('csrf-token')[0].getAttribute('content')
//
//   axios.defaults.headers.common['X-CSRF-Token'] = token
//   axios.defaults.headers.common['Accept'] = 'application/json'
//
//   let file_set_promises = []
//   for (let i = 0; i < body.file_sets.length; i++) {
//     file_set_promises.push(axios.patch('/concern/file_sets/' + body.file_sets[i].id, body.file_sets[i]))
//   }
//   let resourceClassNames = Object.keys(body.resource)
//   axios.patch('/concern/' + Pluralize.plural(resourceClassNames[0]) + '/' + body.resource[resourceClassNames[0]].id, body.resource).then((response) => {
//     axios.all(file_set_promises).then(axios.spread((...args) => {
//       context.commit('SAVE_STATE', [])
//     }, (err) => {
//       alert(errors.join('\n'))
//     }))
//   }, (err) => {
//     alert(errors.join('\n'))
//   })
// },
