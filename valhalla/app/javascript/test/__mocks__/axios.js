import manifest from "./mock-manifest"

const axios = {
  get: () => new Promise(res => res({ data: manifest }) )
}
export default axios

// const axios = {
//   get: () => new Promise(res => res({ data: 'Mock with Jest' }) )
// }
// export default axios
