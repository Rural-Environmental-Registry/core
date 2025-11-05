# Car Registration API Documentation

## Base URL
```
/v1
```

## Admin API (`/v1/admin`)

### Attribute Sets
- **GET** `/attributesets` - Get all attribute sets
- **POST** `/attributesets` - Create new attribute set
  - Body: `AttributeSetReq`

### Attribute Types
- **GET** `/attributetypes` - Get all attribute types

### Attribute Definitions
- **GET** `/attributedefinitions` - Get all attribute definitions
- **POST** `/attributedefinitions` - Create new attribute definition
  - Body: `AttributeDefinitionReq`

### Application Info
- **GET** `/app-info` - Get application information

## Property API (`/v1/properties`)

### Properties Management
- **GET** `/` - Get properties with filters and pagination
  - Query params: `PropertyFilter`, `Pageable`
- **GET** `/{id}` - Get property by ID
- **POST** `/` - Create new property
  - Content-Type: `multipart/form-data`
  - Parts: `property` (PropertyReq), `mapImage` (optional file)
- **PUT** `/{id}` - Update existing property
  - Content-Type: `multipart/form-data`
  - Parts: `property` (PropertyReq), `mapImage` (optional file)

### Property Resources
- **GET** `/{id}/image` - Get property image
- **GET** `/{id}/receipt` - Generate property receipt PDF
  - Query param: `locationZone` (required)

## User API (`/v1/users`)

### User Management
- **GET** `/` - Get all users
- **GET** `/{id}` - Get user by ID
- **GET** `/keycloak/{idKeycloak}` - Get user by Keycloak ID
- **POST** `/` - Create new user
  - Body: `UserReq`
- **PUT** `/{id}` - Update user by ID
  - Body: `UserReq`
- **PUT** `/keycloak/{idKeycloak}` - Update user by Keycloak ID
  - Body: `UserReq`
- **DELETE** `/{id}` - Delete user

## Calculation API (`/v1/calculations`)

### Calculations
- **POST** `/execute` - Execute calculation
  - Body: `CalculationEngineReq`

## Response Formats

All endpoints return JSON unless specified otherwise.

### Common Response Types
- `PagedRes<T>` - Paginated response wrapper
- `PropertyRes` - Property response object
- `UserRes` - User response object
- `AttributeSetRes` - Attribute set response object
- `AttributeDefinitionRes` - Attribute definition response object

### HTTP Status Codes
- `200` - Success
- `400` - Bad Request
- `404` - Not Found
- `500` - Internal Server Error