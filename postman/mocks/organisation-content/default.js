// Methods, URLs and payload fields: kanoct15.postman_collection.json.
// Synthetic response fixtures: the collection supplies no saved responses.
const http = require('http');
let products = [];
let ads = [];
let inserted = false;
http.createServer(async (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  const reply = (status, value) => { res.writeHead(status); res.end(JSON.stringify(value)); };
  try {
    let body = '';
    for await (const chunk of req) body += chunk;
    const path = req.url.replace(/^\/(failure|malformed|reject-status|reject-nested|reject-rows|reject-text|noop|unreadable-after|empty-save|json-save)/, '');
    if (path === '/auth/login' && req.method === 'POST') {
      return reply(200, {access_token: 'expired-content-test', refresh_token: 'content-refresh', userInfo: {data: {user_id: 624}}});
    }
    if (path === '/auth/refresh-accesstoken' && req.method === 'POST') {
      return reply(200, {access_token: 'valid-content-test'});
    }
    if (req.headers.authorization !== 'Bearer valid-content-test') return reply(401, {});
    if (req.url.startsWith('/failure/')) return reply(503, {message: 'Unavailable'});
    if (req.url.startsWith('/malformed/')) return reply(200, {unexpected: true});
    if (path === '/test/reset') { products = []; ads = []; inserted = false; return reply(200, {}); }
    if (path === '/keyValue' && req.method === 'POST') {
      if (JSON.parse(body).requestName !== 'getAll_Product') return reply(400, {});
      return reply(200, [{value: 3, label: 'Rice'}, {value: 4, label: 'Tea'}]);
    }
    if (path === '/api/keyValue' && req.method === 'POST') {
      if (req.headers['x-app-id'] !== '1' || JSON.parse(body).requestName !== 'getAll_AdvType') return reply(400, {});
      return reply(200, [{value: 1, label: 'Event'}, {value: 2, label: 'Advertisement'}]);
    }
    if (path === '/master/organisationproduct/add' && req.method === 'POST') {
      const data = JSON.parse(body);
      if (data.f_organisation_id !== 2 || ![3, 4].includes(data.f_product_id) ||
          typeof data.product_price !== 'number' || !Number.isInteger(data.product_qty) ||
          data.product_price < 0 || data.product_qty < 0 || !data.product_desc) return reply(400, {});
      if (req.url.startsWith('/reject-status/')) return reply(200, {status: 500, message: 'Product insert failed: invalid organisation.'});
      if (req.url.startsWith('/reject-nested/')) return reply(200, {status: 200, data: {success: false, message: 'Product already exists.'}});
      if (req.url.startsWith('/reject-rows/')) return reply(200, {affectedRows: 0, message: 'No product was inserted.'});
      if (req.url.startsWith('/reject-text/')) { res.writeHead(200); return res.end('Product insert failed'); }
      if (req.url.startsWith('/noop/')) return reply(200, {status: 200, message: 'Added successfully'});
      products.push({...data, organisation_product_id: products.length + 1});
      inserted = true;
      if (req.url.startsWith('/empty-save/')) { res.writeHead(204); return res.end(); }
      if (req.url.startsWith('/json-save/')) return reply(200, {status: 200, message: 'Added successfully', data: {affectedRows: 1}});
      // Successful writes may return text instead of a JSON response.
      res.writeHead(201, {'Content-Type': 'text/plain'}); return res.end('Added successfully');
    }
    if ((path === '/master/organisationproduct/get/2' ||
         path === '/master/organisationproduct/getByOrganisation/2') && req.method === 'GET') {
      if (req.url.startsWith('/unreadable-after/') && inserted) return reply(503, {message: 'Read unavailable'});
      return reply(200, {data: products});
    }
    if (path.startsWith('/api/advertisements') && req.headers['x-app-id'] !== '1') return reply(400, {});
    if (path === '/api/advertisements' && req.method === 'POST') {
      const type = req.headers['content-type'] || '';
      if (!type.startsWith('multipart/form-data; boundary=')) return reply(400, {message: 'Multipart required'});
      const boundary = type.split('boundary=')[1].replaceAll('"', '');
      const fields = {};
      let image = false;
      for (const part of body.split(`--${boundary}`)) {
        const name = /name="([^"]+)"/.exec(part)?.[1];
        if (!name) continue;
        const content = part.split('\r\n\r\n').slice(1).join('\r\n\r\n').replace(/\r\n$/, '');
        if (name === 'advertisement_image') {
          image = /filename=".+"/.test(part) && /content-type: image\/png/i.test(part) && content.length > 0;
        } else fields[name] = content;
      }
      if (!image || !fields.advertisement_name || !fields.advertisement_desc ||
          fields.f_villageorganisation_id !== '2' || fields.f_villageapp_id !== '1' ||
          fields.f_adv_type_id !== '2' || fields.isexclusive !== 'false' ||
          !fields.start_date || fields.end_date < fields.start_date) return reply(400, {message: 'Invalid advertisement'});
      ads.push({...fields, villageadvertisement_id: ads.length + 1});
      return reply(201, {message: 'Added'});
    }
    const organisationAds = /^\/api\/advertisements\/getAdvertisementByOrganisation\/(\d+)$/.exec(path);
    if (organisationAds && req.method === 'GET') {
      const organisationId = organisationAds[1];
      return reply(200, {data: ads.filter(ad => ad.f_villageorganisation_id === organisationId)});
    }
    return reply(501, {message: 'Endpoint outside this simulation'});
  } catch (error) { reply(500, {message: error.message}); }
}).listen(process.env.PORT);
