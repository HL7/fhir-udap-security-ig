This section contains general requirements applicable to multiple authorization and authentication workflows.

### JSON Web Token (JWT) Requirements

Both the producers and consumers of JWTs specified in this guide **SHALL** conform to the requirements of [RFC 7515] and the additional requirements below.

#### General requirements and serialization

All JSON Web Tokens (JWTs) defined in this guide:
1. **SHALL** conform to the mandatory requirements of [RFC 7519].
1. **SHALL** be JSON Web Signatures as defined in [RFC 7515].
1. **SHALL** be serialized using JWS Compact Serialization as per [Section 7.1](https://datatracker.ietf.org/doc/html/rfc7515#section-7.1) of RFC 7515.

#### Signature algorithm identifiers

Signature algorithm identifiers used in this guide are defined in [Section 3.1](https://datatracker.ietf.org/doc/html/rfc7518#section-3.1) of RFC 7518.

<table class="table">
   <thead>
      <th colspan="3">Signature Algorithm Identifier Conformance</th>
   </thead>
   <tbody>
      <tr>
         <td><code>RS256</code></td>
         <td>Implementers <b>SHALL</b> support this algorithm.</td>
      </tr>
      <tr>
         <td><code>ES256</code></td>
         <td>Implementers <b>SHOULD</b> support this algorithm.</td>
      </tr>
      <tr>
         <td><code>RS384</code></td>
         <td>Implementers <b>MAY</b> support this algorithm.</td>
      </tr>
      <tr>
         <td><code>ES384</code></td>
         <td>Implementers <b>MAY</b> support this algorithm.</td>
      </tr>
   </tbody>
</table>

While this guide mandates a baseline of support, clients and servers **MAY** support and use additional signature algorithms that meet the security requirements of the use case.

#### JWT headers

All JWTs defined in this guide **SHALL** contain a Javascript Object Signing and Encryption (JOSE) header as defined in [Section 4](https://datatracker.ietf.org/doc/html/rfc7515#section-4) of RFC 7515 that conforms to the following requirements:

<table class="table">
  <thead>
    <th colspan="3">JWT Header Values</th>
  </thead>
  <tbody>
    <tr>
      <td><code>alg</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A string identifying the signature algorithm used to sign the JWT. For
        example:<br>
        <code>"RS256"</code>
      </td>
    </tr>
    <tr>
      <td><code>x5c</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of one or more strings containing the X.509 certificate or
        certificate chain, where the leaf certificate corresponds to the
        key used to digitally sign the JWT. Each string in the array is the
        base64-encoded DER representation of the corresponding certificate, with the leaf
        certificate appearing as the first (or only) element of the array.<br>
        See <a href="https://tools.ietf.org/html/rfc7515#section-4.1.6">Section 4.1.6 of RFC 7515</a>.
      </td>
    </tr>
  </tbody>
</table>

#### JWT Claims

All JWTs defined in this guide contain the `iss`, `exp`, and `jti` claims. The value of the `jti` claim is a nonce string value that uniquely identifies a JWT until the expiration of that JWT, i.e. until the time specified in the `exp` claim of that JWT has passed. Thus, the issuer of a JWT **SHALL NOT** reuse the same `jti` value in a new JWT with the same `iss` value prior to the expiration of the previous JWT. Implementers who track `jti` values to detect the replay of received JWTs **SHALL** allow a `jti` value to be reused after the expiration of any other previously received JWTs containing the same `iss` and `jti` values.

Additional JWT Claim requirements are defined elsewhere in this guide. 

### Authorization code flow

The constraints in the following subsections apply to all workflows utilizing the authorization code flow. Authorization requests submitted by client applications **SHALL** include the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Authorization request parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>response_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>code</code>
      </td>
    </tr>
    <tr>
      <td><code>client_id</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The client identifier issued to the client application at registration.
      </td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        The client application's redirection URI for this session, <strong>REQUIRED</strong> when the client application registered more than one redirection URI. The value <strong>SHALL</strong> match one of the redirection URIs registered by the client.
      </td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Space-delimited list of requested scopes of access.
      </td>
    </tr>
    <tr>
      <td><code>state</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An opaque value used by the client to maintain state between the request and callback, as discused further in <a href="#the-state-parameter">Section 7.2.1</a>
      </td>
    </tr>
    <tr>
      <td><code>code_challenge</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        PKCE code challenge, as discussed further in <a href="#proof-key-for-code-exchange-pkce">Section 7.2.2</a>
      </td>
    </tr>
    <tr>
      <td><code>code_challenge_method</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>S256</code>
      </td>
    </tr>
  </tbody>
</table>

#### The state parameter
A Client application **SHALL** include the `state` parameter in its authorization request. An Authorization Server **SHALL** return an error code of `invalid_request` as per Section 4.1.2.1 of RFC 6749 if a client application does not include a `state` value in its authorization request.

Servers **SHALL** include the `state` parameter and corresponding value provided by the client application in the authorization response as per RFC 6749. The client application **SHALL NOT** proceed if the `state` parameter is not included in the authorization response or its value does not match the value provided by the client application in the corresponding authorization request.

#### Proof Key for Code Exchange (PKCE)

Client applications and Authorization Servers **SHALL** utilize Proof Key for Code Exchange (PKCE) with `code_challenge_method` of `S256` as defined in RFC 7636. An Authorization Server **SHOULD** return an error as per Section 4.4.1 of RFC 7636 if a client application does not include a `code_challenge` is its authorization request. 

The Authorization Server **SHALL** return an error in response to a token request as per Section 4.6 of RFC 7636 if the client included a `code_challenge` in its authorization request but did not include the correct `code_verfier` value in the corresponding token request.

### Scope negotiation

<div class="note-to-balloters" markdown="1">
The following constraints have been adapted from the TEFCA Faciliated FHIR SOP. Some of the constraints in that SOP conflict with constraints found elsewhere in this IG, or relate to requirements in other IGs such as the SMART App Launch IG. This will need to be resolved prior to STU2 publication. Feedback is requested.
</div>

A wildcard scope is a scope that can be alternatively represented as a set of non-wildcard scopes. An example of a wildcard scope is the SMART App Launch v1.0.0 scope `patient/Observation.*` which can expanded to the set of two non-wildcard scopes: `patient/Observation.read` and `patient/Observation.write`. Granting the wildcard scope to a client application is equivalent to granting the corresponding expanded set of non-wildcard scopes.

The constraints enumerated below apply for scope negotiation between client applications and servers. Unless otherwise specified, these constraints apply for both registration requests and access token requests made by client applications, and the corresponding responses returned by servers.

1. The `scopes_supported` metadata **SHALL** be present in the .well-known/udap object and **SHALL** list all scopes supported including all supported wildcard scopes.

    <div class="note-to-balloters">
    `scopes_supported` is currently optional in the Discovery section of this guide. References to SMART specific content should be removed.
    </div>

1. Client applications and servers **MAY** support wildcard scopes.
1. A client application **MAY** request a wildcard scope only if wildcards are specified in the server's `scopes_supported` metadata list.
1. If a client application requests a wildcard scope and the server supports wildcards, then the server **SHOULD** return either the wildcard scope or an expanded set of scopes that the client has been granted in its response.
1. If a client application requests a wildcard scope and the server does not support wildcard scopes, then the server **SHOULD** respond with an error of "invalid_scope".

    <div class="bg-info">
    Note: "invalid_client_metadata" is the corresponding registration request error.
    </div>

1. If a server supports OIDC or SMART App Launch scopes, the server **SHOULD** put the corresponding scopes (e.g. "openid", "offline_access", "email", "fhirUser", etc.) in their `scopes_supported` metadata.
1. A server **MAY** grant fewer scopes than requested by the client application if the client application cannot have a scope specified in the request based on technical or policy guidelines at the responding organization or if the server does not recognize one or more of the requested scopes.
1. A server **SHOULD** respond with "invalid_scope" only if a wildcard scope is requested and not supported, or if none of the requested scopes are supported.

    <div class="bg-info">
    Note: "invalid_client_metadata" is the corresponding registration request error.
    </div>

1. At the time of a token request, an authorization server **MAY** grant additional scopes that are not in the set of scopes requested by the client application if the application has been registered with the server with a different set of scopes than was requested at registration based on technical or policy guidelines at the responding organization.
1. The scopes granted by a server to a client application at the time of an access token request **MAY** be the same as the set from registration or **MAY** be a subset.
1. The scopes granted by a server to a client application at the time of an access token request **MAY** be the same as the set of scopes requested by the client application or **MAY** be a subset.
1. An application **SHOULD** be able to receive a superset of the scopes requested if the server’s policies dictate that a request with a certain system or user/user role is granted specific scopes that are not part of the original request.
1. A server **SHOULD** return "invalid_scope" only if none of the scopes requested are available and/or not part of the scopes requested during registration.

    <div class="bg-info">
    Note: "invalid_client_metadata" is the corresponding registration request error.
    </div>

1. A server **SHALL** include the `scope` parameter in a token response if the set of scopes granted by the server to the client application is not identical to the set of scopes requested by the client application, or if the client application does not include a set of requested scopes in its request.

### Certifications for client applications

As discussed in [UDAP Certifications and Endorsements for Client Applications](https://www.udap.org/udap-certifications-and-endorsements-stu1.html), certifications can be used by client applications or third parties to declare additional information about a client application at the time of registration.

The table in Section 7.4.1 provides a template for UDAP Certification definitions. A trust community **MAY** publish one or more Certification definitions using this template. A Certification definition specifies the values to be used for the `certification_name` and `certification_uris` keys and the allowed `grant_types`. The trust community determines whether or not the optional `scopes` and `extensions` keys will be included in their Certification definition, any restrictions on their allowed values, and whether these keys will be optional, required, or conditionally included when generating a certification. If the `extensions` keys are used, the Certification definition specifies the additional extensions keys to be included in the `extensions` object, as discussed in section 7.4.2.

The trust community also determines who will sign the certification, e.g. the app operator or another party. For example, a certification self-signed by a client app operator can be used to declare the intended use of the application within a trust community, while certifications signed by another party, such as the trust community administrator or an independent accreditor, can be used to assist servers in determining what a client application is authorized to do within a trust community. Note that a trust community could use such a certification to communicate the exchange purposes for which a particular client application operator has been approved.

Using a Certification definition provided by the trust community, a client application or third party **MAY** generate a certification by constructing a signed JWT conforming to requirements of the certification definition and this section. The certification **SHALL** contain the required header elements specified in [Section 7.1.3] of this guide and the JWT claims listed in the certification definition. The certification **SHALL** be signed by the client application operator or by a third party, as specified in the certification definition, using the signature algorithm identified in the `alg` header of the certification and with the private key that corresponds to the public key listed in the signer’s X.509 certificate identified in the `x5c` header of the certification.

Recognized Certification JWT claims and server processing rules for Certifications submitted by a client application are detailed in [UDAP Certifications and Endorsements for Client Applications](https://www.udap.org/udap-certifications-and-endorsements-stu1.html).

#### Certification template

<table class="table">
  <thead>
    <th colspan="3">Template for Certification JWT Claims</th>
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
        A nonce string value that uniquely identifies this software statement. See <a href="general.html#jwt-claims">Section 7.1.4</a> for additional requirements regarding reuse of values.
      </td>
    </tr>
    <tr>
      <td><code>certification_name</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        string with fixed value defined by the trust community, e.g. "Example HL7 Client App Certification"
      </td>
    </tr>
    <tr>
      <td><code>certification_uris</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        array of one or more string with fixed values defined by the trust community, e.g.
        <br>["http://community.example.com/certifications/example-certifications"].
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
      <td><span class="label label-info">optional</span></td>
      <td>
        String containing a space delimited list of scopes that may be requested by the client application in subsequent requests. The Authorization Server <strong>MAY</strong> consider this list when deciding the scopes that it will allow the application to subsequently request. Note for client apps that also support the SMART App Launch framework: certifications for apps requesting the <code>"client_credentials"</code> grant type <strong>SHOULD</strong> lisst system scopes; certifications for apps requesting the <code>"authorization_code"</code> grant type <strong>SHOULD</strong> list user or patient scopes.
      </td>
    </tr>
    <tr>
      <td><code>extensions</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>
        A JSON object containing one or more certification extension keys, as discussed in the following section.
      </td>
    </tr>
  </tbody>
</table>

#### Certification extension keys example

When defining a Certification, a trust community **MAY** define one or more extension keys to be included in the `extensions` object of the Certification JWT, the JSON type of the corresponding value, and the conditions under which the key is present, including whether the use of the key is optional, required, etc. The value of each extension key **SHALL** be a JSON value or a JSON object. For example, a Certification definition could specify that the value of a key is a number, an array of strings, or a FHIR [Questionnaire](https://www.hl7.org/fhir/R4/questionnaire.html) resource, as appropriate for its intended use.

Two non-normative examples of extension keys that could be considered for inclusion in a Certification are presented in the table below:

<table class="table">
  <thead>
    <th colspan="2">Example Client Application Certification JWT Extensions Keys</th>
  </thead>
  <tbody>
    <tr>
      <td><code>example_exchange_purposes</code></td>
      <td>
        Array of strings, each containing a URI identifying an exchange purpose recognized by the trust community.
      </td>
    </tr>
    <tr>
      <td><code>example_privacy_disclosures</code></td>
      <td>
        A JSON object containing a set of privacy-related keys and acceptable values established by the trust community. <br>For example:
        <br>1. the key <code>funding</code> could be used to express the app's source of funding.
        <br>2. the key <code>data_storage</code> could be used to identify where a patient's data is stored.
        <br>3. the key <code>data_access_notification</code> could be used to indicate whether a user is notified when their data is accessed by someone else.
        <br>Note: This example extension key is derived from an example Certification previously published by Carequality, which can be viewed <a href="https://carequality.org/wp-content/uploads/2020/12/Carequality-Consumer-Facing-App-Certification-Profile.pdf">here</a>.
      </td>
    </tr>
  </tbody>
</table>

### Using this guide with the SMART App Launch framework

<div class="bg-info">
Editor's Note: This section is being added per FHIR-49185 and is not yet completed. The SMART note from the intro page and all SMART related comments from the ballot version have been consolidated in this section. Additional specific points mentioned in the ticket are in the process of being added.
</div>

This guide is intended to be compatible and harmonious with client and server use of versions 1 or 2 of the HL7 SMART App Launch IG. Although the use of the SMART App Launch framework is not required to be conformant with this guide, this section provides guidance on how the UDAP and SMART App Launch frameworks can be used together successfully.

<div class="stu-note" markdown="1">
The FAST Security project team is working to identify any potential incompatibilities experienced by servers or client applications that support both this IG and the SMART App Launch IG concurrently. Implementers are requested to submit feedback regarding any other potential issues they have identified related to the concurrent use of both IGs so these may be addressed and resolved in future updates.
</div>

#### Key Algorithms

JWT-based authentication in version 2 of the SMART IG requires server support for either the RS384 or ES384 signature algorithms, while this IG requires server support for RS256. However, this does not present a compatibility issue because RS256 is permitted as an optional algorithm in the SMART IG, while both RS384 and ES384 are permitted as optional algorithms in this IG. Therefore, using any of these three signature algorithms would be compliant with both IGs.

#### Public Key Distribution

This guide uses X.509 certificates included inline within JWTs to distribute public keys. The entity generating a JWT includes the corresponding certificate in the `x5c` header of every signed JWT. Therefore, no separate key discovery or retrieval mechanism is required by the party consuming the JWT. The SMART App Launch framework instead prefers that client apps publish their public keys at a publicly available URL using the JWKS format, and submit this JWKS URL during registration. A server will then dereference this URL to obtain the client's public key. The client may signal to the server to repeat dereferencing by including the same URL in the `jku` header of a JWT.

#### Consistent use of both guides

The question has been raised as to whether this IG can be used for client registration but not used for subsequent authentication. Though adopters of this IG sometimes colloquially refer to its entire workflow as “Dynamic Client Registration”, authentication consistent with this IG is also core to a compliant implementation and the HL7 UDAP FAST Security workgroup recommends that trust communities adopting this IG require the use of this IG for both client registration and authentication, even when SMART is also used, since omitting the UDAP workflow from the authentication step significantly reduces the security benefits to the community.

<div class="bg-info">
Editor's Note: The preceding paragraph may be moved back to Section 1 during final editorial review as it is not limited to SMART.
</div>

#### Discovery

Servers conforming to this guide are generally expected, but not required, to also support the HL7 SMART App Launch Framework, which defines additional discovery and metadata requirements.

For servers that also support the SMART App Launch Framework, there is some expected overlap in the UDAP metadata elements defined in Section 2 and metadata that a server may return for other workflows, e.g. OAuth 2.0 authorization and token endpoints are also included in metadata defined in the SMART App Launch Framework. Having different metadata endpoints permits servers to return different metadata values for different workflows. For example, a server could operate a different token endpoint to handle token requests from clients conforming to this guide. Thus, for the workflows defined in this guide, client applications **SHALL** use the applicable values returned in a server's UDAP metadata.

<div class="bg-info">
Editor's Note: The SHALL requirement in the previous paragraph is duplicative with the text in Section 2 and may be removed during later review.
</div>

Note for client apps that also support the SMART App Launch framework: apps requesting the `"client_credentials"` grant type **SHOULD** request `system` scopes; apps requesting the `"authorization_code"` grant type **SHOULD** request `user` or `patient` scopes.

#### Authorization Request

Client applications that also support the SMART App Launch IG are not required to include a launch scope or launch context requirement scope in an authorization request. However, the capability for a client application to request a launch context from the server is useful in many workflows, e.g. consumer facing workflows. Since this IG does not restrict the inclusion of additional parameters in an authorization request or in the corresponding server response, clients are able initiate either the SMART standalone or EHR launch workflows to request a launch context. For example, a client could initiate the SMART standalone launch by including the `launch/patient` scope in its authorization request to a server that supports this SMART workflow.

#### Token Request

For clients and servers that also support the SMART App Launch IG, the requirement to authenticate using a private key in Section 4.2.1 overrides the requirement for the client to use HTTP Basic Authentication with a client_secret in [Section 7.1.3](http://hl7.org/fhir/smart-app-launch/1.0.0/index.html#step-3-app-exchanges-authorization-code-for-access-token) of the SMART App Launch IG v1.0.0.

#### Token Response

Although this guide does not currently constrain the type or format of access tokens, the SMART App Launch framework, when used together with this guide, may limit the allowed access token types (e.g. Bearer) and/or formats (e.g. JWT). Since this IG does not restrict the server from including additional parameters in the token response, servers can include other parameters specified by the SMART App Launch framework for this purpose, e.g. launch context parameters.

### Experimental workflow alternative using 'jku' dereferencing

<div class="stu-note" markdown="1">
Since many servers support `jku` dereferencing for certain SMART App Launch workflows, the question has been raised as to whether there may be some advantage to allowing clients and servers to re-use this `jku` mechanism for UDAP workflows, as an alternative to requiring a JWT signer to include their certificate inline in the `x5c` header of the JWT. To facilitate future discussion of this topic, this guide defines the following experimental workflow changes for testing purposes. Implementer feedback is requested to determine whether to expand or remove this option in future versions of this guide.
</div>

This sections defines an experimental JWT processing alernative to test the use of `jku` dereferencing for access token request/response workflows. Support for this variation is **OPTIONAL** for both clients and servers, and may be removed in future versions of this guide.  This variation overrides the requirement in [Section 7.1.3] to include an `x5c` header in a JWT. This section does not apply to registration requests or to JWTs signed by servers.

Alternative workflow:
1. Clients **MAY** omit the `x5c` header from an Authentication JWT and instead include the `jku` header containing their pre-registered JWKS URL and the `kid` header identifying a key in the corresponding JWKS key set. If the `jku` header is included, then the key entry from the JWKS set at this URL matching the `kid` value in the JWT header **SHALL** include an `x5c` parameter populated with the corresponding certificate data in the same manner that the `x5c` JWT header would have been populated if it had been included in the JWT.
1. Servers that receive a JWT in a UDAP worfklow without an `x5c` header **MAY** dereference the `jku` header, attempt to locate the `x5c` parameter from the key entry corresponding to the `kid` value in the JWT, and use the `x5c` value from the JWKS in subsequent processing in the same way as if it had been included directly in the JWT as the value of `x5c` JWT header. 
1. Clients intending to utilize this workflow **SHALL** register their JWKS URL by including the `jku` parameter with the JWKS URL value in their signed software statement at the time of registration.

{% include link-list.md %}
