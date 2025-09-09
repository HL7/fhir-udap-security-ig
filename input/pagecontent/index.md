<div class="stu-note" markdown="1">
<strong>This IG is currently undergoing ballot reconciliation in preparation for publication of STU2.</strong>

This Security FHIR&reg; IG has been established upon the recommendations of ONC's FHIR at Scale Taskforce (FAST) Security Tiger Team, and has been adapted from IGs previously published by UDAP.org. The workflows defined in the Unified Data Access Profiles (UDAP&trade;) have been used in several FHIR IGs, including the TEFCA Facilitated FHIR IG, Carequality FHIR IG, Carin BB IG, DaVinci HREX IG, and others. The objective of this IG is to harmonize workflows for both consumer-facing and B2B applications to facilitate cross-organizational and cross-network interoperability.

Additional enhancements include a formal definition for a B2B Authorization Extension Object to facilitate these transactions.
</div>

### Introduction

This implementation guide describes how to extend OAuth 2.0 using UDAP workflows for both consumer-facing apps that implement the authorization code flow, and business-to-business (B2B) apps that implement the client credentials flow or authorization code flow. This guide covers automating the client application registration process and increasing security using asymmetric cryptographic keys bound to digital certificates to authenticate ecosystem participants. This guide also provides a grammar for communicating metadata critical to healthcare information exchange.

The requirements described in this guide are intended to align with the proposed solutions of the ONC FHIR at Scale Taskforce’s Security Tiger Team, the security model and UDAP workflows outlined in the [Carequality FHIR-Based Exchange IG], and implementation guides incorporating UDAP workflows published by the [CARIN Alliance](http://hl7.org/fhir/us/carin-bb/STU1/Authorization_Authentication_and_Registration.html#authorization-and-authentication) and the [Da Vinci Project](http://hl7.org/fhir/us/davinci-hrex/STU1/smart-app-reg.html).
{:.bg-info}

This Guide is divided into several pages which are listed at the top of each page in the menu bar.

- [Home]\: The home page provides the introduction and background for this project, and general requirements that apply to all workflows described in this guide.
- [Discovery]\: This page describes how clients can discover server support for the workflows described in this guide.
- [Registration]\: This page describes workflows for dynamic registration of client applications.
- [Consumer-Facing]\: This page provides detailed guidance for authorization and authentication of consumer-facing apps.
- [Business-to-Business]\: This page provides detailed guidance for authorization and authentication of B2B apps.
- [Tiered OAuth for User Authentication]\: This page provides detailed guidance for user authentication.
- [General Requirements]\: This page provides general requirements applicable to multiple authorization and authentication workflows.
- [FHIR Artifacts]\: This page provides additional conformance artifacts for FHIR resources.

Guidance regarding the use of this IG with the SMART App Launch Framework can be found in [Section 7.5].

### Trust Community Checklist

This section lists some additional topics to be addressed by trust communities adopting this guide:

1. Assignment of unique URIs to servers for use in certificates and in the `iss` and `sub` claims of signed metadata elements (see [Section 2.3]).
1. URI used to identify the community in metadata requests (see [Section 2.4]).
1. Assignment of unique URIs to client applications for use in certificates and in the `iss` and `sub` claims of software statements (see [Section 3.1]).
1. Assignment of unique URIs to organizational requestors for use in a B2B Authorization Extension Object (see `organization_id` in [Section 5.2.1.1]).
1. Allowed values for requestor roles in a B2B Authorization Extension Object (see `subject_role` in [Section 5.2.1.1]).
1. Permitted purposes of use for which data may be requested in a B2B Authorization Extension Object (see `purpose_of_use` in [Section 5.2.1.1]).
1. Consent and authorization policies that may be asserted in a B2B Authorization Extension Object and supporting documentation (see `consent_policy` and `consent_reference` in [Section 5.2.1.1]).
1. Time synchronization between community participants.
1. PKI policies including policies for certificate issuance and distribution.
1. Other community policies or conditions that an actor may need to meet before exchanging data with community participants or with other trust communities. Examples include community legal agreements, certificate policies, policies regarding what claims an actor has the authority to assert, and other community requirements relating to the specific use cases, client types and/or grant types supported by the community.

{% include link-list.md %}
