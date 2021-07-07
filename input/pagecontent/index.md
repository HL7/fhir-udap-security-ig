<div class="note-to-balloters" markdown="1">
This Security FHIR IG has been established upon the recommendations of ONC's FHIR at Scale Task Force (FAST) Security Tiger Team, and has been adapted from IGs previously published by UDAP.org. The workflows defined in the Unified Data Access Profiles (UDAP) have been used in several FHIR IGs, including the Carequality FHIR IG, Carin BB IG, DaVinci HREX IG, and others. The objective of this IG is to harmonize workflows for both consumer-facing and B2B applications to facility cross-organizational and cross-network interoperability.

Additional enhancements include a formal definition for a B2B Authorization Extension Object to facilitate these transactions.
</div>

<div class="bg-info" markdown="1">
Publishing Punch list:

- [ ] verify section numbers and links for internal section references

Where possible, new and updated content will be highlighted with green text and background
{:.new-content}

{{ site.data.pl.list[0].desc }}

</div>

{{ site.data.ig.description }}

### About This Guide

This implementation guide describes how to extend OAuth 2.0 and the HL7 SMART App Launch Framework using UDAP workflows for both consumer-facing apps that implement the authorization code flow, and business-to-business (B2B) apps that implement the client credentials flow or authorization code flow. This guide covers automating the client application registration process and increasing security using asymmetric cryptographic keys bound to digital certificates to authenticate ecosystem participants. This guide also provides a grammar for communicating metadata critical to healthcare information exchange.

The requirements described in this guide are intended to align with the proposed solutions of the ONC FHIR at Scale Task Force’s Security Tiger Team, the security model and UDAP workflows outlined in the [Carequality FHIR-Based Exchange IG], and implementation guide incorporating UDAP workflows published by the [CARIN Alliance](http://hl7.org/fhir/us/carin-bb/STU1/Authorization_Authentication_and_Registration.html#authorization-and-authentication) and the [Da Vinci Project](http://build.fhir.org/ig/HL7/davinci-ehrx/smart-app-reg.html). This guide is also intended to be fully compatible with client and server use of the [HL7 SMART App Launch Framework v1.0.0](http://hl7.org/fhir/smart-app-launch/1.0.0).
{:.bg-info}

This Guide is divided into several pages which are listed at the top of each page in the menu bar.

- [Home]\: The home page provides the introduction and background for this project, and general requirements that apply to all workflows described in this guide.
- [Discovery]\: This page describes how clients can discover server support for the workflows described in this guide.
- [Registration]\: This page describes workflows for dynamic registration of client applications.
- [Consumer-Facing]\: This page provides detailed guidance for authorization and authentication of consumer-facing apps.
- [Business-to-Business]\: This page provides detailed guidance for authorization and authentication of B2B apps.
- [User Authentication]\: This page provides detailed guidance for user authentication.
- [FHIR Artifacts]\: This page provides additional conformance artifacts for FHIR resources.

### JSON Web Token (JWT) Requirements

The requirements in this section are applicable to both consumer-facing and B2B apps and the servers that support them.

#### General requirements and serialization

All JSON Web Tokens (JWTs) defined in this guide:
1. **SHALL** conform to the mandatory requirements of [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519).
1. **SHALL** be JSON Web Signatures conforming to the mandatory requirements of [RFC 7515](https://datatracker.ietf.org/doc/html/rfc7515).
1. **SHALL** be serialized using JWS Compact Serialization as per [Section 7.1](https://datatracker.ietf.org/doc/html/rfc7515#section-7.1) of RFC 7515.

#### Signature algorithm identifiers

Signature algorithm identifiers used in this guide are defined in [Section 3.1](https://datatracker.ietf.org/doc/html/rfc7518#section-3.1) of RFC 7518. Implementations supporting the UDAP workflows defined in this guide **SHALL** support `RS256`. In addition to the algorithm required by the referenced UDAP specifications, this guide also permits the use of `ES256` and `ES384`. Implementations **SHOULD** support `ES256`, and **MAY** support `ES384`.

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
        certificate chain, with the leaf certificate corresponding to the
        key used to digitally sign the JWT. Each string in the array is the
        base64-encoded DER representation of the corresponding certificate, with the leaf
        certificate appearing as the first (or only) element of the array.<br>
        See <a href="https://tools.ietf.org/html/rfc7515#section-4.1.6">https://tools.ietf.org/html/rfc7515#section-4.1.6</a>
      </td>
    </tr>
  </tbody>
</table>

{% include link-list.md %}