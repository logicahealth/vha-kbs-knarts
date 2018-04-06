# VHA KBS KNARTs

This stand-alone content repository contains deliverables and reports of VHA Knowledge-Based Systems HL7 CDS Knowledge Artifacts. The fastest way to browse it is to load the manifest into the 3rd-party KNARTwork tool, here:

http://knartwork.healthcreek.org/browser?repository=http://vha-kbs-knarts.healthcreek.org

The editor will allow you to make changes to the KNARTs, but you'll need to download the updated artifact(s) to save them. 

## Making Your Own Repository

While KNARTwork is currently the only tool that supports this knowledge artifact manifest browsing format, it's easy to create your own repository, or add support into your existing Knowledge Management System. Either:

1. Clone this repository and replace the manifest.json and content folder with your own stuff, or
1. Create your own manifest.json, manually or via your app, and put it somewhere on the Internet.

Whatever you do, make sure CORS is allowed, as users _must_ be able to download this file via other apps. A Dockerfile is provided for convenience, but you are in no way required to use it. Any web server or CDN allowing for cross-domain requests (aka CORS) will work fine.

## Contact

The Office of Knowledge-Based Systems, Veterans Health Administration.

* Preston Lee, Biomedical Informatics, College of Health Solutions, Arizona State University <preston@asu.edu>
