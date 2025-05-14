namespace my.sample;

entity Products {
  key ID    : Integer;
      name  : String;
      price : Decimal(10,2);
}

entity Orders {
  key ID        : UUID;
      orderDate : DateTime;
      items     : Association to many OrderItems on items.order = $self;
}

entity OrderItems {
  key ID      : Integer;
      order   : Association to Orders;
      product : Association to Products;
      quantity : Integer;
}