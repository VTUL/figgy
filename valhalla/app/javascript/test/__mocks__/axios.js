import manifest from "./mock-manifest"

const axios = {
  get: () => new Promise(res => res({ data: manifest }) ),
  patch: () => { console.log('patch called'); new Promise(res => res({ status: 200 }) )}
}
export default axios
