This guide supports consumer-facing client applications using the authorization code grant type. 

Consumer-facing client applications **SHALL** obtain an access token for access to FHIR resources by following the OAuth 2.0 authorization code grant flow, with the additional options and constraints discussed below.

### Authorization code workflow

The workflow for obtaining an access token using this grant type is summarized in the following diagram:
<br>
<div>
{% include authz.svg %}
</div>

#### Authorization request

Client applications **SHALL** request an authorization code as per [Section 4.1.1](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.1) of RFC 6749, with the following additional constraints. Client applications and servers **MAY** optionally support UDAP Tiered OAuth for User Authentication to allow for cross-organizational or third party user authentication as described in [Section 6].

Authorization Servers **SHALL** support both `GET` and `POST` requests to their authorization endpoint for the authorization code flow. Clients **SHALL** support at least one of these two HTTP methods. Authorization requests submitted by client applications **SHALL** include the following parameters:

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
        An opaque value used by the client to maintain state between the request and callback, as discused further in <a href="general.html#the-state-parameter">Section 7.2.1</a>.
      </td>
    </tr>
    <tr>
      <td><code>code_challenge</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        PKCE code challenge, as discussed further in <a href="general.html#proof-key-for-code-exchange-pkce">Section 7.2.2</a>.
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

#### Authorization response

Servers **SHALL** handle and respond to authorization code requests as per [Section 4.1.2](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.2) of RFC 6749.

Client applications and Authorization Servers **SHALL** conform to the additional constraints for authorization code flow found in [Section 7.2] of this guide.

#### Token request

Client applications **SHALL** exchange authorization codes for access tokens as per [Section 4.1.3](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3) of RFC 6749, with the following additional options and constraints.

Client applications **SHALL** generate an Authentication Token JWT as detailed [Section 4.2]. 

Client applications **SHALL** submit a POST request to the Authorization Server's token endpoint as per [Section 5.1](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-5.1) of UDAP JWT-Based Client Authentication. A client application authenticating in this manner **SHALL NOT** include an HTTP Authorization header or client secret in its token request. The token request **SHALL** include the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Token request parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>authorization_code</code>
      </td>
    </tr>
    <tr>
      <td><code>code</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The code that the app received from the Authorization Server
      </td>
    </tr>
    <tr>
      <td><code>code_verifier</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The code verifier corresponding to the PKCE code challenge included by the client in the authorization request, as per Section 4.5 of RFC 7636 and <a href="general.html#proof-key-for-code-exchange-pkce">Section 7.2.2</a> of this guide.
      </td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        The client application's redirection URI. This parameter <strong>SHALL</strong> be present only if the <code>redirect_uri</code> parameter was included in the authorization request in <a href="#authorization-request">Section 4.1.1</a>, and their values <strong>SHALL</strong> be identical.
      </td>
    </tr>
    <tr>
      <td><code>client_assertion_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code>
      </td>
    </tr>
    <tr>
      <td><code>client_assertion</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The signed Authentication Token JWT constructed as per <href a="#constructing-an-authentication-token">Section 4.2</a>.
      </td>
    </tr>
    <tr>
      <td><code>udap</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed value: <code>1</code>
      </td>
    </tr>
  </tbody>
</table>

#### Token response

Authorization Servers **SHALL** validate and respond to token requests as per [Sections 6 and 7](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-6) of UDAP JWT-Based Client Authentication, with the additional constraints below.

Authorization Servers **SHALL** return an error as per Section 4.6 of RFC 7636 if the client included a `code_challenge` in its authorization request but did not include the correct `code_verifier` value in the corresponding token request.

For all successful token requests, Authorization Servers **SHALL** issue access tokens with a lifetime no longer than 60 minutes. 

<div class="stu-note" markdown="1">
This guide does not currently constrain the type or format of access tokens issued by Authorization Servers. Note that other implementation guides (e.g. SMART App Launch, IUA, etc.), when used together with this guide, may limit the allowed access token types (e.g. Bearer) and/or formats (e.g. JWT).
</div>

### Constructing an Authentication Token

Client apps following this guide will have registered to authenticate using a private key rather than a shared `client_secret`. Thus, the client **SHALL** use its private key to sign an Authentication Token as described in this section, and include this JWT in the `client_assertion` parameter of its token request as described in [Section 5.1](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-5.1) of UDAP JWT-Based Client Authentication and detailed further in [Section 4.1.3] of this guide.

Authentication Tokens submitted by client apps **SHALL** conform to the general JWT header requirements in [Section 7.1] of this guide and **SHALL** include the following parameters in the JWT claims, as defined in [Section 4](https://www.udap.org/udap-jwt-client-auth-stu1.html#section-4) of UDAP JWT-Based Client Authentication:

<table class="table">
  <thead>
    <th colspan="3">Authentication JWT Claims</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The application's <code>client_id</code> as assigned by the Authorization Server during the registration process
      </td>
    </tr>
    <tr>
      <td><code>sub</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The application's <code>client_id</code> as assigned by the Authorization Server during the registration process
      </td>
    </tr>
    <tr>
      <td><code>aud</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        The FHIR Authorization Server's token endpoint URL
      </td>
    </tr>
    <tr>
      <td><code>exp</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
      </td>
    </tr>
    <tr>
      <td><code>iat</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issued time integer for this authentication JWT, expressed in seconds since the "Epoch"
      </td>
    </tr>
    <tr>
      <td><code>jti</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A nonce string value that uniquely identifies this authentication JWT. See <a href="general.html#jwt-claims">Section 7.1.4</a> for additional requirements regarding reuse of values.
      </td>
    </tr>
  </tbody>
</table>

The maximum lifetime for an Authentication Token **SHALL** be 5 minutes, i.e. the value of `exp` minus the value of `iat` **SHALL NOT** exceed 300 seconds. The Authorization Server **MAY** ignore any unrecognized claims in the Authentication Token. The Authentication Token **SHALL** be signed and serialized using the JSON compact serialization method. 

### Refresh token workflow

This guide supports the use of refresh tokens, as described in [Section 1.5 of RFC 6749]. Authorization Servers **MAY** issue refresh tokens to consumer-facing client applications as per [Section 5 of RFC 6749]. Client apps that have been issued refresh tokens **MAY** make refresh requests to the token endpoint as per [Section 6 of RFC 6749]. 

The workflow for obtaining an access token using this grant type is summarized in the following diagram:
<br>
<div>
{% include token.svg %}
</div>

Client apps authenticate to the Authorization Server for refresh requests by constructing and including an Authentication Token in the same manner as for initial token requests.

{% include link-list.md %}