# Security Policy

## Supported Versions

OWASP CRS has two major types of releases, Major releases (2.x.x, 3.x.x, 4.x.x) 
and point releases (2.1.x, 3.2.x).
For more information see our [wiki](https://github.com/SpiderLabs/owasp-modsecurity-crs/wiki/Release-Policy).

The OWASP CRS officially supports the previous two point releases of the current major release with security patching.
We are happy to receive and merge PR's that address security issues in older versions of the project, but the team itself may choose not to produce these.
Along the same line, OWASP CRS team may not issue security notifications for unsupported software.

| Version   | Supported          |
| --------- | ------------------ |
| 3.3.x-dev | :white_check_mark: |
| 3.2.x     | :white_check_mark: |
| 3.1.x     | :white_check_mark: |
| 3.0.x     | :x:                |

## Reporting a Vulnerability

We strive to make the OWASP ModSecurity CRS accessible to a wide audience of beginner and experienced users. 
We are interested in hearing any bug reports, false positive alert reports, evasions, usability issues, and suggestions for new detections.
These types of non-vulnerability related issues should be submitted via Github. 
Please include your installed version and the relevant portions of your audit log.

If you’ve found a false negative/bypass, please responsibly disclose the issue by sending an email to security@coreruleset.org.

There are a couple things to verify before you submit an vulnerability:

1) Validate which Paranoia Level this bypass applies to. (It is important to note that a bypass of PL1 is not a total bypass CRS)
2) Verify that you have the latest version of OWASP CRS.

We are happy to work with the community to provide CVE identifiers for any discovered security issue if requested. 

If in doubt, feel free to reach out to us
