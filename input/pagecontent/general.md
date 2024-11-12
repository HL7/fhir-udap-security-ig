This section contains general guidance applicable to multiple authorization and authentication workflows.

### Authorization code flow

The constraints in the following subsections apply to all workflows utilizing the authorization code flow.

#### The state parameter
A Client application **SHALL** include the `state` parameter in its authorization request. An Authorization Server **SHALL** return an error code of `invalid_request` as per Section 4.1.2.1 of RFC 6749 if a client application does not include a `state` value in its authorization request.

Servers **SHALL** include the `state` parameter and corresponding value provided by the client application in the authorization response as per RFC 6749. The client application **SHALL NOT** proceed if the `state` parameter is not included in the authorization response or its value does not match the value provided by the client application in the corresponding authorization request.

#### Proof Key for Code Exchange (PKCE)

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

### Certification template for client applications

This section provides a template for a UDAP Certification that can be used by client applications or third parties to declare additional information about the client application at the time of registration.

A client application or third party **MAY** construct a certification by constructing a signed JWT as detailed in this section. The certification **SHALL** contain the required header elements specified in [Section 1.2.3] of this guide and the JWT claims listed in the table below. The certification **SHALL** be signed by the client application operator or by a third party using the signature algorithm identified in the `alg` header of the certification and with the private key that corresponds to the public key listed in the client’s X.509 certificate identified in the `x5c` header of the certification.

<table class="table">
  <thead>
    <th colspan="3">Client Application Certification JWT Claims</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issuer of the JWT -- unique identifying URI of the signing entity. This <strong>SHALL</strong> match the value of a uniformResourceIdentifier entry in the Subject Alternative Name extension of the signer's certificate included in the <code>x5c</code> JWT header and <strong>SHALL</strong> uniquely identify a single signing entity over time.
      </td>
    </tr>
    <tr>
      <td><code>sub</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Subject of the JWT -- unique identifying client URI. This <strong>SHALL</strong> match the value of a uniformResourceIdentifier entry in the Subject Alternative Name extension of the client's certificate and <strong>SHALL</strong> uniquely identify a single client app operator and applications over time.
        For a self-signed certification, this is same as <code>iss</code>.
      </td>
    </tr>
    <tr>
      <td><code>aud</code></td>
      <td><span class="label label-warning">optional</span></td>
      <td>
        The "registration URL" of the intended Authorization server(s), i.e. the same URL to which the registration request will be posted. If absent, this certification is intended for all Authorization Servers. The value can be a single string or array of strings.
      </td>
    </tr>
    <tr>
      <td><code>exp</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Expiration time integer for this software statement, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC). The <code>exp</code> time <strong>SHALL</strong> be no more than 3 years after the value of the <code>iat</code> claim.
      </td>
    </tr>
    <tr>
      <td><code>iat</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issued time integer for this software statement, expressed in seconds since the "Epoch"
      </td>
    </tr>
    <tr>
      <td><code>jti</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A nonce string value that uniquely identifies this software statement. See <a href="index.html#jwt-claims">Section 1.2.4</a> for additional requirements regarding reuse of values.
      </td>
    </tr>
    <tr>
      <td><code>certification_name</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        string with fixed value: "HL7 Basic Client App Certification"
      </td>
    </tr>
    <tr>
      <td><code>certification_uris</code></td>
      <td><span class="label label-warning">required</span></td>
      <td>
        array of one string with fixed value: ["TBD"]
      </td>
    </tr>
    <tr>
      <td><code>grant_types</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Array of strings, each representing a requested grant type, from the following list: <code>"authorization_code"</code>, <code>"refresh_token"</code>, <code>"client_credentials"</code>. The array <strong>SHALL</strong> include either <code>"authorization_code"</code> or <code>"client_credentials"</code>, but not both. The value <code>"refresh_token"</code> <strong>SHALL NOT</strong> be present in the array unless <code>"authorization_code"</code> is also present.
      </td>
    </tr>
    <tr>
      <td><code>response_types</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        Array of strings. If <code>grant_types</code> contains <code>"authorization_code"</code>, then this element <strong>SHALL</strong> have a fixed value of <code>["code"]</code>, and <strong>SHALL</strong> be omitted otherwise
      </td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        String containing a space delimited list of scopes requested by the client application for use in subsequent requests. The Authorization Server <strong>MAY</strong> consider this list when deciding the scopes that it will allow the application to subsequently request. Note for client apps that also support the SMART App Launch framework: apps requesting the <code>"client_credentials"</code> grant type <strong>SHOULD</strong> request system scopes; apps requesting the <code>"authorization_code"</code> grant type <strong>SHOULD</strong> request user or patient scopes.
      </td>
    </tr>
    <tr>
      <td><code>extensions</code></td>
      <td><span class="label label-success">optional</span></td>
      <td>
        A JSON object containing one or more of the keys listed in the following section.</code>
      </td>
    </tr>
  </tbody>
</table>

Note: A certification self-signed by a client app operator can be used to declare the intended use of the application within a trust community. Certifications signed by a third party, such as the trust community administrator or an independent accreditor, can be used to assist servers in determining what a client application is authorized to do within a trust community. For example, a trust community administrator could use this certification to communicate the use cases for which a particular client application operator has been approved.
#### Basic certification extension keys

<table class="table">
  <thead>
    <th colspan="3">Client Application Certification JWT Extensions Keys</th>
  </thead>
  <tbody>
    <tr>
      <td><code>exchange_purpose</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Array of strings, each containing a URI identifying an exchange purpose recognized by the trust community.
      </td>
    </tr>
  </tbody>
</table>


