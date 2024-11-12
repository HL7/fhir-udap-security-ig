<div class="stu-note" markdown="1">
This Security FHIR&reg; IG has been established upon the recommendations of ONC's FHIR at Scale Taskforce (FAST) Security Tiger Team, and has been adapted from IGs previously published by UDAP.org. The workflows defined in the Unified Data Access Profiles (UDAP&trade;) have been used in several FHIR IGs, including the TEFCA Facilitated FHIR IG, Carequality FHIR IG, Carin BB IG, DaVinci HREX IG, and others. The objective of this IG is to harmonize workflows for both consumer-facing and B2B applications to facilitate cross-organizational and cross-network interoperability.

Additional enhancements include a formal definition for a B2B Authorization Extension Object to facilitate these transactions.
</div>

### Introduction

This implementation guide describes how to extend OAuth 2.0 using UDAP workflows for both consumer-facing apps that implement the authorization code flow, and business-to-business (B2B) apps that implement the client credentials flow or authorization code flow. This guide covers automating the client application registration process and increasing security using asymmetric cryptographic keys bound to digital certificates to authenticate ecosystem participants. This guide also provides a grammar for communicating metadata critical to healthcare information exchange.

The requirements described in this guide are intended to align with the proposed solutions of the ONC FHIR at Scale Taskforce’s Security Tiger Team, the security model and UDAP workflows outlined in the [Carequality FHIR-Based Exchange IG], and implementation guides incorporating UDAP workflows published by the [CARIN Alliance](http://hl7.org/fhir/us/carin-bb/STU1/Authorization_Authentication_and_Registration.html#authorization-and-authentication) and the [Da Vinci Project](http://hl7.org/fhir/us/davinci-hrex/STU1/smart-app-reg.html). This guide is also intended to be compatible and harmonious with client and server use of versions 1 or 2 of the [HL7 SMART App Launch IG](http://hl7.org/fhir/smart-app-launch/history.html).
{:.bg-info}

This Guide is divided into several pages which are listed at the top of each page in the menu bar.

- [Home]\: The home page provides the introduction and background for this project, and general requirements that apply to all workflows described in this guide.
- [Discovery]\: This page describes how clients can discover server support for the workflows described in this guide.
- [Registration]\: This page describes workflows for dynamic registration of client applications.
- [Consumer-Facing]\: This page provides detailed guidance for authorization and authentication of consumer-facing apps.
- [Business-to-Business]\: This page provides detailed guidance for authorization and authentication of B2B apps.
- [Tiered OAuth for User Authentication]\: This page provides detailed guidance for user authentication.
- [General Guidance]\: This page provides general guidance applicable to multiple authorization and authentication workflows.
- [FHIR Artifacts]\: This page provides additional conformance artifacts for FHIR resources.

### JSON Web Token (JWT) Requirements

The requirements in this section are applicable to both consumer-facing and B2B apps and the servers that support them.

#### General requirements and serialization

All JSON Web Tokens (JWTs) defined in this guide:
1. **SHALL** conform to the mandatory requirements of [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519).
1. **SHALL** be JSON Web Signatures conforming to the mandatory requirements of [RFC 7515](https://datatracker.ietf.org/doc/html/rfc7515).
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

Additional JWT Claim requirements are defined later in this guide. 

### Trust Community Checklist

This section lists some additional topics to be addressed by trust communities adopting this guide:

1. Assignment of unique URIs to servers for use in certificates and in the `iss` and `sub` claims of signed metadata elements (see [Section 2.3]).
1. URI used to identify the community in metadata requests (see [Section 2.4]).
1. Assignment of unique URIs to client applications for use in certificates and in the `iss` and `sub` claims of software statements (see [Section 3.1]).
1. Assignment of unique URIs to organizational requestors for use in a B2B Authorization Extension Object (see `organization_id` in [Section 5.2.1.1]).
1. Allowed values for requestor roles in a B2B Authorization Extension Object (see `subject_role` in [Section 5.2.1.1]).
1. Permitted purposes of use for which data may be requested in a B2B Authorization Extension Object (see `purpose_of_use` in [Section 5.2.1.1]).
1. Consent and authorization policies that may be asserted in a B2B Authorization Extension Object and supporting documentation (see `consent_policy` and `consent_reference` in [Section 5.2.1.1]).
1. Other community policies or conditions that an actor may need to meet before exchanging data with community participants or with other trust communities. Examples include community legal agreements, certificate policies, policies regarding what claims an actor has the authority to assert, and other community requirements relating to the specific use cases, client types and/or grant types supported by the community.

{% include link-list.md %}
