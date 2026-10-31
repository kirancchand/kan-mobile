// Request methods/paths from kanoct15.postman_collection.json.
// Response fixtures assume the existing directory fields: no saved response
// examples exist for listOrganisationByUserId in the supplied collection.
const http = require('http');
let name = 'Member organisation';
http.createServer(async (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  let body = '';
  for await (const chunk of req) body += chunk;
  if (req.method === 'POST' && req.url === '/auth/login') {
    return res.end(JSON.stringify({access_token: 'simulation-only',
      user_id: 999, userInfo: {user_id: 998, data: {user_id: 624}}}));
  }
  if (req.method === 'POST' && req.url === '/master/organisation/listOrganisationByUserId/624') {
    if (body) { res.writeHead(400); return res.end('{}'); }
    return res.end(JSON.stringify({message: 'Listed Successfully!!', status: 200, data: [5, 6, 7].map((id) => ({
      organisation_id: id, organisation: id === 5 ? name : `Organisation ${id}`,
      f_user_id: 624, f_usertype_id: id, organisation_address: 'Village',
      organisation_type: {value: '1', label: 'School'}
    }))}));
  }
  if (req.method === 'PUT' && req.url === '/master/organisation/update/5') {
    const data = JSON.parse(body);
    if (data.organisation_id !== 5 || data.f_organisation_type_id !== 1 || 'ownerId' in data) {
      res.writeHead(400); return res.end('{}');
    }
    name = data.organisation;
    return res.end('{}');
  }
  res.writeHead(501); res.end('{}');
}).listen(process.env.PORT);
