The requirements in this section are applicable to both consumer-facing and B2B apps and the servers that support them.

### Discovery of Endpoints

A FHIR Server **SHALL** make its Authorization Server's authorization, token, and registration endpoints, and associated metadata available for discovery by client applications. Servers **SHALL** allow access to the following metadata URL to unregistered client applications and without requiring client authentication, where {baseURL} represents the base FHIR URL for the FHIR server: {baseURL}/.well-known/udap

UDAP Metadata **SHALL** be structured as a JSON object as per section 1 of [UDAP Server Metadata](http://www.udap.org/udap-server-metadata.html) and discussed further in [Section 2.2].

If a server returns a `404 Not Found` response to a `GET` request to the UDAP metadata endpoint, the client application **SHOULD** conclude that the server does not support UDAP workflows.

Note: Servers conforming to this guide are generally expected, but not required, to also support the HL7 SMART App Launch Framework, which defines additional discovery and metadata requirements.
{:.bg-info}

### Required UDAP Metadata

The metadata returned from the UDAP metadata endpoint defined above **SHALL** represent the server's capabilities with respect to the UDAP workflows described in this guide. If no UDAP workflows are supported, the server **SHALL** return a 404 Not Found response to the metadata request. For elements that are represented by JSON arrays, clients **SHALL** interpret an empty array value to mean that the corresponding capability is NOT supported by the server.

Note: For servers that also support the SMART App Launch Framework, there is some expected overlap in the UDAP metadata elements defined below and metadata that a server may return for other workflows, e.g. OAuth 2.0 authorization and token endpoints are also included in metadata defined in the SMART App Launch Framework. Having different metadata endpoints permits servers to return different metadata values for different workflows. For example, a server could operate a different token endpoint to handle token requests from clients conforming to this guide. Thus, for the workflows defined in this guide, client applications **SHALL** use the applicable values returned in a server's UDAP metadata.


<table class="table">
  <thead>
    <th colspan="3">Metadata parameter values</th>
  </thead>
  <tbody>
    <tr>
      <td><code>udap_versions_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A fixed array with one string element: <code>["1"]</code>
      </td>
    </tr>
    <tr>
      <td><code>udap_certifications_supported</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        An array of zero or more certification URIs supported by the Authorization Server, e.g.:<br>
        <code>["https://www.example.com/udap/profiles/example-certification"]</code>
      </td>
    </tr>
    <tr>
      <td><code>udap_certifications_required</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        An array of zero or more certification URIs required by the Authorization Server, e.g.:<br>
        <code>["https://www.example.com/udap/profiles/example-certification"]</code>
      </td>
    </tr>
    <tr>
      <td><code>grant_types_supported</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        An array of one or more grant types supported by the Authorization Server, e.g.:<br>
        <code>["authorization_code", "refresh_token",  "client_credentials"]</code><br>
        The <code>"refresh_token"</code> grant type <strong>SHALL</strong> only be included if the
        <code>"authorization_code"</code> grant type is also included.
      </td>
    </tr>
    <tr>
      <td><code>scopes_supported</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        An array of one or more strings containing scopes supported by the Authorization Server. The server <strong>MAY</strong> support different subsets of these scopes for different client types or entities. Example for a server that also supports SMART App Launch v1 scopes:<br>
        <code>["openid", "launch/patient", "system/Patient.read", "system/AllergyIntolerance.read", "system/Procedures.read"]</code>
      </td>
    </tr>
    <tr>
      <td><code>authorization_endpoint</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        A string containing the absolute URL of the Authorization Server's authorization endpoint
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        A string containing the absolute URL of the Authorization Server's token endpoint if the server supports UDAP JWT-Based Client Authentication.
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint_auth_methods_supported</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        Fixed array with one value: <code>["private_key_jwt"]</code>
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint_auth_signing_alg_values_supported</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        Array of strings identifying one or more signature algorithms supported by the Authorization Server for validation of signed JWTs submitted to the token endpoint for client authentication. For example:<br>
        <code>["RS256", "ES384"]</code>
      </td>
    </tr>
    <tr>
      <td><code>registration_endpoint</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        A string containing the absolute URL of the Authorization Server's registration endpoint if the server supports UDAP Dynamic Client Registration.
      </td>
    </tr>
    <tr>
      <td><code>registration_endpoint_jwt_signing_alg_values_supported</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        Array of strings identifying one or more signature algorithms supported by the Authorization Server for validation of signed software statements, certification, and endorsements submitted to the registration endpoint. For example:<br>
        <code>["RS256", "ES384"]</code>
      </td>
    </tr>
    <tr>
      <td><code>signed_metadata</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>
        A string containing a JWT listing the server's endpoints, as defined in [Section 2.3] below.
      </td>
    </tr>
  </tbody>
</table>

### Signed metadata elements

A server's UDAP metadata **SHOULD** include the `signed_metadata` element. The value of this element is a JWT constructed as described in [Section 1.2] and containing the following claims:

<table class="table">
  <thead>
    <th colspan="3">Signed Metadata JWT claims</th>
  </thead>
  <tbody>
        <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issuer of the JWT -- unique identifying server URI. This <strong>SHALL</strong> match the value of a uniformResourceIdentifier entry in the Subject Alternative Name extension of the server's certificate included in the <code>x5c</code> JWT header, and <strong>SHALL</strong> be equal to the server's {baseURL}
      </td>
    </tr>
    <tr>
      <td><code>sub</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Same as <code>iss</code>.
      </td>
    </tr>
    <tr>
      <td><code>exp</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Expiration time integer for this JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC). The <code>exp</code> time <strong>SHALL</strong> be no more than 1 year after the value of the <code>iat</code> claim.
      </td>
    </tr>
    <tr>
      <td><code>iat</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Issued time integer for this JWT, expressed in seconds since the "Epoch"
      </td>
    </tr>
    <tr>
      <td><code>jti</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A nonce string value that uniquely identifies this JWT. This value <strong>SHALL NOT</strong> be reused by the server in another JWT before the time specified in the <code>exp</code> claim has passed
      </td>
    </tr>
    <tr>
      <td><code>authorization_endpoint</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        A string containing the URI of the server's authorization endpoint, <strong>REQUIRED</strong> if the <code>authorization_endpoint</code> parameter is included in the unsigned metadata
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        A string containing the URI of the server's token endpoint, <strong>REQUIRED</strong> if the <code>token_endpoint</code> parameter is included in the unsigned metadata
      </td>
    </tr>
    <tr>
      <td><code>registration_endpoint</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        A string containing the URI of the server's registration endpoint, <strong>REQUIRED</strong> if the <code>registration_endpoint</code> parameter is included in the unsigned metadata
      </td>
    </tr>
  </tbody>
</table>

{% include link-list.md %}
