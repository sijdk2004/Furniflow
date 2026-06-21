Document 00 – FurniFlow Master Architecture Index
Version: 1.0
Status: Master Governance Document
Platform:
FurniFlow Enterprise Platform
Purpose:
This document serves as the master index, governance framework, architecture map, and entry point for all FurniFlow platform documentation.
This document establishes:
•	Document hierarchy
•	Architecture ownership
•	Development governance
•	Document dependencies
•	Source-of-truth hierarchy
•	Architecture freeze rules
All future platform, industry pack, and client extension development shall reference this document.
________________________________________
1. Platform Vision
FurniFlow is a Multi-Tenant Enterprise Platform designed to support multiple industries through configurable Industry Packs.
Furniture Manufacturing is the first Industry Pack.
Future Industry Packs may include:
•	Garments Manufacturing
•	Steel Fabrication
•	Construction
•	Trading
•	Distribution
•	Service Businesses
The platform shall be built once and reused across industries.
________________________________________
2. Architecture Principles
The platform shall follow:
1.	Platform First
2.	Industry Pack Driven
3.	Multi-Tenant SaaS Ready
4.	API First
5.	RBAC Driven
6.	Configuration Over Customization
7.	Cloud Native
8.	Extensible Architecture
9.	Security By Design
10.	Audit By Default
________________________________________
3. Architecture Layers
Layer 1
Platform Core
________________________________________
Layer 2
Business Foundation
________________________________________
Layer 3
Industry Packs
________________________________________
Layer 4
Client Extensions
________________________________________
Architecture Flow:
Platform Core
→ Business Foundation
→ Industry Pack
→ Client Extension
________________________________________
4. Documentation Structure
The FurniFlow architecture repository shall follow:
00 Master Architecture Index
01 Enterprise Platform Architecture
02 Platform Data Architecture
02A Platform Module Registry
02B RBAC & Authorization Architecture
02C Navigation & Module Enablement Architecture
03 Furniture Industry Architecture
03A Module Catalog & Screen Inventory
03B Master Data Architecture
03C User Personas & Responsibility Matrix
03D Workflow Architecture
04 Database Design (Logical)
04A Database Design (Physical)
05 API Specification & Service Contract
06 Role Permission Matrix
07 UI Navigation Map & Route Registry
08 Antigravity Development Blueprint
Future Documents
09 Backend Technical Architecture
10 Flutter Frontend Architecture
11 DevOps & Deployment Architecture
12 SaaS Tenant Provisioning Architecture
13 Antigravity Prompt Library
14 Sprint Planning & Release Management
15 Module-Level BRDs
________________________________________
5. Document Dependency Map
Document 01
Defines Platform Vision
↓
Document 02
Defines Data Architecture
↓
Documents 02A–02C
Define Platform Runtime Behavior
↓
Document 03
Defines Industry Architecture
↓
Documents 03A–03D
Define Business Implementation
↓
Documents 04–04A
Define Database Design
↓
Document 05
Defines APIs
↓
Document 06
Defines Security
↓
Document 07
Defines UI Navigation
↓
Document 08
Defines Development Execution
________________________________________
6. Single Source Of Truth Hierarchy
Priority Order
Level 1
Document 00
Master Governance
________________________________________
Level 2
Documents 01–02C
Platform Architecture
________________________________________
Level 3
Documents 03–03D
Industry Architecture
________________________________________
Level 4
Documents 04–07
Implementation Architecture
________________________________________
Level 5
Document 08
Development Execution
________________________________________
Conflict Resolution Rule:
If two documents conflict:
Higher-Level Document Wins.
________________________________________
7. Platform Core Ownership
Platform Core owns:
Authentication
Authorization
Users
Roles
Permissions
Organizations
Navigation
Documents
Notifications
Audit
Dashboards
Master Data Framework
Workflow Framework
Search Framework
________________________________________
Industry Packs shall reuse Platform Core.
Industry Packs shall not duplicate Platform functionality.
________________________________________
8. Furniture Industry Pack Ownership
Furniture Industry Pack owns:
Customers
Products
Quotations
Sales Orders
BOM
Production Orders
Production Tracking
Deliveries
Furniture Dashboards
________________________________________
Furniture Pack shall not own:
Authentication
Users
Roles
Permissions
Documents
Audit
Navigation
________________________________________
9. Architecture Freeze Rules
The following documents are considered frozen:
01
02
02A
02B
02C
03
03A
03B
03C
03D
04
04A
05
06
07
08
Changes require architecture review.
No developer may alter architecture through code changes alone.
________________________________________
10. Development Governance
Development Order:
Database
↓
API
↓
Service
↓
UI
↓
Testing
↓
Deployment
UI-first development is prohibited.
________________________________________
11. Database Governance
Database changes require:
Architecture Review
Migration Script
Documentation Update
Version Increment
No direct production schema modifications.
________________________________________
12. API Governance
All APIs must:
Be documented
Be versioned
Be permission protected
Be audit enabled
Follow Document 05
________________________________________
13. Security Governance
All screens shall require:
Authentication
Authorization
Tenant Validation
Organization Validation
Permission Validation
Security shall follow Documents 02B and 06.
________________________________________
14. Navigation Governance
Menus shall be:
Dynamic
Permission Driven
Industry Aware
Module Aware
No hardcoded menus allowed.
Navigation shall follow Documents 02C and 07.
________________________________________
15. SaaS Governance
Every business entity shall support:
tenant_id
organization_id
The MVP may run as a single tenant deployment.
Architecture shall remain SaaS ready.
________________________________________
16. Industry Pack Governance
Every future Industry Pack must provide:
Industry Architecture
Module Catalog
Master Data Architecture
Role Matrix
Workflow Architecture
Database Design
API Design
before implementation begins.
________________________________________
17. Client Extension Governance
Client-specific requirements shall be implemented as:
Extensions
Configurations
Custom Reports
Custom Dashboards
Custom Fields
Core platform modification should be avoided.
________________________________________
18. Antigravity Governance
Antigravity shall not be allowed to:
Create new architecture patterns
Create new modules
Create new permissions
Create new tables
Create new routes
unless explicitly approved.
Antigravity must follow Documents 01–08.
________________________________________
19. Release Governance
MVP Release
Furniture Manufacturing
Target:
July 10
Approved Scope:
Authentication
Users
Roles
Customers
Products
Quotations
Sales Orders
Production Orders
Production Tracking
Deliveries
Dashboards
Documents
Audit
No additional modules are approved for MVP.
________________________________________
20. Future Roadmap
Phase 2
Inventory
Purchase
Suppliers
________________________________________
Phase 3
Finance
Accounting
Costing
________________________________________
Phase 4
SaaS Tenant Management
Subscription Management
Billing
________________________________________
Phase 5
Additional Industry Packs
Garments
Steel
Construction
Trading
________________________________________
21. Architecture Review Checklist
Before implementing any feature verify:
✓ Module Exists
✓ Screen Exists
✓ Route Exists
✓ Permission Exists
✓ Database Entity Exists
✓ API Exists
✓ Workflow Exists
✓ Role Mapping Exists
✓ Documentation Updated
________________________________________
22. Definition Of Architecture Compliance
A feature is architecture compliant only when:
Business Requirement Exists
Module Exists
Screen Exists
Database Exists
API Exists
Permission Exists
Workflow Exists
Documentation Exists
________________________________________
23. FurniFlow Master Architecture Statement
FurniFlow shall be developed as a reusable enterprise platform.
Furniture Manufacturing is the first Industry Pack.
Every architectural decision shall support future industries without requiring redesign of platform foundations.
This document serves as the official Master Architecture Index and Governance Framework for the FurniFlow Platform.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
FurniFlow Enterprise Platform Architecture
Version: 1.0
Status: Foundation Document
Purpose:
This document defines the long-term architecture vision of the FurniFlow Platform. It establishes the reusable enterprise platform components, industry-specific modules, extension strategy, access control framework, tenant strategy, and navigation framework that will govern all current and future implementations.
________________________________________
1. Vision Statement
FurniFlow is not a furniture ERP.
FurniFlow is an Enterprise Business Platform that enables rapid deployment of industry-specific business solutions using a common technology, security, data, and user management foundation.
The first implementation will target the Furniture Manufacturing industry.
Future implementations may include:
•	Furniture Manufacturing
•	Garments Manufacturing
•	Steel Fabrication
•	Modular Kitchen
•	Interior Projects
•	Construction Services
•	Trading Businesses
•	Distribution Businesses
The platform shall support multiple industries without requiring separate applications.
________________________________________
2. Architectural Principles
The platform shall follow the following principles:
1.	Modular Architecture
2.	Industry-Agnostic Core
3.	Multi-Tenant Ready
4.	API First Design
5.	Role-Based Access Control
6.	Cloud Native Deployment
7.	Mobile and Web Ready
8.	Extensible Industry Packs
9.	Secure by Design
10.	Configuration Over Customization
________________________________________
3. Platform Architecture Layers
Layer 1 – Core Platform
Provides reusable enterprise services.
Layer 2 – Business Foundation
Provides common business capabilities used by most industries.
Layer 3 – Industry Packs
Provides industry-specific functionality.
Layer 4 – Client Extensions
Provides customer-specific customizations.
Architecture:
Core Platform
│
├── Business Foundation
│
├── Industry Packs
│
└── Client Extensions
________________________________________
4. Core Platform Modules
The following modules shall be available in every implementation.
4.1 Identity & Access Management (IAM)
Purpose:
Provide secure authentication and access management.
Capabilities:
•	Login
•	Logout
•	Password Management
•	Session Management
•	Authentication Policies
•	Account Locking
•	Future MFA Support
________________________________________
4.2 Role Based Access Control (RBAC)
Purpose:
Control access to modules, screens and actions.
Capabilities:
•	Role Management
•	Permission Management
•	Role Assignment
•	Screen Access
•	Action Access
•	Data Access Restrictions
Examples:
•	Owner
•	Administrator
•	Sales Manager
•	Sales Executive
•	Factory Manager
•	Store Keeper
________________________________________
4.3 User Management
Purpose:
Manage platform users.
Capabilities:
•	Create User
•	Update User
•	Deactivate User
•	Assign Roles
•	Branch Assignment
•	Department Assignment
________________________________________
4.4 Organization Management
Purpose:
Represent organizational hierarchy.
Structure:
Tenant
→ Organization
→ Branch
→ Department
Capabilities:
•	Company Setup
•	Branch Setup
•	Department Setup
•	Business Units
________________________________________
4.5 Dashboard Framework
Purpose:
Provide reusable dashboard infrastructure.
Components:
•	KPI Cards
•	Charts
•	Tables
•	Widgets
•	Alerts
•	Notifications
Industry modules will supply dashboard data.
________________________________________
4.6 Notification Framework
Purpose:
Deliver business notifications.
Phase 1:
•	In-App Notifications
Future:
•	Email
•	SMS
•	WhatsApp
•	Push Notifications
________________________________________
4.7 Document Management Framework
Purpose:
Manage files and attachments.
Supported:
•	Images
•	PDFs
•	Excel Files
•	Drawings
•	Contracts
Capabilities:
•	Upload
•	Download
•	Preview
•	Version Control
________________________________________
4.8 Audit Framework
Purpose:
Provide complete auditability.
Track:
•	Create
•	Update
•	Delete
•	Approval
•	Login
•	Logout
Audit Fields:
•	Created By
•	Created On
•	Updated By
•	Updated On
________________________________________
5. Business Foundation Modules
The following modules are reusable across industries.
Customer Management
•	Customer Master
•	Contacts
•	Addresses
Product & Service Catalog
•	Categories
•	Products
•	Services
•	Variants
Workflow Framework
•	Status Management
•	Workflow Stages
•	State Transitions
Reporting Framework
•	Standard Reports
•	Export Functions
•	Dashboards
Search Framework
•	Global Search
•	Module Search
________________________________________
6. Industry Pack Architecture
Industry packs contain business-specific functionality.
Each industry pack may enable or disable modules based on business requirements.
Examples:
Furniture Pack
Garments Pack
Steel Pack
Construction Pack
All industry packs shall utilize the common platform foundation.
________________________________________
7. Furniture Manufacturing Industry Pack
Initial Release Industry.
Modules:
•	Customer Management
•	Product Catalog
•	Quotations
•	Sales Orders
•	BOM
•	Production Tracking
•	Deliveries
•	Dashboards
Production Workflow:
Raw Material
→ Cutting
→ Carpentry
→ Sanding
→ Sealer
→ Polishing
→ Painting
→ QC
→ Ready
→ Dispatch
→ Delivered
________________________________________
8. Client Extension Framework
Purpose:
Support customer-specific requirements.
Extension Types:
•	Custom Reports
•	Custom Dashboards
•	Custom Fields
•	Custom Workflows
•	Custom Validations
Core platform code shall remain unchanged.
________________________________________
9. Module Enablement Strategy
Every module shall support activation and deactivation.
Example:
Furniture Client
Enabled:
•	CRM
•	Product Catalog
•	Production
•	Delivery
Disabled:
•	Project Management
•	Asset Management
Future clients may enable different combinations.
________________________________________
10. Navigation Framework
Menus shall be dynamically generated.
Navigation shall depend on:
•	Industry Pack
•	Enabled Modules
•	User Role
Formula:
Visible Menu =
Enabled Module
+
Screen Access Permission
+
User Role
No menu shall be hardcoded.
________________________________________
11. Authentication Architecture
Authentication Flow:
User
→ Login
→ Identity Validation
→ JWT Generation
→ Session Creation
→ Access Granted
Token Types:
•	Access Token
•	Refresh Token
Future:
•	MFA
•	SSO
•	OAuth
________________________________________
12. SaaS Architecture Strategy
The platform shall support Multi-Tenant SaaS deployment.
Tenant Structure:
Tenant
→ Organization
→ Users
Principles:
•	Tenant Isolation
•	Shared Platform
•	Shared Infrastructure
•	Secure Data Segregation
Every business table shall support tenant identification.
________________________________________
13. Technology Architecture
Frontend:
Flutter
Backend:
Golang
Framework:
Fiber
Database:
PostgreSQL
Cache:
Redis
Storage:
MinIO
Deployment:
Docker
Future:
Kubernetes
________________________________________
14. Guiding Rule
Every future module, screen, API, database table, workflow and industry pack shall comply with this architecture document.
This document serves as the permanent architectural foundation of the FurniFlow Platform.

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Platform Data Architecture
Version: 1.0
Status: Architectural Baseline
Purpose:
This document defines the data architecture standards, tenant strategy, organizational hierarchy, master data strategy, entity standards, audit standards, security standards, and database design principles for the FurniFlow Platform.
This document serves as the single source of truth for all future database design, APIs, modules, and industry packs.
________________________________________
1. Objectives
The platform data architecture shall:
•	Support multiple industries
•	Support multiple organizations
•	Support future SaaS deployment
•	Support role-based access control
•	Support auditability
•	Support extensibility
•	Support future integrations
•	Minimize database redesign
________________________________________
2. Data Architecture Principles
The platform shall follow the following principles:
1.	Tenant Aware
2.	Organization Aware
3.	Industry Agnostic
4.	API First
5.	Audit Driven
6.	Soft Delete Preferred
7.	Reference Data Centralized
8.	Extensible Entity Model
9.	Security by Design
10.	Backward Compatible Evolution
________________________________________
3. Platform Hierarchy
The platform hierarchy shall be:
Tenant
→ Organization
→ Branch
→ Department
→ User
Example:
Tenant:
ABC Group
Organization:
ABC Furniture
Branch:
Chennai
Department:
Production
User:
Factory Manager
This hierarchy applies to every industry.
________________________________________
4. Multi-Tenant Strategy
4.1 Initial Release
July Release:
Single Customer Deployment
Platform must still be designed as SaaS Ready.
________________________________________
4.2 Future SaaS Strategy
Recommended Approach:
Shared Database
Shared Schema
Tenant Isolation
Every business entity shall contain:
tenant_id
Example:
customers
products
sales_orders
production_orders
________________________________________
4.3 Tenant Isolation Rule
No business record shall exist without tenant ownership.
Every business table shall contain:
tenant_id
This rule is mandatory.
________________________________________
5. Organization Structure
Organization Model
Tenant
→ Organization
→ Branch
→ Department
Tenant
Represents a subscribing customer.
Examples:
ABC Furniture
XYZ Garments
SteelPro Industries
________________________________________
Organization
Represents a legal company.
Examples:
ABC Furniture Pvt Ltd
________________________________________
Branch
Represents a physical location.
Examples:
Chennai
Bangalore
Dubai
________________________________________
Department
Examples:
Sales
Production
Finance
Purchase
Inventory
________________________________________
6. Universal Entity Standards
Every business entity shall follow common standards.
Required Columns:
id
tenant_id
organization_id
created_by
created_on
updated_by
updated_on
is_active
remarks
Examples:
customers
products
sales_orders
production_orders
________________________________________
7. Primary Key Strategy
All tables shall use:
UUID
Example:
id UUID PRIMARY KEY
Reason:
•	SaaS friendly
•	Distributed systems friendly
•	API friendly
•	No dependency on sequence values
________________________________________
8. Soft Delete Strategy
Records shall not be physically deleted.
Use:
is_active
Future:
deleted_on
deleted_by
Benefits:
•	Auditability
•	Recovery
•	Historical reporting
________________________________________
9. Master Data Strategy
Master data shall be centralized.
No module shall create duplicate masters.
________________________________________
Global Masters
Countries
States / Provinces
Cities
Currencies
Languages
Time Zones
Units of Measure
Document Types
Communication Types
Attachment Types
________________________________________
Organization Masters
Departments
Branches
Designations
Cost Centers
Work Centers
Warehouses
________________________________________
Industry Masters
Created only if required by industry.
Examples:
Furniture:
Wood Types
Garments:
Fabric Types
Steel:
Material Grades
________________________________________
10. RBAC Data Architecture
Access shall be controlled through RBAC.
Structure:
User
→ Role
→ Permission
→ Screen
________________________________________
Core Entities
users
roles
permissions
user_roles
role_permissions
screens
modules
________________________________________
Permission Types
View
Create
Edit
Delete
Approve
Export
Print
Admin
________________________________________
11. Navigation Architecture
Navigation shall be data-driven.
Menus shall not be hardcoded.
Structure:
Industry Pack
→ Enabled Module
→ Enabled Screen
→ Role Access
Example:
Furniture Industry
Enabled:
Dashboard
Customers
Products
Production
Disabled:
Project Management
Asset Management
Navigation must be generated dynamically.
________________________________________
12. Module Architecture
Every module shall contain:
Module
→ Screens
→ APIs
→ Permissions
→ Reports
Example:
Customer Management
Customer List
Customer Details
Customer Create
Customer Edit
Customer Reports
________________________________________
13. Document Architecture
Documents shall be managed centrally.
Supported:
Images
PDF
Excel
Word
CAD Drawings
Product Photos
Delivery Proofs
Invoices
________________________________________
Document Metadata
Document ID
Document Name
Document Type
Module Name
Entity Type
Entity ID
Uploaded By
Uploaded On
File Path
Version
________________________________________
14. Audit Architecture
All transactional entities shall be auditable.
Track:
Create
Update
Delete
Approval
Status Changes
Login
Logout
________________________________________
Mandatory Audit Columns
created_by
created_on
updated_by
updated_on
________________________________________
Audit Log Table
audit_logs
Store:
entity_name
entity_id
action
old_value
new_value
performed_by
performed_on
________________________________________
15. Workflow Data Architecture
Workflow must be configurable.
Structure:
Workflow
Workflow Stage
Workflow Transition
Workflow Action
________________________________________
Example:
Quotation
Draft
→ Submitted
→ Approved
→ Rejected
Furniture Production
Cutting
→ Carpentry
→ Sanding
→ Polishing
→ QC
Future industries may define different workflows.
________________________________________
16. Notification Architecture
Notifications shall be centralized.
Notification Types:
In-App
Email
SMS
WhatsApp
Push
________________________________________
Notification Entity
notification_id
recipient_user_id
title
message
status
created_on
read_on
________________________________________
17. Search Architecture
Global Search shall be supported.
Search Sources:
Customers
Products
Orders
Production Orders
Invoices
Documents
Future:
Elastic/OpenSearch
________________________________________
18. API Data Standards
All APIs shall follow common standards.
________________________________________
Request Structure
Header:
Authorization Token
Tenant Context
Organization Context
________________________________________
Response Structure
success
message
data
errors
________________________________________
Pagination Standard
page
page_size
total_records
total_pages
________________________________________
19. Naming Standards
Table Names:
snake_case
Plural
Examples:
customers
products
sales_orders
production_orders
________________________________________
Column Names:
snake_case
Examples:
customer_name
created_on
tenant_id
organization_id
________________________________________
API Names:
kebab-case
Examples:
/api/customers
/api/sales-orders
/api/production-orders
________________________________________
20. Data Security Standards
All business data must be protected.
Rules:
Tenant Isolation
Role Based Access
JWT Authentication
HTTPS
Audit Tracking
Soft Delete
Input Validation
Parameterized Queries
No Direct Database Exposure
________________________________________
21. Platform Core Data Domains
Core Platform Tables
tenants
organizations
branches
departments
users
roles
permissions
user_roles
role_permissions
modules
screens
documents
notifications
audit_logs
workflows
workflow_stages
workflow_transitions
________________________________________
22. Industry Data Domains
Industry packs shall own their own data.
Example:
Furniture Industry
customers
products
quotations
sales_orders
production_orders
deliveries
Future industries shall create new domains without impacting platform core.
________________________________________
23. Future Extensibility Rule
New industry packs shall:
•	Reuse platform core entities
•	Reuse RBAC
•	Reuse audit framework
•	Reuse notification framework
•	Reuse document framework
New industries shall never duplicate platform capabilities.
________________________________________
24. Guiding Principle
Platform Core is permanent.
Industry Packs are replaceable.
Client Extensions are optional.
Every future database table, API, module, workflow, and screen shall comply with this document.
This document serves as the official data architecture baseline of the FurniFlow Platform.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Platform Module Registry
Version: 1.0
Status: Architecture Baseline
Purpose:
This document defines the official platform module registry, module identifiers, screen identifiers, menu hierarchy, permission naming conventions, and routing standards for the FurniFlow Platform.
This document serves as the single source of truth for:
•	Navigation
•	RBAC
•	API Authorization
•	Menu Generation
•	Screen Registration
•	Industry Pack Enablement
•	Future Module Expansion
No module, screen, permission, or menu shall be created outside this registry.
________________________________________
1. Platform Registry Principles
The platform shall be composed of:
Platform Core
+
Business Foundation
+
Industry Packs
+
Client Extensions
Every screen must belong to:
Module
→ Screen
Every permission must belong to:
Module
→ Screen
→ Action
________________________________________
2. Module Classification
Modules shall be classified as:
CORE
FOUNDATION
INDUSTRY
EXTENSION
________________________________________
3. Core Platform Modules
These modules are always available.
IAM
Module Code:
IAM
Purpose:
Authentication and Identity Management
Screens:
LOGIN
CHANGE_PASSWORD
PROFILE
SESSION_MANAGEMENT
________________________________________
USER MANAGEMENT
Module Code:
USR
Purpose:
Manage platform users
Screens:
USR_LIST
USR_CREATE
USR_EDIT
USR_VIEW
USR_ROLE_ASSIGNMENT
________________________________________
ROLE MANAGEMENT
Module Code:
ROL
Purpose:
Manage roles and permissions
Screens:
ROL_LIST
ROL_CREATE
ROL_EDIT
ROL_PERMISSION_MAPPING
________________________________________
ORGANIZATION MANAGEMENT
Module Code:
ORG
Purpose:
Manage organizational hierarchy
Screens:
ORG_LIST
ORG_DETAILS
BRANCH_LIST
DEPARTMENT_LIST
________________________________________
DOCUMENT MANAGEMENT
Module Code:
DOC
Purpose:
Manage documents and attachments
Screens:
DOC_LIST
DOC_UPLOAD
DOC_VIEW
DOC_DOWNLOAD
________________________________________
NOTIFICATION MANAGEMENT
Module Code:
NTF
Purpose:
Manage notifications
Screens:
NTF_LIST
NTF_DETAILS
________________________________________
AUDIT MANAGEMENT
Module Code:
AUD
Purpose:
System audit visibility
Screens:
AUD_LIST
AUD_DETAILS
________________________________________
DASHBOARD FRAMEWORK
Module Code:
DSH
Purpose:
Dashboard infrastructure
Screens:
DSH_HOME
DSH_WIDGET_CONFIGURATION
________________________________________
4. Business Foundation Modules
These modules are reusable across industries.
________________________________________
CUSTOMER MANAGEMENT
Module Code:
CUS
Screens:
CUS_LIST
CUS_CREATE
CUS_EDIT
CUS_VIEW
CUS_CONTACTS
CUS_ADDRESSES
________________________________________
PRODUCT CATALOG
Module Code:
PRD
Screens:
PRD_CATEGORY_LIST
PRD_LIST
PRD_CREATE
PRD_EDIT
PRD_VIEW
PRD_VARIANTS
PRD_DOCUMENTS
________________________________________
WORKFLOW MANAGEMENT
Module Code:
WFL
Screens:
WFL_LIST
WFL_CREATE
WFL_STAGE_SETUP
WFL_TRANSITION_SETUP
________________________________________
REPORTING
Module Code:
RPT
Screens:
RPT_DASHBOARD
RPT_STANDARD
RPT_EXPORT
________________________________________
5. Industry Pack Registry
Industry modules are enabled only when the corresponding industry pack is activated.
________________________________________
5.1 Furniture Manufacturing Industry Pack
Industry Code:
FURN
Modules:
FURN_CRM
FURN_SALES
FURN_MANUFACTURING
FURN_DELIVERY
FURN_DASHBOARD
________________________________________
Furniture CRM
Module Code:
FCRM
Screens:
FCRM_INQUIRIES
FCRM_QUOTATIONS
FCRM_CUSTOMERS
________________________________________
Furniture Sales
Module Code:
FSAL
Screens:
FSAL_ORDER_LIST
FSAL_ORDER_CREATE
FSAL_ORDER_VIEW
________________________________________
Furniture Manufacturing
Module Code:
FMFG
Screens:
FMFG_BOM
FMFG_PRODUCTION_ORDERS
FMFG_STAGE_TRACKING
FMFG_PRODUCTION_BOARD
FMFG_PRODUCTION_TIMELINE
________________________________________
Furniture Delivery
Module Code:
FDLV
Screens:
FDLV_LIST
FDLV_DISPATCH
FDLV_DELIVERED
________________________________________
Furniture Dashboard
Module Code:
FDSH
Screens:
FDSH_OWNER
FDSH_FACTORY
________________________________________
5.2 Future Garments Industry Pack
Industry Code:
GAR
Reserved
Modules to be defined later.
________________________________________
5.3 Future Steel Industry Pack
Industry Code:
STL
Reserved
Modules to be defined later.
________________________________________
6. Menu Hierarchy Standard
Menu structure shall be generated dynamically.
Hierarchy:
Industry
→ Module
→ Screen
Example:
Furniture
Dashboard
Owner Dashboard
Factory Dashboard
CRM
Customers
Quotations
Sales
Orders
Manufacturing
BOM
Production Orders
Stage Tracking
Delivery
Dispatch
Delivery
No menu shall be hardcoded.
________________________________________
7. Permission Registry
Permissions shall follow a standard naming convention.
Format:
MODULE.SCREEN.ACTION
Examples:
CUS.CUS_LIST.VIEW
CUS.CUS_CREATE.CREATE
CUS.CUS_EDIT.UPDATE
PRD.PRD_LIST.VIEW
FMFG.FMFG_STAGE_TRACKING.UPDATE
FSAL.FSAL_ORDER_CREATE.CREATE
________________________________________
8. Permission Actions
Only the following action types are permitted.
VIEW
CREATE
UPDATE
DELETE
APPROVE
REJECT
EXPORT
PRINT
ADMIN
Future actions require architecture review.
________________________________________
9. Route Naming Standards
Frontend Route Format:
/module/screen
Examples:
/customers/list
/customers/create
/products/list
/production/orders
/production/tracking
________________________________________
10. API Naming Standards
Format:
/api/module/resource
Examples:
/api/customers
/api/products
/api/sales-orders
/api/production-orders
/api/deliveries
________________________________________
11. Database Registry Standards
Every module shall have a corresponding registry record.
Modules Table:
module_code
module_name
module_type
industry_code
is_active
________________________________________
Screens Table:
screen_code
screen_name
module_code
route_path
is_active
________________________________________
Permissions Table:
permission_code
module_code
screen_code
action_type
________________________________________
12. Module Enablement Rules
Modules may be enabled or disabled at:
Tenant Level
Industry Level
Organization Level
Example:
Furniture Tenant
Enabled:
FCRM
FSAL
FMFG
FDLV
Disabled:
Project Management
Asset Management
________________________________________
13. Industry Activation Rules
Industry Pack Activation shall:
Enable modules
Enable screens
Enable permissions
Generate menus
Apply default role mappings
Deactivate unused industry components
________________________________________
14. Default Platform Roles
The platform shall provide the following default role templates.
PLATFORM_ADMIN
ORGANIZATION_ADMIN
OWNER
MANAGER
SUPERVISOR
USER
Industry packs may create additional roles.
________________________________________
15. Governance Rule
Before any new module, screen, route, API, permission, or industry pack is created:
1.	Module must exist in this registry.
2.	Screen must exist in this registry.
3.	Route must comply with naming standards.
4.	Permission must comply with naming standards.
5.	Industry ownership must be defined.
Any component not registered in this document shall be considered non-compliant.
________________________________________
16. July 2026 Frozen Registry Scope
For MVP Release:
Core Modules:
IAM
USR
ROL
ORG
DOC
AUD
DSH
Foundation Modules:
CUS
PRD
Furniture Modules:
FCRM
FSAL
FMFG
FDLV
FDSH
Only these modules are approved for implementation during the initial Furniture Manufacturing MVP release.
This registry serves as the official module catalog and permission authority for the FurniFlow Platform.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
FurniFlow Platform RBAC & Authorization Architecture
Version: 1.0
Status: Architecture Baseline
Purpose:
This document defines the official Role-Based Access Control (RBAC) and Authorization Architecture for the FurniFlow Platform.
This document serves as the single source of truth for:
•	User Authorization
•	Role Management
•	Permission Management
•	Screen Access
•	Menu Visibility
•	API Authorization
•	Data Access Rules
•	Industry Pack Access
•	Tenant Isolation
All future modules, APIs, screens, and workflows shall comply with this document.
________________________________________
1. Objectives
The authorization framework shall:
•	Support multiple industries
•	Support multiple tenants
•	Support multiple organizations
•	Support dynamic module enablement
•	Support dynamic menu generation
•	Support screen-level security
•	Support API-level security
•	Support future SaaS deployments
•	Support least privilege access
________________________________________
2. Authorization Principles
The platform shall follow:
1.	Least Privilege Principle
2.	Deny By Default
3.	Role Based Access
4.	Permission Driven Access
5.	Tenant Isolation
6.	Organization Isolation
7.	Auditability
8.	Configurable Authorization
9.	Dynamic Menu Generation
10.	Centralized Permission Governance
________________________________________
3. Access Control Hierarchy
Authorization shall follow:
User
→ Role
→ Permission
→ Resource
Resource may be:
•	Module
•	Screen
•	API
•	Action
•	Report
•	Dashboard Widget
No user shall receive direct screen access.
All access shall be granted through roles.
________________________________________
4. RBAC Architecture
The platform shall implement:
Role Based Access Control (RBAC)
Structure:
User
→ Assigned Role(s)
→ Permissions
→ Authorized Resources
Example:
User:
John
Role:
Sales Manager
Permissions:
Customer View
Quotation Create
Quotation Approve
Order View
________________________________________
5. Authorization Layers
The platform shall enforce authorization at five layers.
Layer 1
Authentication
Validate user identity.
________________________________________
Layer 2
Tenant Validation
Validate tenant ownership.
________________________________________
Layer 3
Organization Validation
Validate organization scope.
________________________________________
Layer 4
Role Validation
Validate assigned role.
________________________________________
Layer 5
Permission Validation
Validate requested action.
Access is granted only when all layers pass.
________________________________________
6. Authorization Scope Levels
Permissions may be granted at different scopes.
________________________________________
Tenant Scope
Access across entire tenant.
Example:
Platform Administrator
________________________________________
Organization Scope
Access across organization.
Example:
Organization Admin
________________________________________
Branch Scope
Access limited to branch.
Example:
Branch Manager
________________________________________
Department Scope
Access limited to department.
Example:
Production Supervisor
________________________________________
Personal Scope
Access limited to own records.
Example:
Sales Executive
________________________________________
7. Core Authorization Entities
The following entities are mandatory.
users
roles
permissions
user_roles
role_permissions
modules
screens
permission_actions
authorization_policies
________________________________________
8. Role Architecture
Roles shall represent business responsibilities.
Roles shall not represent individuals.
Correct:
Sales Manager
Factory Manager
Store Keeper
Owner
________________________________________
Incorrect:
John Role
Vinod Role
Hari Role
________________________________________
9. Role Categories
Platform Roles
Organization Roles
Industry Roles
Custom Roles
________________________________________
Platform Roles
Provided by platform.
Examples:
PLATFORM_ADMIN
SUPPORT_ADMIN
SYSTEM_AUDITOR
________________________________________
Organization Roles
Provided by organization.
Examples:
ORG_ADMIN
OWNER
MANAGER
SUPERVISOR
USER
________________________________________
Industry Roles
Provided by industry packs.
Examples:
Furniture:
Sales Executive
Factory Manager
Store Keeper
Garments:
Production Planner
Line Supervisor
________________________________________
Custom Roles
Created by tenant administrators.
________________________________________
10. Permission Architecture
Permissions shall represent actions.
Permission Format:
MODULE.SCREEN.ACTION
Examples:
CUS.CUS_LIST.VIEW
CUS.CUS_CREATE.CREATE
PRD.PRD_EDIT.UPDATE
FMFG.FMFG_STAGE_TRACKING.UPDATE
________________________________________
11. Standard Action Types
Only the following actions are allowed.
VIEW
CREATE
UPDATE
DELETE
APPROVE
REJECT
EXPORT
PRINT
ADMIN
Future action types require architecture approval.
________________________________________
12. Module Authorization
Module access shall be controlled through permissions.
If user lacks module permissions:
Module shall not appear in menu.
Module APIs shall be inaccessible.
Module reports shall be inaccessible.
________________________________________
13. Screen Authorization
Every screen must have a unique screen code.
Example:
CUS_LIST
PRD_LIST
FMFG_PRODUCTION_BOARD
Authorization shall be evaluated before screen rendering.
Unauthorized screens shall not load.
________________________________________
14. Menu Authorization
Menus shall be generated dynamically.
Formula:
Visible Menu
=
Enabled Module
AND
Authorized Screen
AND
Active Permission
Menu items shall never be hardcoded.
________________________________________
15. API Authorization
Every API endpoint shall require authorization.
Flow:
Authenticate User
Validate Tenant
Validate Organization
Validate Role
Validate Permission
Execute API
________________________________________
Example:
POST /api/customers
Required Permission:
CUS.CUS_CREATE.CREATE
________________________________________
GET /api/customers
Required Permission:
CUS.CUS_LIST.VIEW
________________________________________
16. Dashboard Authorization
Dashboard widgets shall be permission driven.
Example:
Revenue Widget
Permission:
DSH.REVENUE.VIEW
Production Widget
Permission:
FMFG.PRODUCTION.VIEW
Users may view different dashboards based on permissions.
________________________________________
17. Report Authorization
Reports shall be secured independently.
Viewing a screen does not automatically grant report access.
Examples:
Sales Report
Production Report
Costing Report
Variance Report
Each report requires explicit permission.
________________________________________
18. Document Authorization
Documents inherit parent entity authorization.
Example:
Sales Order Attachment
Access depends on Sales Order permission.
Additional document restrictions may be applied.
________________________________________
19. Data Access Authorization
Screen access alone is insufficient.
Data visibility must also be controlled.
Examples:
Sales Executive
Can view own customers.
Sales Manager
Can view team customers.
Owner
Can view all customers.
This rule applies across all modules.
________________________________________
20. Industry Pack Authorization
Industry packs shall automatically register:
Roles
Permissions
Menus
Screens
Reports
Example:
Furniture Pack
Registers:
Factory Manager
Store Keeper
Production Supervisor
Production Permissions
Manufacturing Menus
Production Reports
________________________________________
21. Module Enablement Authorization
Disabled modules shall:
Hide menus
Hide screens
Disable APIs
Disable reports
Ignore permissions
No disabled module shall be accessible.
________________________________________
22. Tenant Isolation Rules
Users shall never access records belonging to another tenant.
Authorization checks must enforce:
tenant_id validation
on every request.
This rule is mandatory.
________________________________________
23. Audit Requirements
Every authorization event shall be auditable.
Events:
Login
Logout
Permission Denied
Role Assignment
Permission Assignment
Module Enablement
Module Disablement
Sensitive Data Access
________________________________________
24. Authorization Failure Handling
Unauthorized requests shall return:
401 Unauthorized
or
403 Forbidden
No internal authorization details shall be exposed.
________________________________________
25. Default Platform Roles
The platform shall provide:
PLATFORM_ADMIN
ORG_ADMIN
OWNER
MANAGER
SUPERVISOR
USER
Industry packs may extend these roles.
Platform roles shall never be modified directly.
________________________________________
26. Future Authorization Support
The architecture shall support:
Multi-Factor Authentication (MFA)
Single Sign-On (SSO)
OAuth
OpenID Connect
Attribute Based Access Control (ABAC)
Policy Based Authorization
without redesigning the RBAC framework.
________________________________________
27. Authorization Governance Rules
Every new component must define:
Module
Screen
Permission
Role Mapping
Menu Visibility
API Permission
Data Access Scope
No module shall be implemented without authorization mapping.
________________________________________
28. July 2026 MVP Authorization Scope
Approved for initial implementation:
Authentication
User Management
Role Management
Permission Management
Dynamic Menu Authorization
API Authorization
Furniture Industry Role Mapping
Tenant-Aware Authorization Model
Advanced ABAC and Policy Engine are deferred to future releases.
________________________________________
29. Guiding Principle
Authentication determines who the user is.
Authorization determines what the user can access.
Permissions determine what actions the user can perform.
Data scope determines which records the user can see.
All platform modules, industry packs, APIs, screens, dashboards, reports, and future extensions shall comply with this document.
This document serves as the official RBAC and Authorization Architecture baseline for the FurniFlow Platform.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Platform Navigation & Module Enablement Architecture
Version: 1.0
Status: Architecture Baseline
Purpose:
This document defines the official navigation architecture, module enablement framework, menu generation model, industry activation process, screen visibility rules, and route governance standards for the FurniFlow Platform.
This document serves as the single source of truth for:
•	Navigation
•	Sidebar Menus
•	Route Visibility
•	Industry Pack Activation
•	Module Enablement
•	Screen Enablement
•	Dynamic Menu Rendering
•	RBAC Driven Navigation
All future industry packs, modules, screens, and menus shall comply with this document.
________________________________________
1. Objectives
The navigation architecture shall:
•	Support multiple industries
•	Support multiple tenants
•	Support dynamic menus
•	Support role-based visibility
•	Support module enablement
•	Support future SaaS deployments
•	Eliminate hardcoded menus
•	Eliminate hardcoded routing decisions
________________________________________
2. Navigation Principles
The platform shall follow:
1.	Configuration Driven Navigation
2.	Permission Driven Visibility
3.	Industry Aware Navigation
4.	Module Based Organization
5.	Dynamic Menu Rendering
6.	Route Authorization Enforcement
7.	Tenant Aware Enablement
8.	Extensible Menu Hierarchy
________________________________________
3. Navigation Hierarchy
The navigation hierarchy shall be:
Industry Pack
→ Module
→ Screen
Example:
Furniture Manufacturing
Dashboard
Owner Dashboard
Factory Dashboard
CRM
Customers
Quotations
Sales
Orders
Manufacturing
Production Orders
Stage Tracking
Delivery
Dispatch
Deliveries
This hierarchy shall be generated dynamically.
________________________________________
4. Platform Navigation Model
Menu visibility shall be determined by:
Enabled Industry Pack
+
Enabled Module
+
Enabled Screen
+
Role Permission
Formula:
Visible Screen
=
Industry Enabled
AND
Module Enabled
AND
Screen Enabled
AND
Permission Granted
If any condition fails, the screen shall not be visible.
________________________________________
5. Navigation Components
The platform shall support:
Primary Navigation
Secondary Navigation
Breadcrumb Navigation
Context Navigation
Dashboard Shortcuts
Quick Actions
________________________________________
6. Primary Navigation
Primary Navigation represents modules.
Examples:
Dashboard
Customers
Products
Sales
Manufacturing
Delivery
Reports
Administration
Primary Navigation shall be generated dynamically.
________________________________________
7. Secondary Navigation
Secondary Navigation represents screens.
Example:
Customers
Customer List
Customer Create
Customer Details
Customer Reports
Only authorized screens shall be displayed.
________________________________________
8. Route Registry
Every route must be registered.
No route shall exist without registration.
Required Route Metadata:
Route Code
Route Name
Module Code
Screen Code
Permission Code
Industry Code
Route Path
Is Active
________________________________________
9. Route Naming Standards
Format:
/module/screen
Examples:
/customers/list
/customers/create
/products/list
/production/orders
/production/stage-tracking
/sales/orders
________________________________________
10. Navigation Metadata Architecture
Each screen shall contain:
screen_code
screen_name
module_code
industry_code
route_path
menu_label
display_order
icon_name
is_visible
is_active
________________________________________
11. Industry Pack Architecture
Industry Packs control business functionality.
Examples:
Furniture Manufacturing
Garments Manufacturing
Steel Fabrication
Construction
Trading
Each industry pack registers:
Modules
Screens
Permissions
Menus
Dashboards
Reports
________________________________________
12. Industry Activation Process
When an industry pack is activated:
Step 1
Register Modules
Step 2
Register Screens
Step 3
Register Permissions
Step 4
Register Menus
Step 5
Assign Default Roles
Step 6
Enable Industry Navigation
Only then shall screens become available.
________________________________________
13. Module Enablement Architecture
Modules shall support activation and deactivation.
Module States:
ACTIVE
INACTIVE
DEPRECATED
DISABLED
Only ACTIVE modules may appear in navigation.
________________________________________
14. Module Enablement Levels
Modules may be enabled at:
Platform Level
Tenant Level
Organization Level
Future Business Unit Level
Example:
Furniture Tenant
Enabled:
CRM
Products
Manufacturing
Delivery
Disabled:
Project Management
Asset Management
Quality Management
________________________________________
15. Screen Enablement Architecture
Modules may contain many screens.
Each screen may be:
ACTIVE
INACTIVE
HIDDEN
DEPRECATED
Only ACTIVE screens may be displayed.
________________________________________
16. Menu Generation Rules
Menus shall never be hardcoded.
Menus shall be generated using:
Industry Pack
Module Registry
Screen Registry
Permission Registry
User Role
Menu generation shall occur after successful login.
________________________________________
17. Dashboard Navigation
Dashboards shall be treated as screens.
Examples:
Owner Dashboard
Factory Dashboard
Sales Dashboard
Finance Dashboard
Dashboard visibility shall follow permission rules.
________________________________________
18. Quick Action Framework
The platform shall support configurable quick actions.
Examples:
Create Customer
Create Quotation
Create Sales Order
Create Production Order
Quick Actions shall be permission aware.
Users shall only see authorized actions.
________________________________________
19. Global Search Navigation
Global Search shall support:
Customers
Products
Orders
Production Orders
Documents
Reports
Search results shall respect authorization rules.
Unauthorized records shall not appear.
________________________________________
20. Breadcrumb Architecture
Breadcrumbs shall be generated automatically.
Example:
Manufacturing
→ Production Orders
→ Order Details
→ Stage Tracking
Breadcrumbs shall use route metadata.
________________________________________
21. Deep Link Architecture
The platform shall support deep linking.
Examples:
/sales/orders/{id}
/customers/{id}
/production-orders/{id}
Access shall still require authorization validation.
________________________________________
22. Mobile Navigation Architecture
Mobile navigation shall use the same registry.
Differences:
Layout Only
No separate permission model shall exist for mobile.
Authorization rules remain identical.
________________________________________
23. Navigation Security Rules
Navigation visibility is not security.
Even if a screen is hidden:
API access must still be validated.
Screen access must still be validated.
Permissions must still be validated.
Security shall never depend solely on menu visibility.
________________________________________
24. Module Dependency Rules
Modules may depend on other modules.
Examples:
Sales depends on Customer Management.
Production depends on Product Catalog.
Delivery depends on Sales Orders.
Dependency validation shall occur during activation.
________________________________________
25. Furniture Industry Navigation (MVP)
Approved Navigation Structure
Dashboard
Owner Dashboard
Factory Dashboard
________________________________________
CRM
Customers
Quotations
________________________________________
Catalog
Products
Categories
________________________________________
Sales
Sales Orders
________________________________________
Manufacturing
BOM
Production Orders
Stage Tracking
Production Board
Production Timeline
________________________________________
Delivery
Dispatch
Deliveries
________________________________________
Administration
Users
Roles
Permissions
Documents
Audit Logs
________________________________________
26. Navigation Database Registry
The following registry tables are mandatory.
modules
screens
routes
menu_groups
menu_items
industry_packs
industry_modules
industry_screens
________________________________________
27. Flutter Navigation Strategy
Flutter routing shall be generated from:
Route Registry
Permission Registry
Industry Registry
The Flutter application shall not hardcode:
Menus
Role Checks
Industry Checks
Module Checks
These values shall be loaded from platform configuration.
________________________________________
28. SaaS Tenant Onboarding Flow
When a new tenant is created:
Create Tenant
Assign Industry Pack
Enable Modules
Create Organization
Assign Default Roles
Generate Navigation
Activate Tenant
This process shall be automated.
________________________________________
29. Future Expansion Rules
New industries shall:
Register Industry Pack
Register Modules
Register Screens
Register Permissions
Register Menus
Reuse Existing Platform Components
No industry shall duplicate platform functionality.
________________________________________
30. Guiding Principle
Users do not navigate the application.
Users navigate authorized capabilities.
Visible Navigation
=
Industry Pack
•	
Enabled Modules
•	
Enabled Screens
•	
Authorized Permissions
The navigation system shall remain completely configuration driven, role aware, industry aware, and tenant aware.
This document serves as the official Navigation and Module Enablement Architecture baseline for the FurniFlow Platform.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Furniture Manufacturing Industry Architecture & BRD Foundation
Version: 1.0
Status: Industry Architecture Baseline
Industry Pack:
Furniture Manufacturing
Platform:
FurniFlow Enterprise Platform
Purpose:
This document defines the business architecture, operating model, business workflows, module boundaries, user personas, and business capabilities of the Furniture Manufacturing Industry Pack.
This document serves as the official foundation for all future Furniture Manufacturing BRDs, FRS documents, database design, APIs, screens, reports, and development activities.
________________________________________
1. Industry Overview
The Furniture Manufacturing Industry Pack is designed for organizations engaged in:
•	Furniture Retail Sales
•	Furniture Showroom Operations
•	Furniture Manufacturing
•	Make-To-Order Production
•	Customized Furniture Production
•	Limited Stock Sales
•	Delivery Operations
The initial implementation is based on the business processes identified during client workshops and site visits.
________________________________________
2. Business Context
The client currently operates using:
•	Paper Records
•	Excel Sheets
•	Phone Calls
•	Employee Knowledge
•	Manual Production Tracking
Current business visibility is limited.
Business users cannot easily determine:
•	Current production stage
•	Delivery readiness
•	Order completion status
•	Production delays
•	Order profitability
These pain points were repeatedly identified during discussions.
________________________________________
3. Industry Objectives
The Furniture Industry Pack shall enable:
1.	End-to-End Order Visibility
2.	Production Stage Visibility
3.	Delivery Commitment Tracking
4.	Customer Status Tracking
5.	Production Monitoring
6.	Management Reporting
7.	Knowledge Capture
8.	Reduced Dependency On Individuals
9.	Operational Standardization
________________________________________
4. Business Operating Model
The business operates using two primary order models.
________________________________________
4.1 Customized Furniture Orders
Furniture is manufactured after customer confirmation.
Examples:
•	King Size Cot
•	Dining Table
•	Sofa
•	Customized Chair
Production begins after order approval.
________________________________________
4.2 Showroom Orders
Products already available in showroom inventory.
Examples:
•	Display Models
•	Ready Products
•	Stock Items
Products may be delivered immediately or scheduled for delivery.
________________________________________
5. Business Lifecycle
The furniture business lifecycle shall be:
Inquiry
→ Quotation
→ Sales Order
→ Production Planning
→ Production Execution
→ Quality Validation
→ Delivery
→ Completion
This lifecycle represents the primary operating flow of the industry pack.
________________________________________
6. Customer Lifecycle
Customer
→ Inquiry
→ Quotation
→ Sales Order
→ Delivery
→ Completed Order
One customer may have multiple quotations.
One quotation may become one sales order.
One customer may have multiple sales orders.
________________________________________
7. Order Architecture
Order management shall be estimate driven.
Structure:
Customer
→ Quotation
→ Sales Order
→ Order Items
Example:
Quotation 700
•	King Cot
•	Dining Table
•	Chairs
•	Sofa
All items remain linked to the same order lifecycle.
________________________________________
8. Manufacturing Architecture
Furniture manufacturing shall be production-stage based.
The system shall track each stage independently.
Production tracking is the primary business requirement of this industry pack.
________________________________________
9. Standard Production Workflow
The initial production workflow shall be:
Raw Material
→ Cutting
→ Carpentry
→ Sanding
→ Sealer
→ Polishing
→ Painting / Varnish
→ Drying
→ Final Inspection
→ Ready For Delivery
→ Delivered
This workflow is derived from actual factory operations.
________________________________________
10. Production Tracking Philosophy
The system shall answer:
"Where is the customer's product right now?"
For every order the system shall display:
•	Current Stage
•	Previous Stage
•	Next Stage
•	Assigned Team
•	Expected Completion
•	Delay Status
This is the highest priority business objective.
________________________________________
11. Product Architecture
Products shall be managed using a catalog.
________________________________________
Product Categories
Examples:
•	Chairs
•	Dining
•	Cots
•	Sofas
Categories shall be configurable.
________________________________________
Product Variants
Products may contain:
Wood Type
Examples:
•	Teak
•	Rosewood
•	Mahogany
Design Variants
Examples:
•	Model A
•	Model B
Product Images
Product Specifications
Product Dimensions
________________________________________
12. Inventory Philosophy
The client does not operate as a finished-goods inventory business.
Primary inventory focus:
Raw Materials
Examples:
•	Timber
•	Wood Components
•	Hardware
•	Consumables
Inventory shall primarily support production execution.
________________________________________
13. Production Planning Philosophy
Production shall be planned against confirmed orders.
Sales Order
→ Production Order
→ Production Stages
The system shall support visibility of:
•	Active Jobs
•	Pending Jobs
•	Delayed Jobs
•	Completed Jobs
________________________________________
14. Delivery Architecture
Delivery represents the final operational stage.
Delivery States:
Pending
Ready
Dispatched
Delivered
Each order shall have delivery status visibility.
________________________________________
15. Management Visibility Requirements
Management requires visibility into:
Sales
Production
Deliveries
Inventory
Collections (Future)
Business Performance
These requirements were identified during discussions.
________________________________________
16. Dashboard Architecture
The Furniture Industry Pack shall initially support:
Owner Dashboard
Factory Dashboard
________________________________________
Owner Dashboard
Business summary view.
Examples:
Orders
Production Status
Deliveries
Revenue
Pending Orders
Delayed Orders
________________________________________
Factory Dashboard
Operational production view.
Examples:
Cutting Jobs
Carpentry Jobs
Sanding Jobs
Polishing Jobs
Ready Jobs
Delayed Jobs
Due Today
These requirements were explicitly requested.
________________________________________
17. User Persona Architecture
Initial personas identified.
Owner
Sales Executive
Factory Manager
Store Keeper
Administrator
Additional personas may be introduced later.
________________________________________
18. Furniture Industry Modules
The following modules are approved for MVP scope.
________________________________________
Furniture CRM
Purpose:
Manage customer interactions.
Capabilities:
Customers
Inquiries
Quotations
________________________________________
Furniture Sales
Purpose:
Manage order lifecycle.
Capabilities:
Sales Orders
Order Tracking
Order Status
________________________________________
Furniture Product Catalog
Purpose:
Manage furniture products.
Capabilities:
Categories
Products
Variants
Images
________________________________________
Furniture Manufacturing
Purpose:
Manage production execution.
Capabilities:
BOM
Production Orders
Production Tracking
Production Board
Production Timeline
________________________________________
Furniture Delivery
Purpose:
Manage dispatch and delivery.
Capabilities:
Dispatch
Delivery Tracking
Delivery Status
________________________________________
Furniture Dashboards
Purpose:
Operational and management visibility.
Capabilities:
Owner Dashboard
Factory Dashboard
KPI Monitoring
________________________________________
19. Industry Boundaries
The following capabilities are NOT part of MVP scope.
Purchase Management
Advanced Inventory Valuation
Finance
Accounting
Payroll
HR
Asset Management
AI Features
WhatsApp Integration
Advanced Workflow Designer
These may be introduced in future phases.
________________________________________
20. Success Criteria
The Furniture Manufacturing Industry Pack shall be considered successful when the organization can:
Create Customers
Create Quotations
Create Sales Orders
Track Production Stages
Monitor Factory Operations
Track Deliveries
View Business Dashboards
Answer customer status questions without relying on phone calls or manual follow-up.
________________________________________
21. July 2026 MVP Scope
Approved Modules:
Furniture CRM
Furniture Sales
Furniture Product Catalog
Furniture Manufacturing
Furniture Delivery
Furniture Dashboards
Platform Modules:
Authentication
Users
Roles
Permissions
Documents
Audit
Navigation
RBAC
Only these modules are approved for the initial MVP release.
________________________________________
22. Guiding Principle
The Furniture Manufacturing Industry Pack exists to provide a single source of truth for the complete furniture order lifecycle.
Customer Inquiry
→ Quotation
→ Sales Order
→ Production
→ Delivery
Every future screen, API, database table, workflow, report, and enhancement shall support and strengthen this lifecycle.
This document serves as the official Furniture Manufacturing Industry Architecture baseline for the FurniFlow Platform.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Furniture Manufacturing Module Catalog & Screen Inventory
Version: 1.0
Status: MVP Baseline
Industry:
Furniture Manufacturing
Purpose:
This document defines the official module catalog, screen inventory, ownership, purpose, and MVP implementation scope for the Furniture Manufacturing Industry Pack.
This document serves as the single source of truth for:
•	Module Planning
•	Screen Development
•	Flutter Routing
•	API Design
•	Database Design
•	Sprint Planning
•	Antigravity Development
Only screens defined in this document are approved for MVP implementation.
________________________________________
1. Module Classification
Modules are classified as:
Platform Modules
Furniture Industry Modules
Future Phase Modules
________________________________________
2. Platform Modules (MVP)
These modules are required by all implementations.
________________________________________
Module: Authentication
Module Code:
IAM
Purpose:
User Authentication
Screens:
IAM_LOGIN
IAM_CHANGE_PASSWORD
IAM_PROFILE
Total Screens: 3
________________________________________
Module: User Management
Module Code:
USR
Purpose:
Manage Users
Screens:
USR_LIST
USR_CREATE
USR_EDIT
USR_VIEW
Total Screens: 4
________________________________________
Module: Role Management
Module Code:
ROL
Purpose:
Manage Roles & Permissions
Screens:
ROL_LIST
ROL_CREATE
ROL_EDIT
ROL_PERMISSION_MAPPING
Total Screens: 4
________________________________________
Module: Document Management
Module Code:
DOC
Purpose:
Attachment Management
Screens:
DOC_UPLOAD
DOC_LIBRARY
DOC_VIEW
Total Screens: 3
________________________________________
Module: Audit
Module Code:
AUD
Purpose:
Audit Visibility
Screens:
AUD_LIST
AUD_VIEW
Total Screens: 2
________________________________________
3. Furniture CRM Module
Module Code:
FCRM
Purpose:
Manage Customers and Quotations
________________________________________
Screen: Customer List
Code:
CUS_LIST
Purpose:
Display all customers
Actor:
Sales Executive
Sales Manager
Owner
________________________________________
Screen: Customer Create
Code:
CUS_CREATE
Purpose:
Create Customer
________________________________________
Screen: Customer Edit
Code:
CUS_EDIT
Purpose:
Update Customer Information
________________________________________
Screen: Customer Details
Code:
CUS_VIEW
Purpose:
View Customer Information
________________________________________
Screen: Quotation List
Code:
QUO_LIST
Purpose:
Display Quotations
________________________________________
Screen: Create Quotation
Code:
QUO_CREATE
Purpose:
Create New Quotation
________________________________________
Screen: Quotation Details
Code:
QUO_VIEW
Purpose:
View Quotation
________________________________________
Screen: Quotation Conversion
Code:
QUO_CONVERT
Purpose:
Convert Quotation To Sales Order
________________________________________
Total Screens: 8
________________________________________
4. Furniture Product Catalog
Module Code:
FCAT
Purpose:
Manage Products
________________________________________
Screen: Product Category List
Code:
CAT_LIST
Purpose:
Manage Categories
________________________________________
Screen: Product Category Create
Code:
CAT_CREATE
Purpose:
Create Category
________________________________________
Screen: Product List
Code:
PRD_LIST
Purpose:
View Products
________________________________________
Screen: Product Create
Code:
PRD_CREATE
Purpose:
Create Product
________________________________________
Screen: Product Edit
Code:
PRD_EDIT
Purpose:
Update Product
________________________________________
Screen: Product Details
Code:
PRD_VIEW
Purpose:
View Product Information
________________________________________
Screen: Product Images
Code:
PRD_IMAGES
Purpose:
Manage Product Images
________________________________________
Total Screens: 7
________________________________________
5. Furniture Sales Module
Module Code:
FSAL
Purpose:
Manage Sales Orders
________________________________________
Screen: Sales Order List
Code:
SO_LIST
Purpose:
View Orders
________________________________________
Screen: Create Sales Order
Code:
SO_CREATE
Purpose:
Create Order
________________________________________
Screen: Sales Order Details
Code:
SO_VIEW
Purpose:
View Order
________________________________________
Screen: Sales Order Status
Code:
SO_STATUS
Purpose:
Track Order Status
________________________________________
Total Screens: 4
________________________________________
6. Furniture Manufacturing Module
Module Code:
FMFG
Purpose:
Manage Production Operations
Primary Business Requirement:
Track customer product status.
________________________________________
Screen: BOM List
Code:
BOM_LIST
Purpose:
Manage BOM Records
________________________________________
Screen: BOM Create
Code:
BOM_CREATE
Purpose:
Create BOM
________________________________________
Screen: Production Order List
Code:
PO_LIST
Purpose:
View Production Orders
________________________________________
Screen: Production Order Create
Code:
PO_CREATE
Purpose:
Generate Production Order
________________________________________
Screen: Production Order Details
Code:
PO_VIEW
Purpose:
View Production Order
________________________________________
Screen: Production Board
Code:
PO_BOARD
Purpose:
Kanban Style Production Tracking
Stages:
Cutting
Carpentry
Sanding
Sealer
Polishing
Painting
QC
Ready
________________________________________
Screen: Production Timeline
Code:
PO_TIMELINE
Purpose:
Production Scheduling View
________________________________________
Screen: Stage Tracking
Code:
PO_STAGE_TRACK
Purpose:
Update Stage Progress
________________________________________
Screen: Factory Dashboard
Code:
PO_FACTORY_DASHBOARD
Purpose:
Factory Operations Monitoring
________________________________________
Total Screens: 9
________________________________________
7. Furniture Delivery Module
Module Code:
FDLV
Purpose:
Manage Delivery Operations
________________________________________
Screen: Delivery List
Code:
DLV_LIST
Purpose:
View Deliveries
________________________________________
Screen: Dispatch Order
Code:
DLV_DISPATCH
Purpose:
Dispatch Order
________________________________________
Screen: Delivery Details
Code:
DLV_VIEW
Purpose:
View Delivery Information
________________________________________
Screen: Delivery Status
Code:
DLV_STATUS
Purpose:
Track Delivery Status
________________________________________
Total Screens: 4
________________________________________
8. Dashboard Module
Module Code:
FDSH
Purpose:
Management Visibility
________________________________________
Screen: Owner Dashboard
Code:
DSH_OWNER
Purpose:
Business Summary
________________________________________
Screen: Factory Dashboard
Code:
DSH_FACTORY
Purpose:
Production Visibility
________________________________________
Total Screens: 2
________________________________________
9. MVP Screen Summary
Platform Modules
Authentication: 3
User Management: 4
Role Management: 4
Document Management: 3
Audit: 2
Platform Total: 16
________________________________________
Furniture CRM: 8
Furniture Catalog: 7
Furniture Sales: 4
Furniture Manufacturing: 9
Furniture Delivery: 4
Furniture Dashboards: 2
Furniture Total: 34
________________________________________
Total MVP Screens
50
________________________________________
10. MVP User Personas
Owner
Sales Executive
Sales Manager
Factory Manager
Store Keeper
Administrator
________________________________________
11. MVP Navigation Structure
Dashboard
Owner Dashboard
Factory Dashboard
________________________________________
CRM
Customers
Quotations
________________________________________
Catalog
Categories
Products
________________________________________
Sales
Sales Orders
________________________________________
Manufacturing
BOM
Production Orders
Production Board
Production Timeline
Stage Tracking
________________________________________
Delivery
Dispatch
Deliveries
________________________________________
Administration
Users
Roles
Documents
Audit Logs
________________________________________
12. Future Phase Modules (Not MVP)
Purchase Management
Supplier Management
Inventory Valuation
Costing
Variance Analysis
Finance
Accounting
HR
Payroll
Asset Management
Quality Management
Advanced Reporting
Mobile Application
AI Assistant
WhatsApp Integration
________________________________________
13. Development Priority
Priority 1
Authentication
Users
Roles
Customers
Products
________________________________________
Priority 2
Quotations
Sales Orders
________________________________________
Priority 3
Production Orders
Production Tracking
Production Board
Factory Dashboard
________________________________________
Priority 4
Delivery
Owner Dashboard
Documents
Audit
________________________________________
14. Guiding Principle
Every screen in this inventory must directly support the furniture manufacturing lifecycle:
Customer
→ Quotation
→ Sales Order
→ Production Order
→ Production Tracking
→ Delivery
No MVP screen shall be implemented unless it contributes to this lifecycle or supports platform administration.
This document serves as the official Furniture Manufacturing Module Catalog and Screen Inventory baseline for the FurniFlow Platform.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Furniture Manufacturing Master Data Architecture
Version: 1.0
Status: Industry Baseline
Industry:
Furniture Manufacturing
Purpose:
This document defines the official master data architecture for the Furniture Manufacturing Industry Pack.
This document serves as the single source of truth for:
•	Reference Data
•	Dropdown Values
•	Product Classification
•	Production Classification
•	Status Management
•	Reporting Dimensions
•	API Reference Data
•	Database Master Tables
All future screens, APIs, reports, and database tables shall use the master data defined in this document.
________________________________________
1. Objectives
The master data architecture shall:
•	Standardize business data
•	Eliminate duplicate reference values
•	Support reporting consistency
•	Support future industry growth
•	Support SaaS deployment
•	Reduce hardcoded values
•	Improve data quality
________________________________________
2. Master Data Classification
Master data shall be classified as:
Platform Masters
Organization Masters
Furniture Industry Masters
System Masters
________________________________________
3. Platform Masters
Owned by Platform.
Reusable across all industries.
________________________________________
Countries
Purpose:
Geographic classification.
Examples:
India
UAE
Saudi Arabia
Qatar
Kuwait
________________________________________
States / Provinces
Purpose:
Regional classification.
________________________________________
Cities
Purpose:
Location classification.
________________________________________
Currencies
Examples:
INR
AED
USD
EUR
________________________________________
Units Of Measure (UOM)
Purpose:
Measurement standardization.
Initial Values:
Nos
Set
Piece
Kg
Litre
Meter
Square Feet
Cubic Feet
________________________________________
Document Types
Examples:
Product Image
Quotation Attachment
Sales Order Attachment
Production Document
Delivery Proof
General Document
________________________________________
4. Organization Masters
Owned by Organization.
________________________________________
Branches
Examples:
Chennai
Bangalore
Dubai
________________________________________
Departments
Initial Values:
Sales
Production
Inventory
Administration
Management
________________________________________
Designations
Examples:
Owner
Manager
Executive
Supervisor
Operator
Store Keeper
________________________________________
5. Furniture Industry Masters
Owned by Furniture Industry Pack.
________________________________________
5.1 Product Category Master
Purpose:
Classify products.
Initial Categories based on current business.
Examples:
Chair
Dining
Cot
Sofa
Additional categories shall be configurable.
________________________________________
5.2 Product Master
Purpose:
Maintain furniture catalog.
Each product shall contain:
Product Code
Product Name
Category
Description
Base Price
UOM
Image
Active Status
________________________________________
5.3 Wood Type Master
Purpose:
Classify wood material.
Examples identified during discussions.
Teak
Rosewood
Mahogany
Additional wood types shall be configurable.
No hardcoded limitation.
________________________________________
5.4 Product Variant Master
Purpose:
Support product variations.
Examples:
Model A
Model B
Future variants shall be configurable.
________________________________________
5.5 Production Stage Master
Purpose:
Control production workflow.
The initial workflow shall be based on actual factory operations.
Stages:
Raw Material
Cutting
Carpentry
Sanding
Sealer
Polishing
Painting / Varnish
Drying
Final Inspection
Ready For Delivery
Delivered
________________________________________
Rules:
Stages shall be ordered.
Display sequence shall be configurable.
Stage names shall not be hardcoded.
________________________________________
5.6 Delivery Status Master
Purpose:
Track delivery lifecycle.
Approved Values:
Pending
Ready
Dispatched
Delivered
________________________________________
5.7 Order Status Master
Purpose:
Track order lifecycle.
Approved Values:
Draft
Confirmed
In Production
Ready For Delivery
Delivered
Closed
Cancelled
________________________________________
5.8 Quotation Status Master
Purpose:
Track quotation lifecycle.
Approved Values:
Draft
Submitted
Approved
Rejected
Converted
Expired
________________________________________
5.9 Production Order Status Master
Purpose:
Track production order state.
Approved Values:
Draft
Released
In Progress
Completed
Cancelled
________________________________________
5.10 Customer Type Master
Purpose:
Classify customers.
Initial Values:
Individual
Business
Additional values may be added later.
________________________________________
6. System Masters
Controlled by Platform.
________________________________________
User Status
Active
Inactive
Locked
________________________________________
Role Status
Active
Inactive
________________________________________
Document Status
Active
Archived
Deleted
________________________________________
Notification Status
Unread
Read
Archived
________________________________________
7. Status Management Principles
All status values shall:
Be stored in master tables.
Not be hardcoded in UI.
Not be hardcoded in APIs.
Be configurable.
Be reportable.
________________________________________
8. Master Data Ownership
Platform Masters
Owned by Platform Administration.
________________________________________
Organization Masters
Owned by Organization Administration.
________________________________________
Furniture Industry Masters
Owned by Furniture Industry Configuration.
________________________________________
System Masters
Owned by Platform.
________________________________________
9. Master Data Governance
Every master shall contain:
id
code
name
description
display_order
is_active
created_on
created_by
updated_on
updated_by
________________________________________
10. Master Data Usage Rules
Dropdowns shall use master data.
Reports shall use master data.
Filters shall use master data.
APIs shall return master data.
No screen shall contain hardcoded business values.
________________________________________
11. Reporting Dimensions
The following masters shall be available for reporting:
Branch
Department
Product Category
Product
Wood Type
Customer Type
Production Stage
Order Status
Delivery Status
Quotation Status
________________________________________
12. Future Master Data Expansion
Future releases may introduce:
Supplier Types
Purchase Types
Warehouse Types
Cost Centers
Expense Categories
Quality Parameters
Finance Masters
These are not part of MVP scope.
________________________________________
13. MVP Frozen Master Data Scope
Platform Masters
Countries
States
Cities
Currencies
Units Of Measure
Document Types
________________________________________
Organization Masters
Branches
Departments
Designations
________________________________________
Furniture Masters
Product Categories
Products
Wood Types
Product Variants
Production Stages
Delivery Status
Order Status
Quotation Status
Production Order Status
Customer Types
________________________________________
14. Guiding Principle
Master data defines the language of the business.
Transactions shall reference master data.
Reports shall aggregate master data.
Workflows shall consume master data.
No transactional entity shall introduce duplicate reference values when a master already exists.
This document serves as the official Furniture Manufacturing Master Data Architecture baseline for the FurniFlow Platform.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Furniture Manufacturing User Personas, Roles & Responsibility Matrix
Version: 1.0
Status: Industry Baseline
Industry:
Furniture Manufacturing
Purpose:
This document defines the official user personas, role definitions, business responsibilities, workflow ownership, and operational accountability matrix for the Furniture Manufacturing Industry Pack.
This document serves as the single source of truth for:
•	User Personas
•	Business Roles
•	Workflow Ownership
•	Responsibility Assignment
•	Screen Ownership
•	Approval Ownership
•	Audit Accountability
•	Future RBAC Mapping
All future screens, APIs, workflows, and permissions shall align with this document.
________________________________________
1. Objectives
The role architecture shall:
•	Reflect actual business operations
•	Reduce dependency on specific employees
•	Establish clear accountability
•	Support RBAC implementation
•	Support workflow ownership
•	Support future scaling
________________________________________
2. Role Classification
Roles shall be classified as:
Platform Roles
Industry Roles
Operational Roles
________________________________________
3. Platform Roles
Provided by FurniFlow Platform.
________________________________________
Platform Administrator
Role Code:
PLATFORM_ADMIN
Purpose:
Platform configuration and administration.
Responsibilities:
•	Platform Setup
•	User Administration
•	Role Management
•	Permission Management
•	Module Enablement
•	Platform Monitoring
Business Ownership:
Platform Only
No operational business ownership.
________________________________________
4. Furniture Manufacturing Roles
The following roles are approved for MVP implementation.
________________________________________
Owner
Role Code:
OWNER
Purpose:
Business leadership and operational visibility.
Responsibilities:
•	Monitor overall business
•	Review production status
•	Review delivery status
•	Monitor customer commitments
•	Review business performance
Key Requirement:
Complete visibility across all business operations.
________________________________________
Sales Executive
Role Code:
SALES_EXEC
Purpose:
Customer engagement and order acquisition.
Responsibilities:
•	Create Customers
•	Manage Customer Information
•	Create Quotations
•	Update Quotations
•	Convert Quotations To Orders
•	Respond To Customer Queries
Primary Objective:
Provide accurate order status to customers without depending on factory phone calls.
________________________________________
Sales Manager
Role Code:
SALES_MGR
Purpose:
Sales supervision and order oversight.
Responsibilities:
•	Review Quotations
•	Monitor Sales Orders
•	Review Customer Pipeline
•	Monitor Delivery Commitments
•	Support Sales Team
________________________________________
Factory Manager
Role Code:
FACTORY_MGR
Purpose:
Manage production operations.
Responsibilities:
•	Review Production Orders
•	Monitor Production Progress
•	Assign Work
•	Monitor Delays
•	Manage Stage Completion
•	Monitor Daily Production
Primary Objective:
Provide real-time production visibility.
________________________________________
Store Keeper
Role Code:
STORE_KEEPER
Purpose:
Inventory and material visibility.
Responsibilities:
•	View Products
•	View Production Orders
•	Track Material Usage
•	Support Production Activities
MVP Scope:
Read-oriented operational role.
________________________________________
System Administrator
Role Code:
SYS_ADMIN
Purpose:
Organization-level system administration.
Responsibilities:
•	Create Users
•	Manage Roles
•	Manage Access
•	Configure Masters
•	Support Daily Operations
________________________________________
5. User Persona Definitions
________________________________________
Persona 1
Owner
Primary Goal:
Understand business health.
Typical Questions:
How many orders are pending?
Which orders are delayed?
What is today's production status?
What deliveries are pending?
Primary Screens:
Owner Dashboard
Factory Dashboard
Sales Orders
Production Board
Delivery Status
________________________________________
Persona 2
Sales Executive
Primary Goal:
Acquire customers and manage commitments.
Typical Questions:
What quotations are pending?
What orders are active?
Where is the customer's order?
When can delivery be expected?
Primary Screens:
Customers
Quotations
Sales Orders
Order Status
________________________________________
Persona 3
Factory Manager
Primary Goal:
Manage production flow.
Typical Questions:
Which jobs are in Cutting?
Which jobs are delayed?
Which jobs are due today?
What stage is each order in?
Primary Screens:
Production Orders
Production Board
Production Timeline
Stage Tracking
Factory Dashboard
________________________________________
Persona 4
Store Keeper
Primary Goal:
Support production execution.
Typical Questions:
Which products are active?
Which production orders are active?
What materials are required?
Primary Screens:
Products
Production Orders
Delivery Status
________________________________________
Persona 5
System Administrator
Primary Goal:
Manage platform operations.
Typical Questions:
Who has access?
Which roles exist?
Which permissions are assigned?
Primary Screens:
Users
Roles
Permissions
Audit Logs
________________________________________
6. Workflow Ownership Matrix
Customer Lifecycle
Owner:
Sales Executive
Supporting Role:
Sales Manager
________________________________________
Quotation Lifecycle
Owner:
Sales Executive
Supporting Role:
Sales Manager
________________________________________
Sales Order Lifecycle
Owner:
Sales Executive
Supporting Role:
Sales Manager
________________________________________
Production Lifecycle
Owner:
Factory Manager
Supporting Role:
Store Keeper
________________________________________
Delivery Lifecycle
Owner:
Factory Manager
Supporting Role:
Sales Executive
________________________________________
User Administration Lifecycle
Owner:
System Administrator
________________________________________
7. Screen Ownership Matrix
Customers
Primary Owner:
Sales Executive
Secondary Owner:
Sales Manager
________________________________________
Quotations
Primary Owner:
Sales Executive
Secondary Owner:
Sales Manager
________________________________________
Sales Orders
Primary Owner:
Sales Executive
Secondary Owner:
Sales Manager
________________________________________
Production Orders
Primary Owner:
Factory Manager
Secondary Owner:
Store Keeper
________________________________________
Production Board
Primary Owner:
Factory Manager
________________________________________
Stage Tracking
Primary Owner:
Factory Manager
________________________________________
Delivery
Primary Owner:
Factory Manager
Secondary Owner:
Sales Executive
________________________________________
Owner Dashboard
Primary Owner:
Owner
________________________________________
Factory Dashboard
Primary Owner:
Factory Manager
________________________________________
Users
Primary Owner:
System Administrator
________________________________________
Roles
Primary Owner:
System Administrator
________________________________________
8. Responsibility Matrix (RACI)
Legend:
R = Responsible
A = Accountable
C = Consulted
I = Informed
________________________________________
Customer Management
Owner: I
Sales Manager: A
Sales Executive: R
Factory Manager: I
Store Keeper: I
System Administrator: I
________________________________________
Quotation Management
Owner: I
Sales Manager: A
Sales Executive: R
Factory Manager: I
Store Keeper: I
System Administrator: I
________________________________________
Sales Orders
Owner: I
Sales Manager: A
Sales Executive: R
Factory Manager: C
Store Keeper: I
System Administrator: I
________________________________________
Production Tracking
Owner: I
Sales Manager: I
Sales Executive: I
Factory Manager: A/R
Store Keeper: C
System Administrator: I
________________________________________
Delivery Tracking
Owner: I
Sales Manager: C
Sales Executive: C
Factory Manager: A/R
Store Keeper: I
System Administrator: I
________________________________________
User Management
Owner: I
Sales Manager: I
Sales Executive: I
Factory Manager: I
Store Keeper: I
System Administrator: A/R
________________________________________
9. Audit Accountability
Every business transaction shall record:
Created By
Created On
Updated By
Updated On
Role
Department
The responsible role shall always be identifiable.
________________________________________
10. Default MVP Role Set
Approved Roles:
OWNER
SALES_EXEC
SALES_MGR
FACTORY_MGR
STORE_KEEPER
SYS_ADMIN
PLATFORM_ADMIN
No additional business roles shall be introduced during MVP implementation.
________________________________________
11. Future Role Expansion
Future phases may introduce:
Purchase Manager
Finance Manager
Production Supervisor
Quality Inspector
Delivery Coordinator
Inventory Manager
Customer Support Executive
These roles are not part of MVP scope.
________________________________________
12. Guiding Principle
Roles represent business responsibilities.
Permissions grant access.
Screens support responsibilities.
Workflows establish accountability.
Every future module, screen, API, report, and workflow shall have a clearly defined business owner based on this document.
This document serves as the official User Personas, Roles & Responsibility Matrix baseline for the Furniture Manufacturing Industry Pack.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Furniture Manufacturing End-to-End Business Process & Workflow Architecture
Version: 1.0
Status: Industry Workflow Baseline
Industry:
Furniture Manufacturing
Purpose:
This document defines the official end-to-end business processes, workflow lifecycles, status transitions, ownership transitions, and operational rules for the Furniture Manufacturing Industry Pack.
This document serves as the single source of truth for:
•	Business Processes
•	Workflow Definitions
•	Status Lifecycles
•	Ownership Lifecycles
•	Screen Behavior
•	Database State Models
•	API Workflows
•	Notifications
•	Audit Events
All future implementations shall comply with this workflow architecture.
________________________________________
1. Business Workflow Philosophy
The system shall provide complete visibility from:
Customer
→ Quotation
→ Sales Order
→ Production
→ Delivery
→ Completion
At any point in time the organization shall be able to determine:
•	Current Order Status
•	Current Production Stage
•	Delivery Readiness
•	Responsible Owner
This is the primary business objective.
________________________________________
2. End-to-End Business Lifecycle
Customer
→ Quotation
→ Sales Order
→ Production Order
→ Production Execution
→ Ready For Delivery
→ Delivery
→ Completed
Each stage shall be tracked independently.
________________________________________
3. Customer Lifecycle
Purpose:
Manage customer information.
Lifecycle:
Customer Created
→ Customer Active
→ Customer Updated
→ Customer Inactive
Owner:
Sales Executive
Supporting Role:
Sales Manager
________________________________________
4. Quotation Workflow
Purpose:
Capture customer requirements and proposed pricing.
Owner:
Sales Executive
________________________________________
Quotation Lifecycle
Draft
→ Submitted
→ Approved
→ Converted
Alternative Path:
Draft
→ Submitted
→ Rejected
Alternative Path:
Draft
→ Expired
________________________________________
Workflow Rules
Draft quotations may be edited.
Submitted quotations may be reviewed.
Converted quotations become Sales Orders.
Converted quotations shall remain available for audit.
________________________________________
5. Sales Order Workflow
Purpose:
Convert approved customer commitments into executable orders.
Owner:
Sales Executive
Supporting Role:
Sales Manager
________________________________________
Sales Order Lifecycle
Draft
→ Confirmed
→ In Production
→ Ready For Delivery
→ Delivered
→ Closed
Alternative Path:
Draft
→ Cancelled
Confirmed
→ Cancelled
________________________________________
Workflow Rules
Sales Orders shall originate from quotations.
One quotation may create one sales order.
Sales Orders shall contain one or more order items.
Production cannot begin until the order reaches Confirmed status.
________________________________________
6. Order Item Workflow
Purpose:
Track manufacturing at item level.
Example:
Sales Order
SO-1001
Contains:
King Cot
Dining Table
6 Chairs
Sofa
Each item shall remain linked to the parent order.
________________________________________
7. Production Workflow
Purpose:
Track manufacturing execution.
Owner:
Factory Manager
Primary Business Requirement:
Provide real-time visibility into product status.
________________________________________
Production Order Lifecycle
Draft
→ Released
→ In Progress
→ Completed
Alternative Path:
Draft
→ Cancelled
Released
→ Cancelled
________________________________________
Production Creation Rule
Confirmed Sales Order
→ Production Order
Production Orders shall not exist independently.
________________________________________
8. Standard Production Stage Workflow
The initial workflow shall follow actual factory operations.
Raw Material
→ Cutting
→ Carpentry
→ Sanding
→ Sealer
→ Polishing
→ Painting / Varnish
→ Drying
→ Final Inspection
→ Ready For Delivery
________________________________________
Workflow Rules
Stages shall execute sequentially.
A stage shall have:
Not Started
In Progress
Completed
The next stage may begin only after completion of the previous stage.
________________________________________
9. Production Stage Ownership
Raw Material
Owner:
Factory Manager
________________________________________
Cutting
Owner:
Factory Manager
________________________________________
Carpentry
Owner:
Factory Manager
________________________________________
Sanding
Owner:
Factory Manager
________________________________________
Sealer
Owner:
Factory Manager
________________________________________
Polishing
Owner:
Factory Manager
________________________________________
Painting / Varnish
Owner:
Factory Manager
________________________________________
Drying
Owner:
Factory Manager
________________________________________
Final Inspection
Owner:
Factory Manager
________________________________________
Ready For Delivery
Owner:
Factory Manager
________________________________________
10. Production Visibility Workflow
The system shall display:
Current Stage
Previous Stage
Next Stage
Stage Start Time
Stage Completion Time
Responsible User
Delay Indicator
Expected Completion
For every active production order.
________________________________________
11. Factory Dashboard Workflow
Purpose:
Operational Monitoring
Dashboard shall display:
Jobs In Cutting
Jobs In Carpentry
Jobs In Sanding
Jobs In Polishing
Jobs Due Today
Delayed Jobs
Completed Jobs
Pending Jobs
These requirements were explicitly identified.
________________________________________
12. Delivery Workflow
Purpose:
Manage dispatch and customer fulfillment.
Owner:
Factory Manager
Supporting Role:
Sales Executive
________________________________________
Delivery Lifecycle
Pending
→ Ready
→ Dispatched
→ Delivered
________________________________________
Workflow Rules
Only production-completed orders may become Ready.
Only Ready orders may be Dispatched.
Only Dispatched orders may become Delivered.
________________________________________
13. Customer Inquiry Workflow
Customer asks:
Where is my order?
Sales Executive opens Sales Order.
System displays:
Current Production Stage
Expected Delivery Date
Delay Status
Current Owner
Sales Executive shall not need to contact factory personnel to answer status queries.
________________________________________
14. Dashboard Workflow
Purpose:
Provide management visibility.
________________________________________
Owner Dashboard
Displays:
Total Orders
Orders In Production
Orders Ready For Delivery
Delivered Orders
Delayed Orders
Production Summary
________________________________________
Factory Dashboard
Displays:
Stage Counts
Pending Jobs
Delayed Jobs
Due Today
Completed Jobs
________________________________________
15. Audit Workflow
The following events shall be audited.
Customer Creation
Customer Update
Quotation Creation
Quotation Conversion
Sales Order Creation
Production Order Creation
Stage Update
Delivery Status Change
User Management
Role Management
________________________________________
16. Notification Events (MVP)
The following events shall generate in-app notifications.
Production Order Created
Production Completed
Delivery Ready
Delivery Dispatched
Delivery Completed
Future channels are out of scope.
________________________________________
17. Exception Workflow Rules
Cancelled Quotation
Cannot be Converted.
________________________________________
Cancelled Sales Order
Cannot enter Production.
________________________________________
Completed Production Order
Cannot return to Draft.
________________________________________
Delivered Order
Cannot return to In Production.
________________________________________
18. Workflow Ownership Matrix
Customer
Sales Executive
________________________________________
Quotation
Sales Executive
________________________________________
Sales Order
Sales Executive
________________________________________
Production Order
Factory Manager
________________________________________
Production Stages
Factory Manager
________________________________________
Delivery
Factory Manager
________________________________________
Users & Roles
System Administrator
________________________________________
19. Status Authority Matrix
Quotation Status
Sales Executive
________________________________________
Sales Order Status
Sales Executive
________________________________________
Production Status
Factory Manager
________________________________________
Stage Status
Factory Manager
________________________________________
Delivery Status
Factory Manager
________________________________________
User Status
System Administrator
________________________________________
20. Business KPIs Derived From Workflow
Orders Created
Orders Confirmed
Orders In Production
Orders Delayed
Orders Ready
Orders Delivered
Production Stage Counts
Average Production Duration
Average Delivery Duration
These KPIs shall be derived from workflow data.
________________________________________
21. MVP Workflow Scope
Approved Workflows:
Customer
Quotation
Sales Order
Production Order
Production Stages
Delivery
User Administration
Role Administration
No additional workflow shall be implemented during MVP without architecture review.
________________________________________
22. Guiding Principle
Every workflow exists to answer one business question:
"Where is the customer's product right now?"
Every status, screen, API, report, dashboard, and database table shall contribute to answering this question accurately and consistently.
This document serves as the official End-to-End Business Process & Workflow Architecture baseline for the Furniture Manufacturing Industry Pack.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Furniture Manufacturing Database Design (Logical Data Model)
Version: 1.0
Status: Architecture Baseline
Database:
PostgreSQL
Purpose:
This document defines the official logical database architecture for the FurniFlow Furniture Manufacturing Industry Pack.
This document serves as the single source of truth for:
•	Database Domains
•	Entity Relationships
•	Table Ownership
•	Primary Keys
•	Foreign Keys
•	Multi-Tenant Readiness
•	Audit Standards
•	Backend Generation
This document does not define physical column specifications. Physical table definitions shall be derived from this architecture.
________________________________________
1. Database Architecture Principles
The database shall be:
•	Multi-Tenant Ready
•	Industry Extensible
•	Audit Enabled
•	RBAC Compatible
•	API Friendly
•	UUID Based
•	Soft Delete Compatible
________________________________________
2. Database Domain Architecture
The database shall be organized into domains.
Platform Domain
Furniture Domain
Each domain owns its entities.
________________________________________
3. Platform Domain
Purpose:
Reusable across all industries.
________________________________________
Identity & Access Domain
Tables
users
roles
permissions
user_roles
role_permissions
________________________________________
Relationship
users
→ user_roles
→ roles
→ role_permissions
→ permissions
________________________________________
Organization Domain
Tables
tenants
organizations
branches
departments
________________________________________
Relationship
tenant
→ organizations
→ branches
→ departments
________________________________________
Navigation Domain
Tables
modules
screens
routes
industry_packs
industry_modules
industry_screens
________________________________________
Document Domain
Tables
documents
document_versions
________________________________________
Notification Domain
Tables
notifications
notification_recipients
________________________________________
Audit Domain
Tables
audit_logs
login_history
________________________________________
4. Master Data Domain
Purpose:
Reference Data
________________________________________
Tables
countries
states
cities
currencies
uoms
document_types
________________________________________
Furniture Masters
product_categories
wood_types
product_variants
production_stages
delivery_statuses
order_statuses
quotation_statuses
production_order_statuses
customer_types
________________________________________
5. Customer Domain
Purpose:
Customer Management
________________________________________
Tables
customers
customer_addresses
customer_contacts
customer_documents
________________________________________
Relationships
customer
→ addresses
customer
→ contacts
customer
→ documents
________________________________________
6. Product Catalog Domain
Purpose:
Product Management
________________________________________
Tables
products
product_images
product_variant_mappings
product_wood_type_mappings
________________________________________
Relationships
product
→ category
product
→ images
product
→ variants
product
→ wood types
________________________________________
7. Quotation Domain
Purpose:
Quotation Lifecycle
________________________________________
Tables
quotations
quotation_items
quotation_documents
________________________________________
Relationships
customer
→ quotations
quotation
→ quotation_items
quotation
→ documents
________________________________________
Business Rule
One quotation contains multiple quotation items.
________________________________________
8. Sales Domain
Purpose:
Sales Order Lifecycle
________________________________________
Tables
sales_orders
sales_order_items
sales_order_documents
________________________________________
Relationships
quotation
→ sales_order
sales_order
→ sales_order_items
sales_order
→ documents
________________________________________
Business Rule
One quotation may generate one sales order.
________________________________________
9. Manufacturing Domain
Purpose:
Production Management
________________________________________
Tables
boms
bom_items
production_orders
production_order_items
production_stage_logs
production_stage_history
________________________________________
Relationships
product
→ bom
bom
→ bom_items
sales_order
→ production_order
production_order
→ production_order_items
production_order
→ stage_logs
production_order
→ stage_history
________________________________________
Business Rule
Production Orders originate from Sales Orders.
________________________________________
10. Production Tracking Domain
Purpose:
Stage Visibility
________________________________________
Tables
production_stage_logs
production_stage_assignments
production_stage_history
________________________________________
Relationship
production_order
→ stage_logs
stage_log
→ assignments
stage_log
→ history
________________________________________
Purpose
Determine:
Current Stage
Previous Stage
Next Stage
Completion Status
Delay Status
________________________________________
11. Delivery Domain
Purpose:
Dispatch and Delivery
________________________________________
Tables
deliveries
delivery_items
delivery_documents
________________________________________
Relationships
sales_order
→ delivery
delivery
→ delivery_items
delivery
→ documents
________________________________________
Business Rule
Delivery begins only after production completion.
________________________________________
12. Dashboard Domain
Purpose:
Business Visibility
________________________________________
Tables
dashboard_configs
dashboard_widgets
dashboard_preferences
________________________________________
Business Rule
Dashboard data shall be derived from transactional entities.
No duplicate business data shall be stored.
________________________________________
13. Core Relationship Model
Customer
→ Quotations
→ Sales Orders
→ Production Orders
→ Deliveries
This relationship chain shall remain intact.
No module shall bypass this lifecycle.
________________________________________
14. Universal Table Standards
Every transactional table shall contain:
id
tenant_id
organization_id
created_by
created_on
updated_by
updated_on
is_active
remarks
________________________________________
Examples
customers
products
quotations
sales_orders
production_orders
deliveries
________________________________________
15. Primary Key Strategy
All entities shall use:
UUID
Example:
id UUID
No auto-increment keys shall be exposed externally.
________________________________________
16. Foreign Key Strategy
Every relationship shall be enforced through foreign keys.
Examples
customer_id
quotation_id
sales_order_id
production_order_id
delivery_id
product_id
________________________________________
17. Audit Strategy
Audit logs shall not replace transactional history.
Both are required.
________________________________________
Transaction History Example
production_stage_history
________________________________________
Audit Example
audit_logs
________________________________________
18. Soft Delete Strategy
Entities shall not be physically deleted.
Use:
is_active
Future:
deleted_on
deleted_by
________________________________________
19. Multi-Tenant Readiness
Every business entity shall contain:
tenant_id
Examples:
customers
products
quotations
sales_orders
production_orders
deliveries
Even if MVP initially supports a single tenant.
________________________________________
20. Industry Isolation Strategy
Platform Tables
Reusable
Industry Tables
Furniture Specific
Future industry packs shall create new domains without modifying platform tables.
________________________________________
21. July MVP Approved Tables
Platform
users
roles
permissions
user_roles
role_permissions
organizations
documents
audit_logs
________________________________________
Masters
product_categories
wood_types
production_stages
order_statuses
quotation_statuses
delivery_statuses
customer_types
uoms
________________________________________
Business
customers
customer_addresses
products
product_images
quotations
quotation_items
sales_orders
sales_order_items
boms
bom_items
production_orders
production_stage_logs
deliveries
delivery_items
________________________________________
22. Deferred Tables
Not MVP
purchase_orders
suppliers
inventory_transactions
stock_movements
finance_entries
costing_entries
variance_analysis
quality_inspections
asset_register
payroll
These tables shall not be implemented during MVP.
________________________________________
23. Guiding Principle
The database exists to support the business lifecycle:
Customer
→ Quotation
→ Sales Order
→ Production Order
→ Production Tracking
→ Delivery
Every entity shall contribute to this lifecycle.
Any table that does not support platform capabilities or the furniture manufacturing lifecycle requires architecture review before implementation.
This document serves as the official Logical Database Architecture baseline for the FurniFlow Furniture Manufacturing Industry Pack.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Physical Database Design & Table Specifications (04A)
Version: 1.0
Status: Physical Database Baseline
Database:
PostgreSQL 16+
Purpose:
This document defines the physical database standards, naming conventions, mandatory audit fields, primary key strategy, foreign key strategy, indexing standards, and MVP table specifications for FurniFlow.
This document serves as the single source of truth for database implementation.
________________________________________
1. Database Standards
Primary Key Standard
All tables shall use:
UUID
Example:
id UUID PRIMARY KEY
________________________________________
Audit Columns Standard
Every transactional table shall contain:
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
remarks TEXT
________________________________________
Multi-Tenant Standard
Every business table shall contain:
tenant_id UUID
organization_id UUID
________________________________________
Naming Standard
Table Names:
snake_case plural
Examples:
customers
sales_orders
production_orders
________________________________________
Column Names:
snake_case
Examples:
customer_name
quotation_date
production_status
________________________________________
2. Platform Tables
users
Purpose:
System Users
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
user_code VARCHAR(50)
first_name VARCHAR(100)
last_name VARCHAR(100)
email VARCHAR(255)
mobile_no VARCHAR(20)
password_hash TEXT
status VARCHAR(30)
last_login_on TIMESTAMP
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
email UNIQUE
user_code UNIQUE
________________________________________
roles
Purpose:
Role Registry
Columns:
id UUID PK
role_code VARCHAR(50)
role_name VARCHAR(150)
description TEXT
created_on TIMESTAMP
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
role_code UNIQUE
________________________________________
permissions
Columns:
id UUID PK
permission_code VARCHAR(150)
module_code VARCHAR(50)
screen_code VARCHAR(100)
action_code VARCHAR(50)
created_on TIMESTAMP
is_active BOOLEAN
Indexes:
permission_code UNIQUE
________________________________________
user_roles
Columns:
id UUID PK
user_id UUID FK
role_id UUID FK
assigned_on TIMESTAMP
assigned_by UUID
Indexes:
(user_id, role_id) UNIQUE
________________________________________
3. Customer Domain
customers
Purpose:
Customer Master
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
customer_code VARCHAR(50)
customer_name VARCHAR(255)
customer_type_id UUID
mobile_no VARCHAR(20)
email VARCHAR(255)
gst_no VARCHAR(50)
address_line_1 VARCHAR(255)
address_line_2 VARCHAR(255)
city_id UUID
state_id UUID
country_id UUID
postal_code VARCHAR(20)
notes TEXT
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
customer_code UNIQUE
mobile_no
customer_name
________________________________________
4. Product Domain
product_categories
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
category_code VARCHAR(50)
category_name VARCHAR(150)
display_order INTEGER
description TEXT
created_on TIMESTAMP
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
category_code UNIQUE
category_name
________________________________________
products
Purpose:
Furniture Products
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
product_code VARCHAR(50)
product_name VARCHAR(255)
category_id UUID
wood_type_id UUID
uom_id UUID
base_price NUMERIC(18,2)
description TEXT
product_image_url TEXT
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
product_code UNIQUE
product_name
category_id
________________________________________
5. Quotation Domain
quotations
Purpose:
Quotation Header
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
quotation_no VARCHAR(50)
customer_id UUID
quotation_date DATE
valid_until DATE
status_id UUID
total_amount NUMERIC(18,2)
remarks TEXT
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
quotation_no UNIQUE
customer_id
quotation_date
status_id
________________________________________
quotation_items
Columns:
id UUID PK
quotation_id UUID
product_id UUID
quantity NUMERIC(18,2)
unit_price NUMERIC(18,2)
line_total NUMERIC(18,2)
remarks TEXT
Indexes:
quotation_id
product_id
________________________________________
6. Sales Order Domain
sales_orders
Purpose:
Sales Order Header
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
sales_order_no VARCHAR(50)
quotation_id UUID
customer_id UUID
order_date DATE
expected_delivery_date DATE
status_id UUID
total_amount NUMERIC(18,2)
remarks TEXT
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
sales_order_no UNIQUE
customer_id
quotation_id
status_id
________________________________________
sales_order_items
Columns:
id UUID PK
sales_order_id UUID
product_id UUID
quantity NUMERIC(18,2)
unit_price NUMERIC(18,2)
line_total NUMERIC(18,2)
remarks TEXT
Indexes:
sales_order_id
product_id
________________________________________
7. BOM Domain
boms
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
bom_no VARCHAR(50)
product_id UUID
version_no INTEGER
effective_from DATE
effective_to DATE
created_on TIMESTAMP
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
bom_no UNIQUE
product_id
________________________________________
bom_items
Columns:
id UUID PK
bom_id UUID
material_name VARCHAR(255)
quantity NUMERIC(18,2)
uom_id UUID
remarks TEXT
Indexes:
bom_id
________________________________________
8. Manufacturing Domain
production_orders
Purpose:
Production Execution
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
production_order_no VARCHAR(50)
sales_order_id UUID
status_id UUID
planned_start_date DATE
planned_end_date DATE
actual_start_date DATE
actual_end_date DATE
remarks TEXT
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
production_order_no UNIQUE
sales_order_id
status_id
________________________________________
production_stage_logs
Purpose:
Stage Tracking
Columns:
id UUID PK
production_order_id UUID
stage_id UUID
status VARCHAR(30)
started_on TIMESTAMP
completed_on TIMESTAMP
assigned_user_id UUID
remarks TEXT
Indexes:
production_order_id
stage_id
assigned_user_id
________________________________________
9. Delivery Domain
deliveries
Purpose:
Dispatch Management
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
delivery_no VARCHAR(50)
sales_order_id UUID
delivery_status_id UUID
dispatch_date DATE
delivery_date DATE
remarks TEXT
created_by UUID
created_on TIMESTAMP
updated_by UUID
updated_on TIMESTAMP
is_active BOOLEAN
Indexes:
delivery_no UNIQUE
sales_order_id
delivery_status_id
________________________________________
delivery_items
Columns:
id UUID PK
delivery_id UUID
sales_order_item_id UUID
quantity NUMERIC(18,2)
remarks TEXT
Indexes:
delivery_id
sales_order_item_id
________________________________________
10. Document Domain
documents
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
entity_type VARCHAR(100)
entity_id UUID
document_name VARCHAR(255)
file_name VARCHAR(255)
file_path TEXT
file_size BIGINT
mime_type VARCHAR(100)
uploaded_by UUID
uploaded_on TIMESTAMP
Indexes:
entity_type
entity_id
________________________________________
11. Audit Domain
audit_logs
Columns:
id UUID PK
tenant_id UUID
organization_id UUID
entity_name VARCHAR(100)
entity_id UUID
action VARCHAR(50)
old_values JSONB
new_values JSONB
performed_by UUID
performed_on TIMESTAMP
ip_address VARCHAR(100)
Indexes:
entity_name
entity_id
performed_on
________________________________________
12. Mandatory Foreign Keys
customers.customer_type_id
→ customer_types.id
products.category_id
→ product_categories.id
products.wood_type_id
→ wood_types.id
quotations.customer_id
→ customers.id
quotation_items.quotation_id
→ quotations.id
quotation_items.product_id
→ products.id
sales_orders.quotation_id
→ quotations.id
sales_orders.customer_id
→ customers.id
sales_order_items.sales_order_id
→ sales_orders.id
sales_order_items.product_id
→ products.id
production_orders.sales_order_id
→ sales_orders.id
production_stage_logs.production_order_id
→ production_orders.id
deliveries.sales_order_id
→ sales_orders.id
delivery_items.delivery_id
→ deliveries.id
________________________________________
13. MVP Database Summary
Platform Tables: 4
Master Tables: 10+
Customer Tables: 1
Product Tables: 2
Quotation Tables: 2
Sales Tables: 2
BOM Tables: 2
Production Tables: 2
Delivery Tables: 2
Document Tables: 1
Audit Tables: 1
Total MVP Tables:
Approximately 30-35 tables
________________________________________
14. Guiding Principle
The database shall support the business lifecycle:
Customer
→ Quotation
→ Sales Order
→ Production Order
→ Production Tracking
→ Delivery
No table shall be created unless it directly supports:
1.	Platform Core
2.	Furniture Industry Workflow
3.	Future SaaS Readiness
This document serves as the official Physical Database Design baseline for FurniFlow MVP.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow API Specification & Service Contract
Version: 1.0
Status: API Baseline
Platform:
FurniFlow
Industry:
Furniture Manufacturing
Technology Stack:
Flutter + Golang (Fiber) + PostgreSQL
Purpose:
This document defines the official API architecture, endpoint standards, request/response contracts, authorization requirements, and service boundaries for the FurniFlow Platform.
This document serves as the single source of truth for:
•	Flutter Integration
•	Backend Development
•	API Security
•	Service Contracts
•	Third Party Integrations
•	Future Mobile Applications
All APIs shall comply with this document.
________________________________________
1. API Architecture Principles
The API architecture shall be:
•	REST Based
•	Resource Oriented
•	JWT Secured
•	Version Controlled
•	Tenant Aware
•	Organization Aware
•	RBAC Protected
•	Audit Enabled
________________________________________
2. API Base Structure
Base URL
/api/v1
Examples
/api/v1/customers
/api/v1/products
/api/v1/sales-orders
________________________________________
3. Authentication Standard
Every secured API shall require:
Authorization: Bearer {token}
________________________________________
Authentication Flow
Login
→ Access Token
→ Refresh Token
→ Authorized Requests
________________________________________
4. Common Request Headers
Authorization
Tenant-Id
Organization-Id
Content-Type
Accept
________________________________________
5. Standard API Response Contract
Success Response
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {},
  "errors": []
}
________________________________________
Error Response
{
  "success": false,
  "message": "Validation failed",
  "data": null,
  "errors": [
    "Customer name is required"
  ]
}
________________________________________
6. Pagination Contract
Request
{
  "page": 1,
  "page_size": 20
}
Response
{
  "page": 1,
  "page_size": 20,
  "total_records": 120,
  "total_pages": 6,
  "records": []
}
________________________________________
7. Authentication APIs
Module:
IAM
________________________________________
POST
/api/v1/auth/login
Purpose:
User Login
Permission:
Public
________________________________________
POST
/api/v1/auth/refresh-token
Purpose:
Generate New Access Token
Permission:
Authenticated User
________________________________________
POST
/api/v1/auth/logout
Purpose:
Logout
Permission:
Authenticated User
________________________________________
GET
/api/v1/auth/profile
Purpose:
Current User Information
Permission:
Authenticated User
________________________________________
PUT
/api/v1/auth/change-password
Purpose:
Change Password
Permission:
Authenticated User
________________________________________
8. User Management APIs
Module:
USR
________________________________________
GET
/api/v1/users
Permission:
USR.USR_LIST.VIEW
________________________________________
GET
/api/v1/users/{id}
Permission:
USR.USR_VIEW.VIEW
________________________________________
POST
/api/v1/users
Permission:
USR.USR_CREATE.CREATE
________________________________________
PUT
/api/v1/users/{id}
Permission:
USR.USR_EDIT.UPDATE
________________________________________
DELETE
/api/v1/users/{id}
Permission:
USR.USR_DELETE.DELETE
________________________________________
9. Role Management APIs
GET
/api/v1/roles
________________________________________
GET
/api/v1/roles/{id}
________________________________________
POST
/api/v1/roles
________________________________________
PUT
/api/v1/roles/{id}
________________________________________
POST
/api/v1/roles/{id}/permissions
Purpose:
Assign Permissions
________________________________________
10. Customer APIs
Module:
FCRM
________________________________________
GET
/api/v1/customers
Permission:
CUS.CUS_LIST.VIEW
________________________________________
GET
/api/v1/customers/{id}
Permission:
CUS.CUS_VIEW.VIEW
________________________________________
POST
/api/v1/customers
Permission:
CUS.CUS_CREATE.CREATE
________________________________________
PUT
/api/v1/customers/{id}
Permission:
CUS.CUS_EDIT.UPDATE
________________________________________
DELETE
/api/v1/customers/{id}
Permission:
CUS.CUS_DELETE.DELETE
________________________________________
11. Product Catalog APIs
GET
/api/v1/categories
________________________________________
POST
/api/v1/categories
________________________________________
PUT
/api/v1/categories/{id}
________________________________________
GET
/api/v1/products
________________________________________
GET
/api/v1/products/{id}
________________________________________
POST
/api/v1/products
________________________________________
PUT
/api/v1/products/{id}
________________________________________
DELETE
/api/v1/products/{id}
________________________________________
12. Quotation APIs
GET
/api/v1/quotations
Permission:
QUO.QUO_LIST.VIEW
________________________________________
GET
/api/v1/quotations/{id}
Permission:
QUO.QUO_VIEW.VIEW
________________________________________
POST
/api/v1/quotations
Permission:
QUO.QUO_CREATE.CREATE
________________________________________
PUT
/api/v1/quotations/{id}
Permission:
QUO.QUO_EDIT.UPDATE
________________________________________
POST
/api/v1/quotations/{id}/convert
Purpose:
Convert Quotation To Sales Order
Permission:
QUO.QUO_CONVERT.CREATE
________________________________________
13. Sales Order APIs
GET
/api/v1/sales-orders
Permission:
SO.SO_LIST.VIEW
________________________________________
GET
/api/v1/sales-orders/{id}
Permission:
SO.SO_VIEW.VIEW
________________________________________
POST
/api/v1/sales-orders
Permission:
SO.SO_CREATE.CREATE
________________________________________
PUT
/api/v1/sales-orders/{id}
Permission:
SO.SO_EDIT.UPDATE
________________________________________
GET
/api/v1/sales-orders/{id}/status
Permission:
SO.SO_STATUS.VIEW
________________________________________
14. BOM APIs
GET
/api/v1/bom
________________________________________
GET
/api/v1/bom/{id}
________________________________________
POST
/api/v1/bom
________________________________________
PUT
/api/v1/bom/{id}
________________________________________
DELETE
/api/v1/bom/{id}
________________________________________
15. Production Order APIs
GET
/api/v1/production-orders
Permission:
PO.PO_LIST.VIEW
________________________________________
GET
/api/v1/production-orders/{id}
Permission:
PO.PO_VIEW.VIEW
________________________________________
POST
/api/v1/production-orders
Permission:
PO.PO_CREATE.CREATE
________________________________________
PUT
/api/v1/production-orders/{id}
Permission:
PO.PO_EDIT.UPDATE
________________________________________
16. Production Board APIs
GET
/api/v1/production-board
Purpose:
Kanban Production View
Permission:
PO.PO_BOARD.VIEW
________________________________________
GET
/api/v1/production-board/summary
Purpose:
Dashboard Metrics
Permission:
PO.PO_BOARD.VIEW
________________________________________
17. Stage Tracking APIs
GET
/api/v1/production-orders/{id}/stages
Permission:
PO.PO_STAGE_TRACK.VIEW
________________________________________
PUT
/api/v1/production-orders/{id}/stages
Permission:
PO.PO_STAGE_TRACK.UPDATE
________________________________________
POST
/api/v1/production-orders/{id}/stages/start
Permission:
PO.PO_STAGE_TRACK.UPDATE
________________________________________
POST
/api/v1/production-orders/{id}/stages/complete
Permission:
PO.PO_STAGE_TRACK.UPDATE
________________________________________
18. Delivery APIs
GET
/api/v1/deliveries
Permission:
DLV.DLV_LIST.VIEW
________________________________________
GET
/api/v1/deliveries/{id}
Permission:
DLV.DLV_VIEW.VIEW
________________________________________
POST
/api/v1/deliveries
Permission:
DLV.DLV_CREATE.CREATE
________________________________________
PUT
/api/v1/deliveries/{id}
Permission:
DLV.DLV_EDIT.UPDATE
________________________________________
POST
/api/v1/deliveries/{id}/dispatch
Permission:
DLV.DLV_DISPATCH.UPDATE
________________________________________
POST
/api/v1/deliveries/{id}/complete
Permission:
DLV.DLV_STATUS.UPDATE
________________________________________
19. Dashboard APIs
GET
/api/v1/dashboard/owner
Permission:
DSH_OWNER.VIEW
________________________________________
GET
/api/v1/dashboard/factory
Permission:
DSH_FACTORY.VIEW
________________________________________
20. Document APIs
GET
/api/v1/documents
________________________________________
POST
/api/v1/documents/upload
________________________________________
GET
/api/v1/documents/{id}
________________________________________
DELETE
/api/v1/documents/{id}
________________________________________
21. Audit APIs
GET
/api/v1/audit-logs
Permission:
AUD.AUD_LIST.VIEW
________________________________________
GET
/api/v1/audit-logs/{id}
Permission:
AUD.AUD_VIEW.VIEW
________________________________________
22. Master Data APIs
GET
/api/v1/masters/customer-types
GET
/api/v1/masters/product-categories
GET
/api/v1/masters/wood-types
GET
/api/v1/masters/production-stages
GET
/api/v1/masters/order-statuses
GET
/api/v1/masters/delivery-statuses
GET
/api/v1/masters/uoms
________________________________________
23. Authorization Middleware Contract
Every secured API shall validate:
JWT Token
Tenant Context
Organization Context
Role Permission
Data Scope
________________________________________
Access Formula
Authenticated
AND
Tenant Valid
AND
Organization Valid
AND
Permission Granted
________________________________________
24. Audit Contract
The following actions shall automatically generate audit logs:
Create
Update
Delete
Status Change
Role Assignment
Permission Assignment
Login
Logout
________________________________________
25. Error Codes
200
Success
________________________________________
201
Created
________________________________________
400
Validation Error
________________________________________
401
Unauthorized
________________________________________
403
Forbidden
________________________________________
404
Not Found
________________________________________
409
Conflict
________________________________________
500
Server Error
________________________________________
26. MVP API Inventory
Authentication APIs: 5
User APIs: 5
Role APIs: 5
Customer APIs: 5
Product APIs: 8
Quotation APIs: 5
Sales APIs: 5
BOM APIs: 5
Production APIs: 4
Production Board APIs: 2
Stage Tracking APIs: 4
Delivery APIs: 6
Dashboard APIs: 2
Document APIs: 4
Audit APIs: 2
Master APIs: 7
Total MVP APIs:
Approximately 74 Endpoints
________________________________________
27. Guiding Principle
APIs expose business capabilities.
Permissions protect business capabilities.
Workflows govern business capabilities.
Every API shall directly support the furniture manufacturing lifecycle:
Customer
→ Quotation
→ Sales Order
→ Production Order
→ Production Tracking
→ Delivery
This document serves as the official API Specification & Service Contract baseline for the FurniFlow Platform and Furniture Manufacturing Industry Pack.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Furniture Manufacturing Role Permission Matrix
Version: 1.0
Status: Authorization Baseline
Industry:
Furniture Manufacturing
Purpose:
This document defines the official role-to-permission mapping for the Furniture Manufacturing Industry Pack.
This document serves as the single source of truth for:
•	RBAC Configuration
•	Menu Visibility
•	Screen Access
•	API Authorization
•	Action Permissions
•	Data Visibility Rules
All authorization decisions shall be derived from this document.
________________________________________
1. Permission Legend
V = View
C = Create
U = Update
D = Delete
A = Approve
X = No Access
________________________________________
2. Approved MVP Roles
PLATFORM_ADMIN
SYS_ADMIN
OWNER
SALES_MGR
SALES_EXEC
FACTORY_MGR
STORE_KEEPER
________________________________________
3. Platform Administration
Users
Screen	PLATFORM_ADMIN	SYS_ADMIN	OWNER	SALES_MGR	SALES_EXEC	FACTORY_MGR	STORE_KEEPER
User List	VCUDA	VCUDA	V	X	X	X	X
Create User	C	C	X	X	X	X	X
Edit User	U	U	X	X	X	X	X
Assign Roles	A	A	X	X	X	X	X
________________________________________
Roles & Permissions
Screen	PLATFORM_ADMIN	SYS_ADMIN	OWNER	Others
Role List	VCUDA	VCUDA	V	X
Permission Mapping	VCUDA	VCUDA	X	X
________________________________________
Audit Logs
Screen	PLATFORM_ADMIN	SYS_ADMIN	OWNER	Others
Audit List	V	V	V	X
Audit Details	V	V	V	X
________________________________________
4. Customer Management
Customer List
Role	Permission
OWNER	V
SALES_MGR	VCUDA
SALES_EXEC	VCUD
FACTORY_MGR	V
STORE_KEEPER	V
SYS_ADMIN	V
________________________________________
Customer Details
Role	Permission
OWNER	V
SALES_MGR	VCUDA
SALES_EXEC	VCUD
FACTORY_MGR	V
STORE_KEEPER	V
SYS_ADMIN	V
________________________________________
5. Quotation Management
Quotation List
Role	Permission
OWNER	V
SALES_MGR	VCUDA
SALES_EXEC	VCUD
FACTORY_MGR	V
SYS_ADMIN	V
________________________________________
Create Quotation
Role	Permission
SALES_MGR	CUA
SALES_EXEC	CU
OWNER	V
Others	X
________________________________________
Convert Quotation To Order
Role	Permission
SALES_MGR	A
SALES_EXEC	C
OWNER	V
Others	X
________________________________________
6. Product Catalog
Categories
Role	Permission
SYS_ADMIN	VCUD
OWNER	V
SALES_MGR	V
SALES_EXEC	V
FACTORY_MGR	V
STORE_KEEPER	V
________________________________________
Products
Role	Permission
SYS_ADMIN	VCUD
OWNER	V
SALES_MGR	V
SALES_EXEC	V
FACTORY_MGR	V
STORE_KEEPER	V
________________________________________
7. Sales Orders
Sales Order List
Role	Permission
OWNER	V
SALES_MGR	VCUDA
SALES_EXEC	VCUD
FACTORY_MGR	V
STORE_KEEPER	V
SYS_ADMIN	V
________________________________________
Create Sales Order
Role	Permission
SALES_MGR	CUA
SALES_EXEC	CU
OWNER	V
Others	X
________________________________________
Sales Order Status
Role	Permission
OWNER	V
SALES_MGR	VU
SALES_EXEC	VU
FACTORY_MGR	VU
STORE_KEEPER	V
SYS_ADMIN	V
________________________________________
8. BOM Management
BOM List
Role	Permission
OWNER	V
FACTORY_MGR	VCUD
STORE_KEEPER	V
SYS_ADMIN	V
Others	X
________________________________________
BOM Create
Role	Permission
FACTORY_MGR	VCUD
Others	X
________________________________________
9. Production Orders
Production Order List
Role	Permission
OWNER	V
FACTORY_MGR	VCUDA
STORE_KEEPER	V
SALES_MGR	V
SALES_EXEC	V
SYS_ADMIN	V
________________________________________
Create Production Order
Role	Permission
FACTORY_MGR	CUA
Others	X
________________________________________
Production Order Details
Role	Permission
OWNER	V
FACTORY_MGR	VCUDA
STORE_KEEPER	V
SALES_MGR	V
SALES_EXEC	V
SYS_ADMIN	V
________________________________________
10. Production Board
Production Board
Role	Permission
OWNER	V
FACTORY_MGR	VCUDA
STORE_KEEPER	V
SALES_MGR	V
SALES_EXEC	V
SYS_ADMIN	V
________________________________________
11. Production Stage Tracking
Stage Tracking
Role	Permission
FACTORY_MGR	VCUDA
STORE_KEEPER	V
OWNER	V
SALES_MGR	V
SALES_EXEC	V
SYS_ADMIN	V
________________________________________
Stage Status Update
Role	Permission
FACTORY_MGR	U
Others	X
________________________________________
12. Delivery Management
Delivery List
Role	Permission
OWNER	V
FACTORY_MGR	VCUDA
SALES_MGR	V
SALES_EXEC	V
STORE_KEEPER	V
SYS_ADMIN	V
________________________________________
Dispatch Order
Role	Permission
FACTORY_MGR	U
Others	X
________________________________________
Delivery Status Update
Role	Permission
FACTORY_MGR	U
Others	X
________________________________________
13. Dashboards
Owner Dashboard
Role	Permission
OWNER	V
SYS_ADMIN	V
PLATFORM_ADMIN	V
________________________________________
Factory Dashboard
Role	Permission
OWNER	V
FACTORY_MGR	V
SYS_ADMIN	V
________________________________________
14. Document Management
Document Upload
Role	Permission
SYS_ADMIN	VCUD
SALES_MGR	CU
SALES_EXEC	CU
FACTORY_MGR	CU
OWNER	V
________________________________________
Document Library
Role	Permission
OWNER	V
SYS_ADMIN	VCUDA
SALES_MGR	V
SALES_EXEC	V
FACTORY_MGR	V
STORE_KEEPER	V
________________________________________
15. Data Scope Matrix
PLATFORM_ADMIN
Scope:
All Tenants
________________________________________
SYS_ADMIN
Scope:
Entire Organization
________________________________________
OWNER
Scope:
Entire Organization
Read Visibility Across All Modules
________________________________________
SALES_MGR
Scope:
All Sales Data
All Customers
All Quotations
All Sales Orders
________________________________________
SALES_EXEC
Scope:
Own Records
Own Customers
Own Quotations
Own Sales Orders
________________________________________
FACTORY_MGR
Scope:
All Production Data
All Deliveries
All BOM Records
________________________________________
STORE_KEEPER
Scope:
Read Only Production Visibility
Read Only Product Visibility
Read Only Delivery Visibility
________________________________________
16. Menu Visibility Matrix
Dashboard
OWNER
FACTORY_MGR
SYS_ADMIN
________________________________________
Customers
OWNER
SALES_MGR
SALES_EXEC
FACTORY_MGR
STORE_KEEPER
________________________________________
Quotations
OWNER
SALES_MGR
SALES_EXEC
________________________________________
Products
All Roles
________________________________________
Sales Orders
OWNER
SALES_MGR
SALES_EXEC
FACTORY_MGR
STORE_KEEPER
________________________________________
Manufacturing
OWNER
FACTORY_MGR
STORE_KEEPER
________________________________________
Delivery
OWNER
FACTORY_MGR
SALES_MGR
SALES_EXEC
________________________________________
Administration
PLATFORM_ADMIN
SYS_ADMIN
________________________________________
17. API Authorization Rule
Every API shall map to:
Permission Code
Example:
CUS.CUS_LIST.VIEW
Required For:
GET /api/customers
________________________________________
QUO.QUO_CREATE.CREATE
Required For:
POST /api/quotations
________________________________________
FMFG.PO_STAGE_TRACK.UPDATE
Required For:
PUT /api/production-stage/{id}
________________________________________
18. MVP Frozen Role Matrix
Approved Roles:
PLATFORM_ADMIN
SYS_ADMIN
OWNER
SALES_MGR
SALES_EXEC
FACTORY_MGR
STORE_KEEPER
No additional business roles shall be introduced during MVP implementation without architecture review.
________________________________________
19. Guiding Principle
Roles represent responsibilities.
Permissions represent actions.
Menus represent authorized capabilities.
Data scope represents visibility.
A user shall only see:
Authorized Modules
+
Authorized Screens
+
Authorized Actions
+
Authorized Data
This document serves as the official Role Permission Matrix baseline for the FurniFlow Furniture Manufacturing Industry Pack.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow UI Navigation Map & Route Registry
Version: 1.0
Status: UI Architecture Baseline
Platform:
FurniFlow
Industry:
Furniture Manufacturing
Purpose:
This document defines the official UI navigation structure, route registry, menu hierarchy, breadcrumb hierarchy, route permissions, and frontend navigation standards.
This document serves as the single source of truth for:
•	Flutter Routing
•	Sidebar Navigation
•	Menu Generation
•	Route Guards
•	Breadcrumbs
•	Screen Registration
•	Dynamic Navigation
No route, screen, or menu shall be implemented outside this registry.
________________________________________
1. Navigation Principles
Navigation shall be:
•	Dynamic
•	Role Driven
•	Permission Driven
•	Industry Aware
•	Module Based
•	Breadcrumb Enabled
Menus shall never be hardcoded.
________________________________________
2. Navigation Hierarchy
Industry
→ Module
→ Screen
Example:
Furniture Manufacturing
→ CRM
→ Customers
→ Quotations
→ Sales
    → Sales Orders

→ Manufacturing
    → Production Orders
    → Stage Tracking
________________________________________
3. Route Naming Standard
Format:
/module/screen
Examples:
/customers/list
/products/list
/quotations/create
/sales-orders/list
/production-orders/list
________________________________________
4. Authentication Routes
Module:
IAM
________________________________________
Login
Route Code:
IAM_LOGIN
Path:
/login
Permission:
Public
________________________________________
Change Password
Route Code:
IAM_CHANGE_PASSWORD
Path:
/profile/change-password
Permission:
Authenticated User
________________________________________
Profile
Route Code:
IAM_PROFILE
Path:
/profile
Permission:
Authenticated User
________________________________________
5. Dashboard Routes
Module:
FDSH
________________________________________
Owner Dashboard
Route Code:
DSH_OWNER
Path:
/dashboard/owner
Roles:
OWNER
SYS_ADMIN
PLATFORM_ADMIN
________________________________________
Factory Dashboard
Route Code:
DSH_FACTORY
Path:
/dashboard/factory
Roles:
OWNER
FACTORY_MGR
SYS_ADMIN
________________________________________
6. Customer Management Routes
Module:
FCRM
________________________________________
Customer List
Route Code:
CUS_LIST
Path:
/customers
Permission:
CUS.CUS_LIST.VIEW
________________________________________
Customer Create
Route Code:
CUS_CREATE
Path:
/customers/create
Permission:
CUS.CUS_CREATE.CREATE
________________________________________
Customer Edit
Route Code:
CUS_EDIT
Path:
/customers/{id}/edit
Permission:
CUS.CUS_EDIT.UPDATE
________________________________________
Customer View
Route Code:
CUS_VIEW
Path:
/customers/{id}
Permission:
CUS.CUS_VIEW.VIEW
________________________________________
7. Quotation Routes
Module:
FCRM
________________________________________
Quotation List
Route Code:
QUO_LIST
Path:
/quotations
Permission:
QUO.QUO_LIST.VIEW
________________________________________
Create Quotation
Route Code:
QUO_CREATE
Path:
/quotations/create
Permission:
QUO.QUO_CREATE.CREATE
________________________________________
Quotation View
Route Code:
QUO_VIEW
Path:
/quotations/{id}
Permission:
QUO.QUO_VIEW.VIEW
________________________________________
Quotation Convert
Route Code:
QUO_CONVERT
Path:
/quotations/{id}/convert
Permission:
QUO.QUO_CONVERT.CREATE
________________________________________
8. Product Catalog Routes
Module:
FCAT
________________________________________
Category List
Route Code:
CAT_LIST
Path:
/categories
Permission:
CAT.CAT_LIST.VIEW
________________________________________
Category Create
Route Code:
CAT_CREATE
Path:
/categories/create
Permission:
CAT.CAT_CREATE.CREATE
________________________________________
Product List
Route Code:
PRD_LIST
Path:
/products
Permission:
PRD.PRD_LIST.VIEW
________________________________________
Product Create
Route Code:
PRD_CREATE
Path:
/products/create
Permission:
PRD.PRD_CREATE.CREATE
________________________________________
Product Edit
Route Code:
PRD_EDIT
Path:
/products/{id}/edit
Permission:
PRD.PRD_EDIT.UPDATE
________________________________________
Product View
Route Code:
PRD_VIEW
Path:
/products/{id}
Permission:
PRD.PRD_VIEW.VIEW
________________________________________
9. Sales Order Routes
Module:
FSAL
________________________________________
Sales Order List
Route Code:
SO_LIST
Path:
/sales-orders
Permission:
SO.SO_LIST.VIEW
________________________________________
Sales Order Create
Route Code:
SO_CREATE
Path:
/sales-orders/create
Permission:
SO.SO_CREATE.CREATE
________________________________________
Sales Order View
Route Code:
SO_VIEW
Path:
/sales-orders/{id}
Permission:
SO.SO_VIEW.VIEW
________________________________________
Sales Order Status
Route Code:
SO_STATUS
Path:
/sales-orders/{id}/status
Permission:
SO.SO_STATUS.UPDATE
________________________________________
10. BOM Routes
Module:
FMFG
________________________________________
BOM List
Route Code:
BOM_LIST
Path:
/bom
Permission:
BOM.BOM_LIST.VIEW
________________________________________
BOM Create
Route Code:
BOM_CREATE
Path:
/bom/create
Permission:
BOM.BOM_CREATE.CREATE
________________________________________
11. Production Order Routes
Module:
FMFG
________________________________________
Production Order List
Route Code:
PO_LIST
Path:
/production-orders
Permission:
PO.PO_LIST.VIEW
________________________________________
Production Order Create
Route Code:
PO_CREATE
Path:
/production-orders/create
Permission:
PO.PO_CREATE.CREATE
________________________________________
Production Order View
Route Code:
PO_VIEW
Path:
/production-orders/{id}
Permission:
PO.PO_VIEW.VIEW
________________________________________
12. Production Tracking Routes
Module:
FMFG
________________________________________
Production Board
Route Code:
PO_BOARD
Path:
/production-board
Permission:
PO.PO_BOARD.VIEW
________________________________________
Production Timeline
Route Code:
PO_TIMELINE
Path:
/production-timeline
Permission:
PO.PO_TIMELINE.VIEW
________________________________________
Stage Tracking
Route Code:
PO_STAGE_TRACK
Path:
/production-orders/{id}/stages
Permission:
PO.PO_STAGE_TRACK.UPDATE
________________________________________
13. Delivery Routes
Module:
FDLV
________________________________________
Delivery List
Route Code:
DLV_LIST
Path:
/deliveries
Permission:
DLV.DLV_LIST.VIEW
________________________________________
Dispatch Order
Route Code:
DLV_DISPATCH
Path:
/deliveries/{id}/dispatch
Permission:
DLV.DLV_DISPATCH.UPDATE
________________________________________
Delivery View
Route Code:
DLV_VIEW
Path:
/deliveries/{id}
Permission:
DLV.DLV_VIEW.VIEW
________________________________________
Delivery Status
Route Code:
DLV_STATUS
Path:
/deliveries/{id}/status
Permission:
DLV.DLV_STATUS.UPDATE
________________________________________
14. Administration Routes
Module:
USR
ROL
AUD
DOC
________________________________________
Users
Path:
/admin/users
Permission:
USR.USR_LIST.VIEW
________________________________________
Roles
Path:
/admin/roles
Permission:
ROL.ROL_LIST.VIEW
________________________________________
Audit Logs
Path:
/admin/audit
Permission:
AUD.AUD_LIST.VIEW
________________________________________
Documents
Path:
/admin/documents
Permission:
DOC.DOC_LIST.VIEW
________________________________________
15. Sidebar Navigation Structure
Dashboard
Owner Dashboard
Factory Dashboard
CRM
Customers
Quotations
Catalog
Categories
Products
Sales
Sales Orders
Manufacturing
BOM
Production Orders
Production Board
Production Timeline
Stage Tracking
Delivery
Deliveries
Administration
Users
Roles
Documents
Audit Logs
________________________________________
16. Breadcrumb Structure
Example
Customer Details
Home
→ CRM
→ Customers
→ Customer Details
________________________________________
Sales Order Details
Home
→ Sales
→ Sales Orders
→ Order Details
________________________________________
Production Stage Tracking
Home
→ Manufacturing
→ Production Orders
→ Stage Tracking
________________________________________
17. Route Guard Rules
Every route shall validate:
Authentication
Permission
Tenant Context
Organization Context
________________________________________
Route Access Formula
Authenticated User
AND
Permission Granted
AND
Tenant Valid
AND
Organization Valid
________________________________________
18. Unauthorized Route Handling
Unauthorized Access
→ 403 Page
Unauthenticated Access
→ Login Page
Route Not Found
→ 404 Page
________________________________________
19. Dynamic Menu Generation
Menus shall be generated using:
Industry Pack
Module Registry
Role Permissions
Enabled Modules
Enabled Screens
No hardcoded visibility checks shall exist in Flutter UI.
________________________________________
20. MVP Frozen Route Count
Authentication: 3
Dashboards: 2
Customers: 4
Quotations: 4
Catalog: 6
Sales Orders: 4
BOM: 2
Production Orders: 3
Production Tracking: 3
Delivery: 4
Administration: 4
Total MVP Routes:
39
________________________________________
21. Guiding Principle
A route represents a business capability.
A menu represents an authorized capability.
A user shall only see routes that are:
Enabled
+
Authorized
+
Industry Applicable
This document serves as the official UI Navigation Map and Route Registry baseline for the FurniFlow Platform and Furniture Manufacturing Industry Pack.

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

FurniFlow Antigravity Development Blueprint & Execution Plan
Version: 1.0
Status: Development Baseline
Platform:
FurniFlow Enterprise Platform
Industry Pack:
Furniture Manufacturing
Technology Stack:
Flutter
Golang (Fiber)
PostgreSQL
Purpose:
This document defines the official development execution strategy, repository structure, coding standards, module implementation sequence, database migration strategy, Antigravity prompting standards, and release roadmap.
This document serves as the single source of truth for all development activities.
________________________________________
1. Development Philosophy
Build Platform First.
Build Industry Pack Second.
Build Client Features Third.
Never build screens directly.
Always build:
Database
→ API
→ Service
→ UI
in that order.
________________________________________
2. MVP Goal
Target Date:
10 July
Objective:
Deliver a working furniture manufacturing ERP MVP.
Must Support:
Authentication
Users
Roles
Customers
Products
Quotations
Sales Orders
Production Orders
Production Tracking
Deliveries
Dashboards
Documents
Audit
________________________________________
3. Repository Strategy
Recommended:
Separate Repositories
________________________________________
Frontend
furniflow-web
Flutter
________________________________________
Backend
furniflow-api
Golang
________________________________________
Database
furniflow-db
SQL Scripts
Migration Scripts
________________________________________
Documentation
furniflow-docs
Architecture Documents
________________________________________
4. Backend Architecture
Pattern:
Clean Architecture
________________________________________
Structure
cmd
internal
modules
shared
pkg
migrations
docs
________________________________________
5. Module Structure Standard
Example
customers
customers/
├── handler
├── service
├── repository
├── dto
├── model
├── validator
├── mapper
Every module shall follow identical structure.
________________________________________
6. Flutter Architecture
Pattern:
Feature First
________________________________________
lib/
core/
features/
shared/
routes/
services/
widgets/
________________________________________
Feature Example
customers/
customers_list
customers_create
customers_detail
customers_provider
customers_service
________________________________________
7. Database Migration Strategy
Use:
golang-migrate
________________________________________
Migration Naming
001_create_users.sql
002_create_roles.sql
003_create_permissions.sql
________________________________________
Never modify existing migrations.
Create new migration files.
________________________________________
8. Environment Strategy
Environment Files
local
dev
uat
prod
________________________________________
Variables
DB_HOST
DB_PORT
DB_NAME
JWT_SECRET
REDIS_HOST
MINIO_ENDPOINT
________________________________________
9. Authentication Development
Build First
Tables
users
roles
permissions
user_roles
role_permissions
________________________________________
Deliverables
Login API
JWT
Refresh Token
Role Authorization
Menu Authorization
________________________________________
10. Seed Data Strategy
Required Seed Data
Platform Admin
Roles
Permissions
Master Data
Industry Pack Configuration
________________________________________
Seed Scripts Must Be Repeatable.
________________________________________
11. Development Sequence
Phase 1
Platform Core
________________________________________
Authentication
Users
Roles
Permissions
Navigation
Documents
Audit
________________________________________
Phase 2
Furniture CRM
________________________________________
Customers
Quotations
________________________________________
Phase 3
Sales
________________________________________
Sales Orders
Order Tracking
________________________________________
Phase 4
Manufacturing
________________________________________
BOM
Production Orders
Production Tracking
Production Board
________________________________________
Phase 5
Delivery
________________________________________
Deliveries
Dispatch
Status Tracking
________________________________________
Phase 6
Dashboards
________________________________________
Owner Dashboard
Factory Dashboard
________________________________________
12. API Development Rules
Every API Must Have
DTO
Validator
Service
Repository
Permission Mapping
Audit Logging
Swagger Documentation
________________________________________
No Direct Database Calls From Handlers.
________________________________________
13. Flutter Development Rules
Every Screen Must Have
Page
Provider / Bloc
API Service
Models
Permission Guard
Loading State
Error State
________________________________________
No Direct API Calls Inside Widgets.
________________________________________
14. RBAC Implementation Strategy
Login
→ Get User
→ Get Roles
→ Get Permissions
→ Generate Menu
________________________________________
Menus Must Come From API.
Never Hardcode Menus.
________________________________________
15. Dynamic Menu Strategy
After Login
Call:
GET /api/v1/navigation/menu
Response:
Modules
Screens
Permissions
Routes
Flutter Generates Menu Dynamically.
________________________________________
16. Antigravity Development Rules
Every Prompt Must Reference:
01 Platform Architecture
02 Data Architecture
02A Module Registry
02B RBAC
02C Navigation
03 Furniture Architecture
04 Database Design
05 API Specification
06 Role Matrix
07 Route Registry
________________________________________
Never Generate Code Without Referencing Architecture Documents.
________________________________________
17. Antigravity Module Prompt Template
Implement Module:
Customer Management
Follow:
Platform Architecture
RBAC Architecture
Database Design
API Specification
Route Registry
Generate:
PostgreSQL Tables
Golang Models
Repositories
Services
Handlers
DTOs
Validators
Swagger
Flutter Screens
Routing
Permission Guards
Unit Tests
Follow Existing Project Structure.
Do Not Create New Architecture Patterns.
________________________________________
18. Development Ownership
Developer 1
Platform Core
Authentication
RBAC
Navigation
Database
________________________________________
Developer 2
Furniture Modules
Customers
Products
Quotations
Orders
Production
Delivery
________________________________________
If Solo:
Follow Development Sequence Exactly.
________________________________________
19. Daily Development Cycle
Morning
Architecture Review
________________________________________
Generate Module Prompt
________________________________________
Antigravity Code Generation
________________________________________
Review Code
________________________________________
Fix Issues
________________________________________
Commit
________________________________________
Repeat
________________________________________
20. Git Strategy
Branches
main
develop
feature/*
________________________________________
Examples
feature/auth
feature/customers
feature/products
feature/production
________________________________________
Merge Process
Feature
→ Develop
→ Main
________________________________________
21. Testing Strategy
Every Module Must Include
Unit Tests
API Tests
Permission Tests
Validation Tests
________________________________________
Critical Areas
Authentication
RBAC
Production Tracking
Delivery Tracking
________________________________________
22. Deployment Strategy
Local
Docker Compose
________________________________________
Server
Docker Compose
________________________________________
Future
Kubernetes
________________________________________
Containers
flutter-web
api
postgres
redis
minio
________________________________________
23. July 10 Release Scope
Platform Core
Authentication
Users
Roles
Permissions
________________________________________
CRM
Customers
Quotations
________________________________________
Sales
Orders
________________________________________
Manufacturing
BOM
Production Orders
Stage Tracking
Production Board
________________________________________
Delivery
Dispatch
Deliveries
________________________________________
Dashboards
Owner Dashboard
Factory Dashboard
________________________________________
24. Post MVP Roadmap
Phase 2
Inventory
Purchase
Suppliers
________________________________________
Phase 3
Finance
Costing
Accounting
________________________________________
Phase 4
Multi Tenant SaaS
Tenant Provisioning
Subscription Management
________________________________________
Phase 5
Industry Packs
Garments
Steel
Construction
________________________________________
25. Architecture Freeze Rule
No developer shall:
Add Tables
Add Modules
Add Routes
Add Permissions
Add APIs
without updating the architecture documents.
Architecture Documents remain the source of truth.
Code must follow architecture.
Architecture must never follow code.
________________________________________
26. Definition Of Done
A module is complete only when:
Database Complete
Migration Complete
API Complete
Swagger Complete
RBAC Complete
Audit Complete
UI Complete
Navigation Complete
Testing Complete
Documentation Complete
________________________________________
27. Final Guiding Principle
Build FurniFlow as a Platform.
Do not build a Furniture ERP.
Furniture is the first Industry Pack.
Every decision made during development must support future industry packs without rewriting platform foundations.
This document serves as the official Antigravity Development Blueprint & Execution Plan for FurniFlow.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


