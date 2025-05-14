# Comprehensive SAP BTP CAPM Interview Guide

## Fundamentals

**1. What is SAP BTP CAPM and what are its key components?**

SAP BTP CAPM (Business Technology Platform Cloud Application Programming Model) is a framework for building enterprise-grade services and applications on the SAP Business Technology Platform. It's designed to simplify and accelerate the development of cloud applications.

Key components include:
- **CDS (Core Data Services)**: Domain modeling language and infrastructure
- **Service modules**: For exposing data models as APIs (typically OData or REST)
- **Runtime environment**: Node.js and Java runtime environments
- **Persistence layer**: For connecting to databases like SAP HANA, PostgreSQL, etc.
- **Service SDK**: Provides programming model and APIs for service implementation
- **Project templates**: Pre-defined structures for rapid application development
- **CLI tools**: Command-line tools for development, testing, and deployment tasks

**2. How does CAPM differ from traditional SAP application development?**

CAPM differs from traditional SAP development in several significant ways:
- **Cloud-native approach**: Built specifically for cloud deployment versus on-premises
- **Microservices architecture**: Modular services instead of monolithic applications
- **Modern tech stack**: Uses Node.js, JavaScript/TypeScript, and modern Java versus ABAP
- **Declarative programming**: Uses CDS models to generate code instead of writing everything manually
- **DevOps friendly**: Designed for continuous integration/deployment pipelines
- **API-first design**: Emphasizes service interfaces from the beginning
- **Multi-cloud compatibility**: Can run on various cloud platforms, not just SAP data centers
- **Open-source compatibility**: Better integration with open-source libraries and frameworks

**3. Explain the core principles of CAPM's multi-target application approach.**

CAPM's multi-target application (MTA) approach is based on these core principles:
- **Modularity**: Applications are broken down into separate modules with specific responsibilities
- **Declarative deployment**: The `mta.yaml` file declaratively defines all modules and their dependencies
- **Environment independence**: Applications can be deployed to multiple environments with minimal changes
- **Resource definition**: External services and resources are defined abstractly and bound at deployment time
- **Build-time vs. runtime separation**: Clear distinction between build configuration and runtime behavior
- **Dependency management**: Explicit management of dependencies between modules
- **Cross-module references**: Modules can reference resources provided by other modules
- **Environment-specific configuration**: Parameters can be customized for different deployment targets

**4. What are the advantages of using CAPM for cloud application development?**

Key advantages include:
- **Reduced boilerplate code**: CDS models generate much of the repetitive code
- **Standardized approach**: Consistent structure across projects improves maintainability
- **Faster development**: Pre-built templates and components accelerate development
- **Built-in best practices**: Security, authentication, and other crucial aspects are handled by the framework
- **Simplified data modeling**: CDS provides a powerful yet accessible way to model domain entities
- **Automatic API generation**: OData/REST APIs are generated automatically from CDS models
- **Future-proof design**: Compatible with SAP's strategic direction for cloud development
- **Extensibility**: Designed to allow extensions and customizations to standard applications
- **Integration capabilities**: Easy integration with other SAP services and solutions

## Technical Knowledge

**5. What is CDS (Core Data Services) and how is it used in CAPM?**

CDS (Core Data Services) is a domain-specific language used for defining and consuming data models in CAPM. It's a central part of the framework that serves several purposes:

- **Data modeling**: Defines entities, their properties, relationships, and constraints
- **Service definition**: Exposes entities as APIs with specific capabilities
- **Query language**: Provides a way to query and manipulate data
- **Code generation**: Auto-generates database schemas, OData services, and UI annotations
- **Extensibility**: Allows for extending and customizing existing models

In CAPM, CDS files (`.cds`) define the data model schema, service interfaces, and annotations. These definitions are then compiled into database artifacts, service implementations, and client-side code as needed.

Example of a simple CDS model:
```cds
namespace com.example;

entity Products {
  key ID : UUID;
  name : String(100);
  description : String(1000);
  price : Decimal(10,2);
  currency : String(3);
  stock : Integer;
  supplier : Association to Suppliers;
}

entity Suppliers {
  key ID : UUID;
  name : String(100);
  address : String(200);
  products : Association to many Products on products.supplier = $self;
}
```

**6. Explain the role of service definitions and service implementations in CAPM.**

In CAPM, service architecture is split into two main parts:

**Service definitions**:
- Declared in CDS files using the `service` keyword
- Define the contract/API that clients will interact with
- Specify which entities are exposed and what operations are allowed
- Include annotations for documentation, validation, and UI generation
- Are protocol-independent (can be exposed as OData, REST, etc.)

Example service definition:
```cds
service ProductService {
  entity Products as projection on my.Products;
  entity Suppliers as projection on my.Suppliers;
}
```

**Service implementations**:
- Typically written in JavaScript/TypeScript (Node.js) or Java
- Provide the actual business logic behind service operations
- Can override default CRUD behavior generated from CDS models
- Implement custom validations, calculations, and workflows
- Handle integration with external systems
- Manage transactions and error handling

Example service implementation:
```javascript
module.exports = (srv) => {
  srv.before('CREATE', 'Products', async (req) => {
    // Custom validation logic
    if (req.data.price <= 0) {
      req.error(400, 'Product price must be greater than zero');
    }
  });
  
  srv.on('calculateTax', async (req) => {
    // Custom action implementation
    const product = await srv.read('Products', req.data.productId);
    return { tax: product.price * 0.19 };
  });
}
```

**7. How do you define data models in CAPM?**

Data models in CAPM are defined using CDS (Core Data Services) syntax, typically in `.cds` files. The process involves:

1. **Creating entity definitions**: Define the core data structures with their properties
2. **Establishing relationships**: Define associations between entities
3. **Adding constraints**: Apply validations, default values, and other constraints
4. **Setting up namespaces**: Organize models in logical namespaces
5. **Defining types**: Create reusable types and aspects (reusable property groups)
6. **Adding annotations**: Enhance models with metadata for UI, validation, etc.

Example of a comprehensive data model:

```cds
namespace com.example.bookshop;

using { Currency, managed, cuid } from '@sap/cds/common';

entity Books : cuid, managed {
  title        : localized String(111);
  description  : localized String(1111);
  price        : Decimal(9,2);
  currency     : Currency;
  stock        : Integer;
  author       : Association to Authors;
  orders       : Association to many OrderItems on orders.book = $self;
}

entity Authors : cuid {
  name         : String(111);
  dateOfBirth  : Date;
  books        : Association to many Books on books.author = $self;
}

entity Orders : cuid, managed {
  customer     : String(111);
  items        : Composition of many OrderItems on items.order = $self;
  status       : String(1) enum {
    New = 'N';
    Processing = 'P';
    Delivered = 'D';
    Cancelled = 'X';
  };
}

entity OrderItems {
  key order    : Association to Orders;
  key book     : Association to Books;
  quantity     : Integer;
}
```

**8. Describe the purpose and structure of the `mta.yaml` file.**

The `mta.yaml` file is a descriptor for Multi-Target Applications in SAP BTP. It:

- Defines the entire application and its components
- Specifies dependencies between modules
- Declares required resources and services
- Configures build and deployment parameters
- Manages environment-specific configurations

Structure of an `mta.yaml` file:

```yaml
ID: my-application
version: 1.0.0
_schema-version: '3.1'

parameters:
  enable-parallel-deployments: true

build-parameters:
  before-all:
    - builder: custom
      commands:
        - npm install
        - npm run build

modules:
  - name: my-application-db
    type: hdb
    path: db
    parameters:
      buildpack: nodejs_buildpack
    requires:
      - name: my-application-db-hdi-container

  - name: my-application-srv
    type: nodejs
    path: srv
    parameters:
      buildpack: nodejs_buildpack
    provides:
      - name: srv-api
        properties:
          srv-url: ${default-url}
    requires:
      - name: my-application-db-hdi-container
      - name: my-application-uaa

resources:
  - name: my-application-db-hdi-container
    type: com.sap.xs.hdi-container
    parameters:
      service: hana
      service-plan: hdi-shared
      
  - name: my-application-uaa
    type: org.cloudfoundry.managed-service
    parameters:
      service: xsuaa
      service-plan: application
      path: ./xs-security.json
```

**9. How do you handle authentication and authorization in CAPM applications?**

Authentication and authorization in CAPM applications are typically managed through:

**Authentication**:
- Integration with SAP Authorization and Trust Management service (XSUAA)
- Configuration in `xs-security.json` file for role definitions
- Use of JSON Web Tokens (JWT) for user identity
- Support for various authentication flows (OAuth 2.0, SAML, etc.)
- Authentication handled by the application router (approuter)

**Authorization**:
- Role-based access control through XSUAA roles and role collections
- Scope checks for service operations
- Restriction of data access through instance-based authorization
- CDS annotations for defining authorization requirements

Example of authorization in CDS:
```cds
@requires: 'authenticated-user'
service RestrictedService {
  @requires: 'Admin'
  entity SensitiveData as projection on db.SensitiveTable;
  
  @readonly
  @requires: ['Reader', 'Viewer']
  entity Reports as projection on db.ReportTable;
}
```

Example of role configuration in `xs-security.json`:
```json
{
  "xsappname": "my-application",
  "tenant-mode": "dedicated",
  "scopes": [
    {
      "name": "$XSAPPNAME.Admin",
      "description": "Admin access"
    },
    {
      "name": "$XSAPPNAME.Reader",
      "description": "Read access"
    }
  ],
  "role-templates": [
    {
      "name": "AdminRole",
      "description": "Administrator",
      "scope-references": [
        "$XSAPPNAME.Admin"
      ]
    },
    {
      "name": "ReaderRole",
      "description": "Reader",
      "scope-references": [
        "$XSAPPNAME.Reader"
      ]
    }
  ]
}
```

**10. Explain the difference between synchronous and asynchronous service calls in CAPM.**

**Synchronous service calls**:
- Block execution until the operation completes
- Follow a request-response pattern
- Simpler to implement and understand
- Used for operations that need immediate results
- Can cause performance issues for long-running operations
- Implemented as direct function calls or REST/OData calls that await responses

Example of synchronous service call:
```javascript
// Synchronous call in service implementation
srv.on('getOrder', async (req) => {
  const { orderId } = req.data;
  const order = await srv.read('Orders').where({ ID: orderId });
  return order;
});
```

**Asynchronous service calls**:
- Don't block execution while waiting for completion
- Use callbacks, events, or message queues
- Better for long-running operations
- Improve application responsiveness
- More complex to implement and debug
- Often used for background processing and integration scenarios

Example of asynchronous service call:
```javascript
// Asynchronous processing using events
srv.on('createOrder', async (req) => {
  const order = req.data;
  // Save the order first
  const result = await srv.create('Orders').entries(order);
  
  // Then trigger asynchronous processing via an event
  srv.emit('OrderCreated', { orderId: result.ID });
  
  // Return immediately without waiting for processing to complete
  return { orderId: result.ID, status: 'processing' };
});

// Handle the event asynchronously
srv.on('OrderCreated', async (event) => {
  const { orderId } = event.data;
  // Perform long-running operations
  await performInventoryCheck(orderId);
  await notifyWarehouse(orderId);
  await updateOrderStatus(orderId, 'ready');
});
```

## Practical Experience

**11. What are the common CAPM project directory structures and what is their purpose?**

A typical CAPM project follows a standardized directory structure:

- **`/app`**: Contains UI applications (optional)
  - Front-end resources like SAPUI5/Fiori elements applications
  - HTML, JavaScript, and CSS files
  - UI5 manifests and component configurations

- **`/db`**: Database artifacts
  - CDS data models (schema definitions)
  - Database-specific configurations
  - Migration scripts
  - Initial data for seeding the database (CSV files)

- **`/srv`**: Service layer
  - Service definitions in CDS
  - Service implementations in JavaScript/TypeScript or Java
  - Custom handlers and logic
  - Integration with external systems

- **`/test`**: Test resources
  - Unit and integration tests
  - Test data and configurations
  - Mock services for testing

- **`/mta.yaml`**: Multi-target application descriptor
  - Defines modules, resources, and dependencies

- **`/package.json`**: Node.js package configuration
  - Project metadata
  - Dependencies
  - Scripts for build, test, and deployment

- **`/xs-security.json`**: Security configuration
  - Authentication settings
  - Role definitions
  - Authorization scopes

This structure separates concerns, making the application more maintainable and easier to understand for developers familiar with the CAPM framework.

**12. How do you deploy a CAPM application to SAP BTP?**

Deploying a CAPM application to SAP BTP typically involves these steps:

1. **Prepare the application**:
   - Ensure all dependencies are properly configured in package.json
   - Create or update the mta.yaml file with all modules and resources
   - Configure xs-security.json for authentication and authorization

2. **Build the MTA archive**:
   - Use the MTA build tool: `mbt build`
   - This creates an .mtar file (MTA archive) containing all application components

3. **Deploy using the MultiApps CF CLI plugin**:
   - Ensure you're logged into CF: `cf login`
   - Deploy using: `cf deploy <your-app-name>.mtar`
   - The plugin handles deploying all modules in the correct order, respecting dependencies

4. **Monitor deployment**:
   - Check deployment status with: `cf mtas` or `cf services`
   - Troubleshoot using: `cf logs <app-name> --recent`

5. **Post-deployment configuration**:
   - Assign role collections to users
   - Configure destinations if needed
   - Set up additional monitoring or logging

Example commands:
```bash
# Build the MTA archive
mbt build

# Login to Cloud Foundry
cf login -a https://api.cf.eu10.hana.ondemand.com

# Deploy the application
cf deploy mta_archives/my-application_1.0.0.mtar

# Check deployment status
cf apps
cf services
```

**13. Describe how you would implement custom handlers for your service operations.**

Custom handlers in CAPM allow you to implement business logic for your service operations. The implementation differs slightly between Node.js and Java, but the concept is similar:

**Node.js implementation**:

1. **Create a service implementation file** that corresponds to your service definition.
2. **Export a function** that accepts the service object.
3. **Register event handlers** for various operations using `srv.on`, `srv.before`, or `srv.after`.

```javascript
// srv/cat-service.js
module.exports = (srv) => {
  // Handle CRUD operations
  srv.before('CREATE', 'Books', validateBook);
  srv.after('READ', 'Books', enrichBookData);
  
  // Handle custom actions
  srv.on('orderBook', placeOrder);
  
  // Implementation functions
  async function validateBook(req) {
    const { title, price } = req.data;
    if (!title) req.error(400, 'Book title is required');
    if (price <= 0) req.error(400, 'Price must be positive');
  }
  
  async function enrichBookData(books, req) {
    return books.map(book => {
      book.availability = book.stock > 0 ? 'Available' : 'Out of stock';
      return book;
    });
  }
  
  async function placeOrder(req) {
    const { bookId, quantity } = req.data;
    const tx = srv.transaction(req);
    
    // Check inventory
    const book = await tx.read('Books', bookId);
    if (book.stock < quantity) {
      return req.error(400, 'Not enough books in stock');
    }
    
    // Create order
    const order = await tx.create('Orders').entries({
      book_ID: bookId,
      quantity: quantity,
      status: 'New'
    });
    
    // Update stock
    await tx.update('Books', bookId).set({
      stock: { '-=': quantity }
    });
    
    return { orderId: order.ID };
  }
}
```

**Java implementation**:

1. **Create a service class** with `@Service` annotation.
2. **Define handler methods** annotated with event annotations.

```java
@Service
public class CatalogServiceHandler {

    @Autowired
    private PersistenceService db;

    @Before(event = CdsService.EVENT_CREATE, entity = "CatalogService.Books")
    public void validateBookBeforeCreate(Books book) {
        if (book.getTitle() == null || book.getTitle().isEmpty()) {
            throw new ServiceException(ErrorStatuses.BAD_REQUEST, "Book title is required");
        }
        if (book.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new ServiceException(ErrorStatuses.BAD_REQUEST, "Price must be positive");
        }
    }

    @After(event = CdsService.EVENT_READ, entity = "CatalogService.Books")
    public void enrichBookData(List<Books> books) {
        books.forEach(book -> {
            book.setAvailability(book.getStock() > 0 ? "Available" : "Out of stock");
        });
    }

    @On(entity = "CatalogService.orderBook")
    public Result placeOrder(OrderBookContext context) {
        String bookId = context.getBookId();
        int quantity = context.getQuantity();
        
        // Check inventory
        Books book = db.run(Select.from("CatalogService.Books").where(b -> b.ID().eq(bookId))).single(Books.class);
        if (book.getStock() < quantity) {
            throw new ServiceException(ErrorStatuses.BAD_REQUEST, "Not enough books in stock");
        }
        
        // Create order and update stock
        // ...
        
        return Result.success().withMessage("Order placed successfully");
    }
}
```

**14. How do you integrate with external systems or APIs from a CAPM application?**

Integrating with external systems in CAPM applications can be done through several approaches:

**1. Using Destination Service**:
- Configure destinations in SAP BTP cockpit
- Use the destination service to access the configured endpoints
- Handles authentication and connectivity automatically

```javascript
const { executeHttpRequest } = require('@sap-cloud-sdk/core');

module.exports = (srv) => {
  srv.on('getExternalData', async (req) => {
    try {
      const response = await executeHttpRequest(
        { destinationName: 'MY_API_DESTINATION' },
        { method: 'GET', url: '/api/data' }
      );
      return response.data;
    } catch (error) {
      req.error(500, `Error fetching external data: ${error.message}`);
    }
  });
}
```

**2. Direct HTTP requests**:
- Use libraries like axios or node-fetch for direct API calls
- Manage authentication and error handling manually

```javascript
const axios = require('axios');

module.exports = (srv) => {
  srv.on('getWeatherData', async (req) => {
    try {
      const { city } = req.data;
      const response = await axios.get(
        `https://weather-api.example.com/data?city=${encodeURIComponent(city)}`,
        { headers: { 'API-Key': process.env.WEATHER_API_KEY } }
      );
      return response.data;
    } catch (error) {
      req.error(500, `Weather API error: ${error.message}`);
    }
  });
}
```

**3. Using SAP Cloud SDK**:
- Leverage the SAP Cloud SDK for SAP-specific system integration
- Use OData clients for SAP S/4HANA or other SAP systems

```javascript
const { businessPartnerService } = require('@sap/cloud-sdk-vdm-business-partner-service');

module.exports = (srv) => {
  srv.on('getBusinessPartners', async (req) => {
    try {
      const businessPartners = await businessPartnerService
        .requestBuilder()
        .getAll()
        .filter(businessPartnerService.schema.BUSINESS_PARTNER_CATEGORY.equals('1'))
        .top(50)
        .execute({ destinationName: 'S4HANA_SYSTEM' });
        
      return businessPartners;
    } catch (error) {
      req.error(500, `Error fetching business partners: ${error.message}`);
    }
  });
}
```

**4. Message-based integration**:
- Use SAP Event Mesh or similar services for asynchronous integration
- Publish and subscribe to events for loosely coupled systems

```javascript
const messaging = require('@sap/xb-msg-amqp-v100');

module.exports = (srv) => {
  // Initialize messaging client
  const messagingClient = new messaging.MessagingClient({ ...config });
  
  // Set up a message handler
  messagingClient.onMessage('orders/new', async (message) => {
    const order = JSON.parse(message.getData().toString());
    await srv.create('Orders').entries(order);
  });
  
  // Publish a message
  srv.after('CREATE', 'Orders', async (order, req) => {
    const message = { orderID: order.ID, status: 'created' };
    await messagingClient.publishMessage('orders/created', JSON.stringify(message));
  });
}
```

**15. Explain how to implement OData V4 services using CAPM.**

Implementing OData V4 services in CAPM is straightforward because CAPM generates OData services automatically from CDS models. Here's how it works:

**1. Define your data model in CDS**:
```cds
namespace com.example;

entity Products {
  key ID : UUID;
  name : String(100);
  description : String(1000);
  price : Decimal(10,2);
  supplier : Association to Suppliers;
}

entity Suppliers {
  key ID : UUID;
  name : String(100);
  products : Association to many Products on products.supplier = $self;
}
```

**2. Create a service definition exposing the entities**:
```cds
service CatalogService @(path: '/catalog') {
  entity Products as projection on com.example.Products;
  entity Suppliers as projection on com.example.Suppliers;
}
```

**3. Implement custom logic (optional)**:
```javascript
module.exports = (srv) => {
  // Custom handlers as needed
  srv.before('READ', 'Products', (req) => {
    console.log('Reading products');
  });
}
```

**4. Configure OData specifics with annotations**:
```cds
service CatalogService @(
  path: '/catalog',
  requires: 'authenticated-user',
  impl: './cat-service.js'
) {
  entity Products @(
    // OData capabilities
    Capabilities.DeleteRestrictions.Deletable: false,
    Capabilities.InsertRestrictions.Insertable: true,
    // OData navigation properties
    Common.SemanticKey: [ID, name]
  ) as projection on com.example.Products;
  
  entity Suppliers as projection on com.example.Suppliers;
  
  // Define OData actions and functions
  action orderProduct(productId: UUID, quantity: Integer) returns {
    orderId: UUID;
    status: String;
  };
  
  function getProductAvailability(productId: UUID) returns {
    available: Boolean;
    stock: Integer;
  };
}
```

**5. Run your service**:
OData V4 endpoints are automatically generated when you start your service:
```bash
cds run
```

**Key OData V4 features supported by CAPM**:
- CRUD operations on entities
- Query options ($select, $filter, $expand, etc.)
- Batch processing
- Entity relationships and navigation
- Actions and functions
- Metadata document (service capabilities)
- Advanced queries (aggregation, grouping)
- Change tracking with ETags

**OData V4 endpoints generated by CAPM**:
- Entity sets: `/catalog/Products`, `/catalog/Suppliers`
- Individual entities: `/catalog/Products(ID)`
- Navigation properties: `/catalog/Products(ID)/supplier`
- Functions: `/catalog/getProductAvailability(productId=...)`
- Actions: `/catalog/orderProduct` (via POST)
- Metadata: `/catalog/$metadata`

## Troubleshooting & Best Practices

**16. What are common challenges when developing with CAPM and how do you address them?**

Common challenges in CAPM development and their solutions include:

**1. Complex data modeling**:
- *Challenge*: Creating and maintaining complex data models with many entities and relationships
- *Solution*: Use CDS aspects and compositions to create reusable components; break models into logical namespaces; leverage annotations for documentation

**2. Authentication and authorization issues**:
- *Challenge*: Implementing proper security controls and debugging access problems
- *Solution*: Use SAP BTP security tools to trace authentication; implement role checks early; test with different user roles; use proper scopes in xs-security.json

**3. Deployment failures**:
- *Challenge*: MTA deployment can fail for various reasons
- *Solution*: Check logs carefully; use `cf logs APP_NAME --recent`; ensure services exist; check quota limitations; validate mta.yaml for syntax errors

**4. Database migration issues**:
- *Challenge*: Schema changes can cause deployment failures or data loss
- *Solution*: Use database evolution tools; create proper migration scripts; test migrations in non-production environments first

**5. Performance problems**:
- *Challenge*: Slow queries or high resource usage
- *Solution*: Add database indexes; optimize CDS queries; implement pagination; use caching strategies; monitor with SAP BTP monitoring tools

**6. Integration complexity**:
- *Challenge*: Connecting to external systems securely
- *Solution*: Use destination service; implement proper error handling and retry logic; create mock services for testing

**7. Dependency management**:
- *Challenge*: Managing npm package dependencies and version conflicts
- *Solution*: Use package-lock.json; specify exact versions; regularly update dependencies; test thoroughly after updates

**8. Testing challenges**:
- *Challenge*: Testing services with complex dependencies
- *Solution*: Use mock services; implement comprehensive unit and integration tests; create test data generators

**9. Learning curve**:
- *Challenge*: CAPM has many components and concepts to learn
- *Solution*: Start with sample applications; use SAP tutorials; join community forums; attend training sessions

**10. Local development setup**:
- *Challenge*: Setting up a complete local development environment
- *Solution*: Use SAP Business Application Studio for cloud development; configure proper local profiles for different databases; use Docker for local services

**17. Describe your approach to testing CAPM applications.**

A comprehensive testing approach for CAPM applications includes:

**1. Unit Testing**:
- Test individual components and functions in isolation
- Mock external dependencies and services
- Use frameworks like Jest or Mocha for Node.js services
- Focus on business logic rather than framework-generated code

```javascript
// Example unit test for a service handler
const { expect } = require('chai');
const sinon = require('sinon');

describe('Book service handlers', () => {
  let srv, mockDb;
  
  beforeEach(() => {
    mockDb = {
      read: sinon.stub().resolves([{ ID: '1', stock: 10 }]),
      create: sinon.stub().resolves({ ID: '999' }),
      update: sinon.stub().resolves()
    };
    
    srv = {
      on: (event, handler) => {
        srv[event] = handler;
      },
      read: mockDb.read,
      create: mockDb.create,
      update: mockDb.update,
      transaction: () => mockDb
    };
    
    require('../srv/cat-service')(srv);
  });
  
  it('should validate book price is positive', async () => {
    const req = {
      data: { title: 'Test Book', price: -10 },
      error: sinon.spy()
    };
    
    await srv['before_CREATE_Books'](req);
    expect(req.error.called).to.be.true;
    expect(req.error.args[0][0]).to.equal(400);
  });
  
  it('should successfully place an order when stock is available', async () => {
    const req = {
      data: { bookId: '1', quantity: 2 },
      error: sinon.spy()
    };
    
    const result = await srv['orderBook'](req);
    expect(result).to.have.property('orderId');
    expect(mockDb.update.called).to.be.true;
  });
});
```

**2. Integration Testing**:
- Test the interaction between multiple components
- Connect to in-memory or test databases
- Verify that CDS models and service implementations work together
- Test the full request-response cycle

```javascript
const cds = require('@sap/cds');
const { expect } = require('chai');
const request = require('supertest');

describe('Catalog Service Integration', () => {
  let app, bookId;
  
  before(async () => {
    // Boot the service with an in-memory database
    app = await cds.test('srv').in-memory();
    
    // Seed test data
    const catalogService = await cds.connect.to('CatalogService');
    const result = await catalogService.create('Books').entries({
      title: 'Test Book',
      stock: 10,
      price: 29.99
    });
    bookId = result.ID;
  });
  
  it('should return books with proper fields', async () => {
    const response = await request(app)
      .get('/catalog/Books')
      .set('Accept', 'application/json')
      .expect(200);
      
    expect(response.body.value).to.be.an('array');
    expect(response.body.value[0]).to.have.properties(['ID', 'title', 'price']);
  });
  
  it('should process the orderBook action correctly', async () => {
    const response = await request(app)
      .post('/catalog/orderBook')
      .send({ bookId: bookId, quantity: 2 })
      .set('Content-Type', 'application/json')
      .expect(200);
      
    expect(response.body).to.
