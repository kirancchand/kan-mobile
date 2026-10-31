// GET/path/auth from the Service section of kanoct15.postman_collection.json.
// Service fields from the supplied example; tests cover both common envelopes.
const http = require('http');
const service = {service_id: 2, service: 'Online Library', shortform: 'library',
  description: 'Rent, buy & sell books peer-to-peer',
  icon: '        return AppIcons.bookOpen;\n', color: '0xFF326B65'};
http.createServer(async (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  if (req.method === 'POST' && req.url === '/auth/login') {
    return res.end(JSON.stringify({access_token:'expired-test', refresh_token:'refresh-test',
      userInfo:{data:{user_id:624}}}));
  }
  if (req.method === 'POST' && req.url === '/auth/refresh-accesstoken') {
    return res.end(JSON.stringify({access_token:'valid-test'}));
  }
  if (req.method === 'GET' && req.url.endsWith('/master/service/getAll')) {
    if (req.headers.authorization !== 'Bearer valid-test') {
      res.writeHead(401); return res.end('{}');
    }
    if (req.url.startsWith('/failure/')) {res.writeHead(503); return res.end('{}');}
    if (req.url.startsWith('/empty/')) return res.end('{"data":[]}');
    if (req.url.startsWith('/bare/')) return res.end(JSON.stringify([service]));
    return res.end(JSON.stringify({message:'Listed Successfully!!',status:200,data:[service]}));
  }
  res.writeHead(501); res.end('{}');
}).listen(process.env.PORT);
