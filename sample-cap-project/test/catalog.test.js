const cds = require('@sap/cds');
const { GET, POST, expect } = cds.test(__dirname + '/..');

describe('Catalog Service', () => {
  it('should serve Products', async () => {
    const { data } = await GET`/catalog/Products`;
    expect(data.value).to.be.an('array');
  });
});