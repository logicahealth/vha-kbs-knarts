# Veterans Health Administration, Knowledge Based Systems (VHA KBS): Clinical Decision Support (CDS) Knowledge Artifacts (KNARTs)

**This is a working copy curated by VHA program staff with input from OSEHRA and clinical communities. Official artifact releases are made through [CDS Connect](https://cds.ahrq.gov/cdsconnect/explore)**

This clinical content repository is the authoritative public-facing source of a broad and deep VHA effort to formally represent 100+ order sets, documentation templates, and event-condition-action (ECA) rules as structured knowledge. Long term, the primary aim is to provide a clinically-vetted knowledge base such that standards-based EHR and support systems may apply and reuse the wealth of tacit knowledge held by VA physicians in interoperable, computable, and automated form. This project was initiated in 2017 under Contract VA118-16-D-1008, Task Order VA11817F10080007. Contributions have been made from a large set of subject matter experts, informaticians, university partners, industry leaders, interagency staff, and other professionals.

The most highly structured documents we have created comply with the HL7 CDS Knowledge Artifacts specification: an XML-based represention of interoperable clinical knowledge.


# Important Legal Statements
**THE CONTENT IN THIS REPOSITORY IS NOT DIRECTLY SUITABLE FOR CLINICAL USE. IT HAS NEVER BEEN PILOTED, _NEVER_ 100% REPRESENTS THE INTENT OF THE CLINICAL SUBJECT MATTER EXPERTS, AND WILL CAUSE HARM IF APPLIED AS-IS. WORK IS MADE AVAILABLE WITHOUT ANY WARRANTY WHATSOEVER, AND WITHOUT CLAIMS, EXPRESSED OR IMPLIED, OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.**

Content of this repository is made available under the Apache 2.0 license unless otherwise noted. Copyright 2017, 2018 Veterans Health Administration. All right reserved.


# Content Overview 
All current clincial content files may be found with the `/content` directory. Files are loosely organized by clinical domain, and are subsorted by artifact shortcode that are frequently referred in the issue tracker. Amongst artifacts, you will encounter various reports, illustrations, background information, and other documents in varied stages of completeness and correctness. All content herein should be assumed to be coninually-evolving _draft_ copy part of the larger body of work. 
frequently see:
 
 * Clinical Content White Papers (CCWP) – L2 – Narratives authored by clinical SMEs and captured in a semi-structured way. Formats: Word, PDF
 * HL7 CDS Knowledge Artifacts v1.3 (KNARTs) – L3/L4 – Schema-validated XML with embedded queries/conditions and statements authored in ELM and ANF, respectively. ANF has not yet been balloted by HL7 but is anticipated in an upcoming cycle. Formats: XML
 * Composite CDS Knowledge Artifacts (“composites”) – L3/L4 – Aggregate type of KNARTs that provides stateful control flow *across* documents. These are based on the current *draft* KNART schema and has not yet been balloted. Numerous composites are provided, and in all cases are essentially wrappers that starts with a documentation template, and based on the outcome, fire off an event that launches an appropriate order set based on conditionts represented using ELM logic. Formats: XML
 * Harmonization and Integration of Member KNART White Papers (HIMKWP) – L2 – Basically the “composite”-level equivalent of a CCWP. Formats: DocBook, Word, PDF

## Historical Versions
Prior to using GitHub, document revisions were not tracking in a manner trivial for consumers to navigate. These historical documents are also provided for posterity and analytics withen the `/superseded` directory.

# High-Level Browsing
This repository includes several metadata files useful for task-specific purposes.

## Master Visual Index and Docker Image
An `index.html` file at the root level allows for viewing cross-artifact metrics via a web browers, including graphical SVG diagrams of composite artifacts. This may be built into a deployable docker image for local use via the provided `Dockerfile`. A version is hosted by Arizona State University, periodically updated at:

	http://vha-kbs-knarts.healthcreek.org
	

# File Availability Auditing with KNARTwork
A `manifest.json` is provided for loading into the free web-based KNARTwork tool from Arizona State University. The fastest way to search for specific artifacts or documents it is to use this magic link and search the manifest within the KNARTwork browser:

	http://knartwork.healthcreek.org/browser?repository=http://vha-kbs-knarts.healthcreek.org

An "audit" button allows you to check for individual file availability directly via your web browser. The editor will allow you to make changes to the KNARTs, but you'll need to download the updated artifact(s) to save them. 

# CDS Connect Mapping
The provided `connect.json` file has been jointly created between VHA and the CDS Connect team at AHRQ and MITRE. This file is effectively a remapping of the KNARTwork `manifest.json` file to match CDS Connect's internal metadata structure as closely as possible. This allows for import and integration with the CDS Connect API.

# Additional Resources

TODO this entire section
TODO list of clinical domains
TODO CDS Connect links
TODO OSEHRA Summit 2018 presentation link
TODO HSPC presentation slides
TODO OSEHRA webinar

# Contact

Program office is run by @kbsgitgal and @a-dru-desai in Clinical Decision Support, Knowledge Based Systems, Office of Informatics and Information Governance, Veterans Health Administration, Department of Veterans Affairs, United States. Repository management and curation is provided by @preston, College of Health Solutions, Arizona State University.

