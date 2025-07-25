The requirements in this section are applicable to both consumer-facing and B2B apps and the servers that support them. The client and the server **SHALL** conform to the underlying server metadata profile in [UDAP Server Metadata].

### Discovery of Endpoints

A FHIR Server **SHALL** make its Authorization Server's authorization, token, and registration endpoints, and associated metadata available for discovery by client applications. Servers **SHALL** respond to `GET` requests to the following metadata URL by unregistered client applications and without requiring client authentication, where {baseURL} represents the base FHIR URL for the FHIR server: {baseURL}/.well-known/udap

The discovery workflow is summarized in the following diagram:
<br>
<div>
{% include discovery.svg %}
</div>

UDAP metadata **SHALL** be structured as a JSON object as per Section 1 of [UDAP Server Metadata](https://www.udap.org/udap-server-metadata-stu1.html#section-1) and discussed further in [Section 2.2].

If a server returns a `404 Not Found` response to a `GET` request to the UDAP metadata endpoint, the client application **SHOULD** conclude that the server does not support UDAP workflows.

### Required UDAP Metadata

The metadata returned from the UDAP metadata endpoint defined above **SHALL** represent the server's capabilities with respect to the UDAP workflows described in this guide. If no UDAP workflows are supported, the server **SHALL** return a `404 Not Found` response to the metadata request. For elements that are represented by JSON arrays, clients **SHALL** interpret an empty array value to mean that the corresponding capability is NOT supported by the server.

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
      <td><code>udap_profiles_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of two or more strings identifying the core UDAP profiles supported by the Authorization Server.
        The array <strong>SHALL</strong> include: 
        <br><code>"udap_dcr"</code> for UDAP Dynamic Client Registration, and
        <br><code>"udap_authn"</code> for UDAP JWT-Based Client Authentication.
        <br>If the <code>grant_types_supported</code> parameter includes the string <code>"client_credentials"</code>, then the array <strong>SHALL</strong> also include:
        <br><code>"udap_authz"</code> for UDAP Client Authorization Grants using JSON Web Tokens to indicate support for Authorization Extension Objects.
        <br>If the server supports the user authentication workflow described in <a href="user.html#tiered-oauth-for-user-authentication">Section 6</a>, then the array <strong>SHALL</strong> also include:
        <br><code>"udap_to"</code> for UDAP Tiered OAuth for User Authentication.
      </td>
    </tr>
    <tr>
      <td><code>udap_authorization_extensions_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of zero or more recognized key names 
        for Authorization Extension Objects supported by the Authorization Server. If the Authorization Server supports the B2B Authorization Extension Object defined in <a href="b2b.html#b2b-authorization-extension-object">Section 5.2.1.1</a>, then the following key name <strong>SHALL</strong> be included:<br>
        <code>["hl7-b2b"]</code>
      </td>
    </tr>
    <tr>
      <td><code>udap_authorization_extensions_required</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        An array of zero or more recognized key names 
        for Authorization Extension Objects required by the Authorization Server in every token request. The array <strong>SHALL NOT</strong> include key names that are not also elements of the <code>udap_authorization_extensions_supported</code> array. This metadata parameter <strong>SHALL</strong> be present if the value of the <code>udap_authorization_extensions_supported</code> parameter is not an empty array. If the Authorization Server requires the B2B Authorization Extension Object defined in <a href="b2b.html#b2b-authorization-extension-object">Section 5.2.1.1</a> in every token request, then the following key name <strong>SHALL</strong> be included:<br>
        <code>["hl7-b2b"]</code>
      </td>
    </tr>
    <tr>
      <td><code>udap_certifications_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of zero or more certification URIs supported by the Authorization Server, e.g.:<br>
        <code>["https://www.example.com/udap/profiles/example-certification"]</code>
      </td>
    </tr>
    <tr>
      <td><code>udap_certifications_required</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        An array of zero or more certification URIs required by the Authorization Server. The array <strong>SHALL NOT</strong> include certification URIs that are not also elements of the <code>udap_certifications_supported</code> array. This metadata parameter <strong>SHALL</strong> be present if the value of the <code>udap_certifications_supported</code> parameter is not an empty array. Example:<br>
        <code>["https://www.example.com/udap/profiles/example-certification"]</code>
      </td>
    </tr>
    <tr>
      <td><code>grant_types_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        An array of one or more grant types supported by the Authorization Server, e.g.:<br>
        <code>["authorization_code", "refresh_token",  "client_credentials"]</code><br>
        The <code>"refresh_token"</code> grant type <strong>SHALL</strong> only be included if the
        <code>"authorization_code"</code> grant type is also included.
      </td>
    </tr>
    <tr>
      <td><code>scopes_supported</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>
        An array of one or more strings containing scopes supported by the Authorization Server. The server <strong>MAY</strong> grant different subsets of these scopes for different client types or entities. Example for a server that also supports SMART App Launch v1 scopes:<br>
        <code>["openid", "launch/patient", "system/Patient.read", "system/AllergyIntolerance.read", "system/Procedures.read"]</code>
      </td>
    </tr>
    <tr>
      <td><code>authorization_endpoint</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        A string containing the absolute URL of the Authorization Server's authorization endpoint. This parameter <strong>SHALL</strong> be present if the value of the <code>grant_types_supported</code> parameter includes the string <code>"authorization_code"</code>
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A string containing the absolute URL of the Authorization Server's token endpoint for UDAP JWT-Based Client Authentication.
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint_auth_methods_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Fixed array with one value: <code>["private_key_jwt"]</code>
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint_auth_signing_alg_values_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Array of strings identifying one or more signature algorithms supported by the Authorization Server for validation of signed JWTs submitted to the token endpoint for client authentication. For example:<br>
        <code>["RS256", "ES384"]</code>
      </td>
    </tr>
    <tr>
      <td><code>registration_endpoint</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A string containing the absolute URL of the Authorization Server's registration endpoint.
      </td>
    </tr>
    <tr>
      <td><code>registration_endpoint_jwt_signing_alg_values_supported</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        Array of strings identifying one or more signature algorithms supported by the Authorization Server for validation of signed software statements, certifications, and endorsements submitted to the registration endpoint. For example:<br>
        <code>["RS256", "ES384"]</code>
      </td>
    </tr>
    <tr>
      <td><code>signed_metadata</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A string containing a JWT listing the server's endpoints, as defined in <a href="#signed-metadata-elements">Section 2.3</a> below.
      </td>
    </tr>
  </tbody>
</table>

An Authorization Server **MAY** include additional metadata elements in its metadata response as described in [UDAP Server Metadata]. However, a conforming client application might not support additional metadata elements.

### Signed metadata elements

A server's UDAP metadata **SHALL** include the `signed_metadata` element. The value of this element is a JWT constructed as described in [Section 7.1] and containing the claims in the table below. This JWT **SHALL** be signed using the [RS256](general.html#signature-algorithm-identifiers) signature algorithm. Metadata values conveyed in the signed metadata **SHALL** take precedence over the corresponding values conveyed using plain JSON elements.

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
        A nonce string value that uniquely identifies this JWT. See <a href="general.html#jwt-claims">Section 7.1.4</a> for additional requirements regarding reuse of values.
      </td>
    </tr>
    <tr>
      <td><code>authorization_endpoint</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>
        A string containing the absolute URL of the server's authorization endpoint, <strong>REQUIRED</strong> if the <code>authorization_endpoint</code> parameter is included in the unsigned metadata
      </td>
    </tr>
    <tr>
      <td><code>token_endpoint</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A string containing the absolute URL of the server's token endpoint
      </td>
    </tr>
    <tr>
      <td><code>registration_endpoint</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
        A string containing the absolute URL of the server's registration endpoint
      </td>
    </tr>
  </tbody>
</table>

The client **SHALL** validate the signed metadata returned by the server as per Section 3 of [UDAP Server Metadata].

Note: The use of the `signed_metadata` parameter in this guide is intended to align with [Section 2.1 of RFC 8414]. However, the requirements specified in this section are stricter than the corresponding requirements in RFC 8414.

### Multiple Trust Communities

A server that participates in more than one trust community may be issued different certificates from each community. However, the serialization method used to sign server metadata in the previous section of this guide requires the server to select only one certificate for use in assembling the signed JWT returned for the `signed_metadata` element. This can lead to scenarios where a client application might not trust the certificate that was selected by the server, but would have trusted one of the server's other certificates for a different trust community. 

To address this, a client application **SHOULD** add the optional query parameter `community` to the metadata request URL described in [Section 2.1] to indicate that it trusts certificates issued by the community identified by the parameter value. The value of the parameter **SHALL** be a URI as determined by the trust community for this purpose.

Servers **SHALL** support the `community` parameter. IF a client includes this parameter in its metadata request and the server recognizes the community URI, the server **SHALL** select a certificate intended for use within the identified trust community, if it has been issued such a certificate, and use that certificate when generating the signed JWT returned for the `signed_metadata` element. If a server supports different UDAP capabilities for different communities, it **MAY** also return different values for other metadata elements described in [Section 2.2] as appropriate for the identified community. If the server does not recognize the community URI or does not have a suitable certificate for the identified community, it **MAY** return a `204 No Content` response to the metadata request to indicate that no UDAP workflows are supported by server in the context of that community, or it **MAY** return its default metadata, i.e. the metadata that it would have returned if the `community` parameter was not included in the request.

Note: The authors recommend that the client be prepared to handle server metadata signed with a key for a different trust community than expected, regardless if the community parameter was used.

{% include link-list.md %}
