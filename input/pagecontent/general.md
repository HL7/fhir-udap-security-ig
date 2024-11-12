This section contains general guidance applicable to multiple authorization and authentication workflows.

### Authorization code flow

The constraints in the following subsections apply to all workflows utilizing the authorization code flow.

#### The state parameter
A Client application **SHALL** include the `state` parameter in its authorization request. An Authorization Server **SHALL** return an error code of `invalid_request` as per Section 4.1.2.1 of RFC 6749 if a client application does not include a `state` value in its authorization request.

Servers **SHALL** include the `state` parameter and corresponding value provided by the client application in the authorization response as per RFC 6749. The client application **SHALL NOT** proceed if the `state` parameter is not included in the authorization response or its value does not match the value provided by the client application in the corresponding authorization request.
### Proof Key for Code Exchange (PKCE)

Client applications and Authorization Servers **SHALL** utilize Proof Key for Code Exchange (PKCE) with `code_challenge_method` of `S256` as defined in RFC 7636. An Authorization Server **SHOULD** return an error as per Section 4.4.1 of RFC 7636 if a client application does not include a `code_challenge` is its authorization request. 

The Authorization Server **SHALL** return an error in response to a token request as per Section 4.6 of RFC 7636 if the client included a `code_challenge` in its authorization request but did not include the correct `code_verfier` value in the corresponding token request.

### Scope negotiation

STU2 Draft Notes: The following constraints are adapted from the TEFCA Faciliated FHIR SOP. Some of the constraints in that SOP conflict with constraints found elsewhere in this IG, or relate to requirements in other IGs such as the SMART App Launch IG. This will need to be resolved prior to STU2 publication.
{:.bg-info}

A wildcard scope is a scope that can be alternatively represented as a set of non-wildcard scopes. An example of a wildcard scope is the SMART App Launch v1.0.0 scope `patient/Observation.*` which can expanded to the set of two non-wildcard scopes: `patient/Observation.read` and `patient/Observation.write`. Granting the wildcard scope to a client application is equivalent to granting the corresponding expanded set of non-wildcard scopes.


The constraints enumerated below apply for scope negotiation between client applications and servers. Unless otherwise specified, these constraints apply for both registration requests and access token requests made by client applications, and the corresponding responses returned by servers.

1. The `scopes_supported` metadata **SHALL** be present in the .well-known/smartconfiguration or .well-known/udap object, as applicable, and **SHALL** list all scopes supported including all supported wildcard scopes.
Note: `scopes_supported` is currently optional in the Discovery section of this guide. References to SMART specific content should be removed.
{:bg-info}
1. Client applications and servers **MAY** support wildcard scopes.
1. A client application **MAY** request a wildcard scope only if wildcards are specified in the server's `scopes_supported` metadata list.
1. If a client application requests a wildcard scope and the server supports wildcards, then the server **SHOULD** return either the wildcard scope or an expanded set of scopes that the client has been granted in its response.
1. If a client application requests a wildcard scope and the server does **NOT** support wildcard scopes, then the server **SHOULD** respond with an error of “invalid_scope”.
Note: invalid_client_metadata is the corresponding registration request error.
{:bg-info}
1. If a server supports OIDC or SMART App Launch scopes, the server **SHOULD** put the corresponding scopes (e.g. "openid", "offline_access", "email", "fhirUser", etc.) in their `scopes_supported` metadata.
1. A server **MAY** grant fewer scopes than requested by the client application if the client application cannot have a scope specified in the request based on technical or policy guidelines at the responding organization or if the server does not recognize one or more of the requested scopes.
1. A server **SHOULD** respond with “invalid_scope” only if a wildcard scope is requested and not supported, or if none of the requested scopes are supported.
Note: invalid_client_metadata is the corresponding registration request error.
{:bg-info}
1. At the time of a token request, an authorization server **MAY** grant additional scopes that are not in the set of scopes requested by the client application if the application has been registered with the server with a different set of scopes than was requested at registration based on technical or policy guidelines at the responding organization.
1. The scopes granted by a server to a client application at the time of an access token request **MAY** be the same as the set from registration or **MAY** be a subset.
1. The scopes granted by a server to a client application at the time of an access token request **MAY** be the same as the set of scopes requested by the client application or **MAY** be a subset.
1. An application **SHOULD** be able to receive a superset of the scopes requested if the server’s policies dictate that a request with a certain system or user/user role is granted specific scopes that are not part of the original request.
1. A server **SHOULD** return “invalid_scope” only if none of the scopes requested are available and/or not part of the scopes requested during registration.
Note: invalid_client_metadata is the corresponding registration request error.
{:bg-info}
1. A server **SHALL** include the `scope` parameter in a token response if the set of scopes granted by the server to the client application is not identical to the set of scopes requested by the client application, or if the client application does not include a set of requested scopes in its request.