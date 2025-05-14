module.exports = async (srv) => {
    const { Orders } = srv.entities;

    srv.before( 'CREATE', Orders, async (req) => {
        req.data.orderDate = new Date().toISOString();
    });
    srv.on('placeOrder', async (req) => {
        return { message: 'Order Placed Successfully' };
    });
}