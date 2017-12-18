import payload from "./mock-payload"
const axios = {
  get: () => new Promise(res => res(payload) )
}
export default axios
