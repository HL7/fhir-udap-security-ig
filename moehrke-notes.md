# Notes by John Moehrke

IG CI - https://build.fhir.org/ig/HL7/fhir-udap-security-ig/index.html

## Issues

- There is no use-case documentation. What is the problem that this IG is trying to solve or support?
- There is no overall flow diagram that shows the relationship of the Discovery, Registration, and Authorization steps
- on the AA pages, there are single step flow diagrams, but the multiple steps are not shown in a single diagram. This makes it difficult to understand how the steps relate to each other and to the overall flow.
- How would one combine FAST Security and SMART App Launch OAuth flows?
  - can one combine the well-known configuration for both? This was presented as a possible simplification by Josh.
- I understand the need to use OAuth terms (Authorization Code Flow, ) The introduction should present these in use-case terms without OAuth jargon. 
  - For example, "A client application needs to obtain permission from a user to access their health data. This process involves several steps, including discovering the necessary endpoints, registering the application, and obtaining authorization from the user."
- Similarly the four menus under "Authorization and Authentication" are never explained in the text. They are just there. The text should explain what they are and how they relate to the overall flow.
- Possible FHIR artifact, even as informative, would be an AuditEvent or set of AuditEvent that represent relevant security events in the flow. For example, an AuditEvent for discovery, registration, and authorization steps. This would be useful for implementers to understand what events to log and how to log them.

## Reference Implementation

- Joe Shook [UDAP Ed](https://udaped.fhirlabs.net/)
- Joe Shook [Reference Implementation for .NET](https://github.com/udap-tools/udap-dotnet)
- [HL7-FAST / udap - FAST Security RI](https://udap-security.fast.hl7.org/docs/guides/integration/)
- [UDAP - Security.FAST.hl7.org](https://udap-security.fast.hl7.org/)

### Tutorial

- [TEFCA SOP Facilitated FHIR Implementation](https://rce.sequoiaproject.org/wp-content/uploads/2026/02/SOP-Facilitated-FHIR-Implementation-2.0-Draft-508.pdf)
- Joe Shook [Set up a local UDAP playground, which includes a FHIR server, a static certificates server, a UDAP Auth Server, and a UDAP IDP Server.](https://github.com/JoeShook/udap-dotnet-tutorial)
- 
- 
## Testing

- [UDAP.org test tool](https://www.udap.org/UDAPTestTool/)

## Overall Flow


### FAST UDAP Tiered OAuth (User-present Authorization Code)

```mermaid
sequenceDiagram
    participant User
    participant Client as UDAP Client
    participant AS as Authorization Server (UDAP Tiered OAuth)
    participant FHIR as FHIR Resource Server

    Client->>Client: Retrieve UDAP Metadata (Signed Software Statement)
    Client->>AS: Present UDAP Metadata (Client Identity)
    AS->>Client: Trust Established (Client Registered/Recognized)

    User->>Client: Launch App
    Client->>AS: Authorization Request (client_id, redirect_uri, scope, state, PKCE)
    AS->>User: Authenticate User
    User->>AS: Credentials + Consent
    AS->>Client: Redirect with Authorization Code

    Client->>AS: Token Request (code, PKCE verifier, UDAP client assertion)
    AS->>Client: Access Token (+ optional ID Token if OIDC)

    Client->>FHIR: FHIR API Request (Bearer access_token)
    FHIR->>Client: FHIR Resource Response
```

### FAST UDAP B2B (Client Credentials, No User)

```mermaid
sequenceDiagram
    participant Client as UDAP Client
    participant AS as Authorization Server (UDAP B2B)
    participant FHIR as FHIR Resource Server

    Client->>Client: Create UDAP JWT (Signed with Client Certificate)
    Client->>AS: Token Request (grant_type=client_credentials, UDAP JWT)
    AS->>AS: Validate Certificate, Trust Chain, Metadata
    AS->>Client: Access Token (B2B system identity)

    Client->>FHIR: FHIR API Request (Bearer access_token)
    FHIR->>Client: FHIR Resource Response
```
### FAST UDAP Dynamic Client Registration (UDAP DCR)

```mermaid
sequenceDiagram
    participant Client as UDAP Client
    participant AS as Authorization Server (UDAP DCR)

    Client->>Client: Create Software Statement (Signed Metadata)
    Client->>AS: Registration Request (Software Statement)
    AS->>AS: Validate Signature, Certificate, Trust Anchor
    AS->>Client: Registration Response (client_id, metadata accepted)
```

### SMART App Launch: OAuth → OIDC → SMART App Launch

```mermaid
sequenceDiagram
    participant User
    participant App as SMART App
    participant AS as Authorization Server (OAuth + OIDC)
    participant FHIR as FHIR Server

    User->>App: Launch App (Standalone or EHR Launch)
    App->>AS: Authorization Request (client_id, redirect_uri, scope, state, nonce, PKCE)
    AS->>User: Authenticate User (Login UI)
    User->>AS: Credentials + Consent
    AS->>App: Redirect with Authorization Code + state

    App->>AS: Token Request (code, redirect_uri, PKCE verifier)
    AS->>App: ID Token + Access Token + Refresh Token

    App->>AS: (Optional) UserInfo Request
    AS->>App: User Claims

    App->>FHIR: FHIR API Request (Authorization: Bearer access_token)
    FHIR->>App: FHIR Resource Response

```

### SMART Backend Services (Bulk Data)

```mermaid
sequenceDiagram
    participant Client as Backend Service
    participant AS as Authorization Server (OAuth)
    participant FHIR as FHIR Server

    Client->>Client: Create JWT Client Assertion
    Client->>AS: Token Request (grant_type=client_credentials, JWT assertion, system/*.read)
    AS->>Client: Access Token (system-level)

    Client->>FHIR: FHIR API Request (Authorization: Bearer access_token)
    FHIR->>Client: FHIR Resource Response

```

### Bulk Data Access - Flat FHIR

```mermaid
sequenceDiagram
    participant Client as Backend Service
    participant AS as Authorization Server
    participant FHIR as FHIR Server
    participant Storage as Bulk Data File Store

    Client->>Client: Create JWT Client Assertion
    Client->>AS: Token Request (client_credentials, JWT assertion, system/*.read)
    AS->>Client: Access Token

    Client->>FHIR: $export Request (Authorization: Bearer access_token)
    FHIR->>Client: 202 Accepted + Content-Location (status URL)

    loop Poll Until Complete
        Client->>FHIR: GET status URL
        FHIR->>Client: 202 In Progress
    end

    FHIR->>Client: 200 OK + Output File URLs

    Client->>Storage: Download NDJSON Files
    Storage->>Client: NDJSON Data
```


### Combined FAST Security + SMART App Launch

- FAST Security provides trust.
- OAuth provides authorization.
- OIDC provides user identity.
- SMART App Launch provides healthcare semantics.
- All four stack cleanly in a single flow.

```mermaid
sequenceDiagram
    participant User
    participant Client as SMART App (UDAP-enabled)
    participant AS as Authorization Server (FAST UDAP + OAuth + OIDC)
    participant FHIR as FHIR Server (FAST Security)

    %% --- UDAP Trust Bootstrap ---
    Client->>Client: Retrieve UDAP Metadata (Signed Software Statement)
    Client->>AS: Present UDAP Metadata (Client Identity)
    AS->>AS: Validate Certificate, Trust Chain, Metadata
    AS->>Client: Trust Established (Client recognized)

    %% --- SMART App Launch Begins ---
    User->>Client: Launch SMART App (Standalone or EHR Launch)

    %% --- OAuth Authorization Request ---
    Client->>AS: Authorization Request\n(client_id, redirect_uri, scope, state, nonce, PKCE)

    %% --- User Authentication (OIDC) ---
    AS->>User: Authenticate User (Login UI)
    User->>AS: Credentials + Consent

    %% --- Authorization Code Returned ---
    AS->>Client: Redirect with Authorization Code + state

    %% --- Token Exchange (OAuth + UDAP) ---
    Client->>AS: Token Request\n(code, redirect_uri, PKCE verifier, UDAP client assertion)
    AS->>AS: Validate PKCE, Code, UDAP Assertion
    AS->>Client: Access Token + ID Token + Refresh Token

    %% --- Optional OIDC UserInfo ---
    Client->>AS: UserInfo Request (optional)
    AS->>Client: User Claims

    %% --- SMART Launch Context + FHIR Access ---
    Client->>FHIR: FHIR API Request\n(Authorization: Bearer access_token)
    FHIR->>Client: FHIR Resource Response
```

1. UDAP happens first (trust + client identity)
FAST Security ensures the SMART app is:
   - trusted
   - registered
   - certificate-bound
   - validated via signed metadata
   - This is pre‑OAuth.
1. OAuth Authorization Code Flow runs normally
UDAP does not change the OAuth protocol.
The SMART app performs a standard Authorization Code Flow with PKCE.
1. OIDC provides user identity
OIDC adds:
   - ID Token
   - nonce
   - UserInfo (optional)
   - SMART requires this because launch context is tied to the authenticated user.
1. SMART App Launch adds healthcare semantics
SMART adds:
   - launch context (patient, encounter, etc.)
   - SMART scopes (patient/*.read, user/*.read, etc.)
   - SMART discovery metadata
1. FHIR Server enforces FAST Security
The FHIR server:
   - validates the access token
   - enforces scopes
   - enforces trust policies
   - returns FHIR resources

### UDAP Success Path

```mermaid
sequenceDiagram
    autonumber
    participant Client as Client App (Requestor)
    participant RS as Resource Server (FHIR Server)
    participant DAS as Downstream AS (Responder)
    participant UAS as Upstream AS (The IdP)
    participant TA as Trust Anchor (Root CA)

    Note over Client, RS: Phase 1: Discovery & Registration
    Client->>RS: GET /.well-known/udap
    RS-->>Client: Signed Metadata (Includes DAS endpoints + Cert)
    Note right of Client: Validates DAS Cert via Trust Anchor
    
    Client->>DAS: POST /register (Signed Software Statement)
    DAS-->>Client: 201 Created (client_id)

    Note over Client, UAS: Phase 2: Tiered Authorization (OIDC)
    Client->>DAS: /authorize (with 'idp' hint)
    
    rect rgb(240, 240, 240)
        Note right of DAS: DAS acts as a UDAP Client to the Upstream IdP
        DAS->>UAS: GET /.well-known/udap (Discovery)
        UAS-->>DAS: Signed Metadata + Cert
        DAS->>UAS: POST /register (Dynamic Registration)
        UAS-->>DAS: client_id for DAS
    end

    DAS->>UAS: Redirect User for Auth
    Note right of UAS: User Authenticates
    UAS-->>DAS: ID Token + Auth Code
    
    Note over Client, DAS: Phase 3: Token Exchange
    DAS-->>Client: Auth Code
    Client->>DAS: POST /token (Signed JWT Client Assertion)
    DAS-->>Client: Access Token (JWT) + ID Token

    Note over Client, RS: Phase 4: Resource Access
    Client->>RS: GET /Patient/123 (Bearer [Token])
    Note right of RS: RS validates Token (often via DAS Introspection)
    RS-->>Client: 200 OK (FHIR Resource)
```

clarified AS

Summary of the Handshake
1. Client discovers Resource AS.
2. Resource AS discovers IdP AS.
3. IdP AS authenticates the User.
4. Resource AS issues the Token based on that authentication.

Resource Server accepts the Token and serves the data.

```mermaid
sequenceDiagram
    autonumber
    participant Client as Client Application
    participant RS as Resource Server (FHIR API)
    participant RAS as Resource AS (The Data Holder's AS)
    participant IAS as IdP AS (The User's Identity AS)
    participant TA as Trust Anchor (CA)

    Note over Client, RS: Phase 1: Discovery of the Data Source
    Client->>RS: GET /.well-known/udap
    RS-->>Client: Signed Metadata (Points to Resource AS)
    Note right of Client: Validates Resource AS Cert via Trust Anchor

    Note over Client, RAS: Phase 2: Dynamic Client Registration
    Client->>RAS: POST /register (Signed Software Statement)
    RAS-->>Client: 201 Created (client_id issued)

    Note over Client, IAS: Phase 3: Tiered Authorization (OIDC)
    Client->>RAS: /authorize (Request + 'idp' hint)
    
    rect rgb(240, 240, 240)
        Note right of RAS: Resource AS now acts as a Client to the IdP AS
        RAS->>IAS: GET /.well-known/udap (Discovery)
        IAS-->>RAS: Signed Metadata + Cert
        RAS->>IAS: POST /register (Dynamic Registration)
        IAS-->>RAS: client_id for the Resource AS
    end

    RAS->>IAS: Redirect User for Authentication
    Note right of IAS: User logs in (OIDC)
    IAS-->>RAS: ID Token + Auth Code
    
    Note over Client, RAS: Phase 4: Final Token Exchange
    RAS-->>Client: Auth Code
    Client->>RAS: POST /token (Signed JWT Client Assertion)
    RAS-->>Client: Access Token (JWT) + ID Token

    Note over Client, RS: Phase 5: Data Retrieval
    Client->>RS: GET /Patient/123 (Bearer Token)
    Note right of RS: RS validates Token with Resource AS
    RS-->>Client: 200 OK (FHIR Resource)
```

more refined

```mermaid
sequenceDiagram
    autonumber
    participant Client as Requestor (Client App)
    participant RS as Resource Server (FHIR API)
    participant RAS as Resource AS (Data Holder AS)
    participant IAS as Identity AS (User's IdP)
    participant TA as Trust Anchor (e.g. TEFCA CA)

    Note over Client, RS: Phase 1: Discovery & Registration
    Client->>RS: GET /.well-known/udap
    RS-->>Client: Signed UDAP Metadata (Points to RAS)
    Note right of Client: Client validates RAS Cert via Trust Anchor
    Client->>RAS: POST /register (Signed Software Statement)
    RAS-->>Client: 201 Created (client_id)

    Note over Client, IAS: Phase 2: Tiered Authorization (The "FAST" Handshake)
    Client->>RAS: GET /authorize?idp=[IAS_URL]&scope=udap+openid...
    
    rect rgb(240, 248, 255)
    Note right of RAS: RAS uses UDAP to trust the Identity AS
    RAS->>IAS: GET /.well-known/udap (Discovery)
    IAS-->>RAS: Signed Metadata + IAS Certificate
    RAS->>IAS: POST /register (Dynamic Registration)
    IAS-->>RAS: client_id for the Resource AS
    end

    Note over RAS, IAS: Phase 3: Identity Verification (OIDC)
    RAS->>IAS: Redirect User to /authorize (scope=openid+udap)
    Note right of IAS: User Logs In
    IAS-->>RAS: Auth Code
    RAS->>IAS: POST /token (Signed JWT Auth)
    IAS-->>RAS: ID Token (User Identity)

    Note over Client, RAS: Phase 4: Final Token Issuance
    RAS-->>Client: Auth Code
    Client->>RAS: POST /token (Signed Client Assertion)
    RAS-->>Client: Access Token + ID Token

    Note over Client, RS: Phase 5: Data Access
    Client->>RS: GET /Patient/123 (Bearer Token)
    Note right of RS: RS Introspects Token with RAS
    RS-->>Client: 200 OK (FHIR Resource)
```
