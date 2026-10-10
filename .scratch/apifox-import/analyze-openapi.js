const fs = require('fs');
const path = require('path');

const dir = process.argv[2] || __dirname;

function analyze(file) {
  const raw = fs.readFileSync(path.join(dir, file), 'utf8');
  let doc;
  try {
    doc = JSON.parse(raw);
  } catch (e) {
    return { file, error: String(e) };
  }
  const paths = doc.paths || {};
  const methods = ['get', 'post', 'put', 'patch', 'delete', 'head', 'options', 'trace'];
  let operations = 0;
  let writes = 0;
  let withBody = 0;
  let emptyObjectBodies = 0;
  const tags = new Set();
  const qianchuan = [];
  for (const [p, item] of Object.entries(paths)) {
    for (const m of methods) {
      const op = item[m];
      if (!op) continue;
      operations += 1;
      (op.tags || []).forEach((t) => tags.add(t));
      if (p.includes('/qianchuan') || (op.tags || []).some((t) => String(t).includes('千川'))) {
        qianchuan.push(`${m.toUpperCase()} ${p}`);
      }
      if (['post', 'put', 'patch'].includes(m)) {
        writes += 1;
        const rb = op.requestBody;
        if (rb) {
          withBody += 1;
          const content = rb.content || {};
          const first = content['application/json'] || content['application/*+json'] || Object.values(content)[0] || {};
          const schema = first.schema;
          const emptyObject =
            schema &&
            schema.type === 'object' &&
            (!schema.properties || Object.keys(schema.properties).length === 0) &&
            !schema.$ref &&
            !schema.allOf;
          if (emptyObject) emptyObjectBodies += 1;
        }
      }
    }
  }
  const schemas = Object.keys((doc.components && doc.components.schemas) || {}).length;
  return {
    file,
    title: doc.info && doc.info.title,
    openapi: doc.openapi,
    paths: Object.keys(paths).length,
    operations,
    schemas,
    writes,
    withBody,
    emptyObjectBodies,
    bodyCoverage: writes ? Number(((withBody / writes) * 100).toFixed(1)) : null,
    tags: [...tags].sort(),
    qianchuanCount: qianchuan.length,
    qianchuan: qianchuan.sort(),
  };
}

for (const f of ['openapi-full.json', 'openapi-business.json', 'openapi-support.json']) {
  console.log(JSON.stringify(analyze(f), null, 2));
}
