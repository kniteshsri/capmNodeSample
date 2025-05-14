using my.sample from '../db/schema';

service CatalogService {
    entity Products as projection on sample.Products;
    entity Orders as projection on sample.Orders;
    entity OrderItems as projection on sample.OrderItems;
}