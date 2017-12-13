import Vue from 'vue'
import Vuex from 'vuex'
import { shallow, createLocalVue } from 'vue-test-utils'
import Detail from '@/components/Thumbnails'
const localVue = createLocalVue()
localVue.use(Vuex)

describe('Thumbnails.vue', () => {
  let cmp

  beforeEach(() => {
    cmp = mount(Thumbnails, {
      computed: {
        thumbnails: {
          get () {
            return this.$store.state.images
          },
          set (value) {
            this.$store.dispatch('sortImages', value)
          }
        }
      },
      localVue
    })
  })

  it('renders a $store.state value return from computed', () => {
    expect(cmp.find('#detail_img').html()).toEqual('<img id="detail_img" src="http://localhost:3000/image-service/50b5e49b-ade7-4278-8265-4f72081f26a5/full/400,/0/default.jpg">')
  })

  it('has the expected html structure', () => {
    expect(cmp.element).toMatchSnapshot()
  })

  it('selectedImageUrl function has the expected value', () => {
    expect(cmp.vm.selectedImageUrl).toEqual("http://localhost:3000/image-service/50b5e49b-ade7-4278-8265-4f72081f26a5/full/400,/0/default.jpg")
  })

})
