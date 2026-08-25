### Package File

The following package file includes an NPM package file used by many FHIR tools. It includes all the value sets, profiles, extensions, list of pages and urls in the IG, etc. for this version of the Implementation Guide. This file should be the first choice when generating any implementation artifacts as it contains all of the rules about what makes the profiles valid. Implementers will still need to be familiar with the contents of this specification and the applicable profiles in order to make a conformant implementation. See the overview on validating [FHIR profiles and resources](http://hl7.org/fhir/R4/validation.html):

[Package](package.tgz)

### Downloadable Copy of Entire Specification

The following ZIP file contains a downloadable version of this IG that can be hosted locally:
[Downloadable Copy](full-ig.zip)

### FAST Security and UDAP.org Specification Relationship

The aim of this project is to expand upon the existing work by [UDAP.org](https://www.udap.org/) within the HL7 consensus process to produce a more complete set of implementation guides targeted at implementers of both client and server systems using FHIR for data exchange at scale.
The [UDAP.org](https://www.udap.org/) specification is recognized as a legitimate normative reference for this implementation guide. Substantial portions of the FAST Security content are derived from and aligned with the technical work published by [UDAP.org specifications](https://www.udap.org/). HL7 and UDAP.org maintain a Memorandum of Understanding to support joint development and publication activities, and implementers should rely on UDAP.org publications as revision-controlled artifacts when referencing foundational UDAP requirements.

- [UDAP JWT-Based Client Authentication](https://www.udap.org/udap-jwt-client-auth-stu1.html) STU1
- [UDAP Server Metadata](https://www.udap.org/udap-server-metadata-stu1.html) STU1
- [UDAP Tiered OAuth for User Authentication](https://www.udap.org/udap-user-auth-stu1.html) STU1
- [UDAP Dynamic Client Registration](https://www.udap.org/udap-dynamic-client-registration-stu1.html) STU1
- [UDAP Client Authorization Grants using JSON Web Tokens](https://www.udap.org/udap-client-authorization-grants-stu1.html) STU1
- [UDAP Certifications and Endorsements for Client Applications](https://www.udap.org/udap-certifications-and-endorsements-stu1.html) STU1

### Notices

HL7&reg;, FHIR&reg;, the HL7&reg; logo, and the FHIR&reg; flame design are registered trademarks of Health Level Seven International.
UDAP&trade; and the gear design are trademarks of UDAP.org.
{% include ip-statements.xhtml %} 

### Credits

Editor: Luis C. Maas, EMR Direct and UDAP.org

This implementation guide was made possible by the thoughtful contributions and feedback of the following people and organizations:

The members of the ONC FHIR at Scale Taskforce (FAST) Security Tiger Team<br>
The members of the HL7/UDAP.org joint project working group<br>
The members of the HL7 Security Work Group

### Cross Version Analysis 

{% include cross-version-analysis.xhtml %} 

### Dependency Table 

{% include dependency-table-short.xhtml %} 

### Globals Table 

{% include globals-table.xhtml %} 
