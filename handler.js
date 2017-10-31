const rp = require('request-promise')

module.exports.hello = (event, context, callback) => {
  rp('http://ifconfig.io/ip').then((ip) => {
    callback(null, { statusCode: 200, body: ip })
  }).catch((e) => {
    console.log('error', e)
    callback(e, null)
  })
};
