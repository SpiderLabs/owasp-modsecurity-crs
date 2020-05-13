![Travis build v3.3/dev](https://img.shields.io/travis/spiderlabs/owasp-modsecurity-crs/v3.3/dev?label=v3.3%2Fdev)
![Travis build v3.2/dev](https://img.shields.io/travis/spiderlabs/owasp-modsecurity-crs/v3.2/dev?label=v3.2%2Fdev)
![Travis build v3.1/dev](https://img.shields.io/travis/spiderlabs/owasp-modsecurity-crs/v3.1/dev?label=v3.1%2Fdev)
[![OWASP Flagship](https://img.shields.io/badge/owasp-flagship%20project-38a047.svg)](https://www.owasp.org/index.php/OWASP_Project_Inventory#tab=Flagship_Projects)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/1390/badge)](https://bestpractices.coreinfrastructure.org/projects/1390)

**CRS migrated to a new :house: !**

The OWASP ModSecurity Core Rule Set (CRS) has moved to https://github.com/coreruleset/coreruleset.

A note on this change:

This project started at Trustwave SpiderLabs over ten years ago, it was created with the idea of making a free ruleset that anyone can use to get started with ModSecurity. Over time it has grown into a community maintained project that no longer needs our direct support- which is the best you can hope for with such a project: Apart from growing a community dedicated fully to maintaining the CRS project, it also freed us up to focus fully on maintaining ModSecurity the engine.

Given that Trustwave SpiderLabs hasn't been the maintainer of the project for a few years now it made sense for it to have its own home on GitHub. As such, in coordination with the CRS team it has moved to the following location: https://github.com/coreruleset/coreruleset

This project is now archived to retain its history and make sure that no links are broken but it will **NOT** be maintained at this location so if you're working directly with GitHub make sure to update your scripts and environments accordingly.

*- Trustwave SpiderLabs*



# OWASP ModSecurity Core Rule Set (CRS)

The OWASP ModSecurity Core Rule Set (CRS) is a set of generic attack detection rules for use with ModSecurity or compatible web application firewalls. The CRS aims to protect web applications from a wide range of attacks, including the OWASP Top Ten, with a minimum of false alerts.

## CRS Resources

Please see the [OWASP ModSecurity Core Rule Set page](https://coreruleset.org/) to get introduced to the CRS and view resources on installation, configuration, and working with the CRS.

## Contributing to the CRS

We strive to make the OWASP ModSecurity CRS accessible to a wide audience of beginner and experienced users. We are interested in hearing any bug reports, false positive alert reports, evasions, usability issues, and suggestions for new detections.

[Create an issue on GitHub](https://github.com/SpiderLabs/owasp-modsecurity-crs/issues) to report a false positive or false negative (evasion). Please include your installed version and the relevant portions of your ModSecurity audit log.

[Sign up for our Google Group](https://groups.google.com/a/owasp.org/forum/#!forum/modsecurity-core-rule-set-project) to ask general usage questions and participate in discussions on the CRS. Also [here](https://lists.owasp.org/pipermail/owasp-modsecurity-core-rule-set/index) you can find the archives for the previous mailing list.

[Join the #coreruleset channel on OWASP Slack](http://owaspslack.com) to chat about the CRS.

## License

Copyright (c) 2006-2019 Trustwave and contributors. All rights reserved.

The OWASP ModSecurity Core Rule Set is distributed under Apache Software License (ASL) version 2. Please see the enclosed LICENSE file for full details.
