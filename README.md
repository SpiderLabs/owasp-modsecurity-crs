# OWASP ModSecurity Core Rule Set (CRS)

Licensing
=========
(c) 2006-2012 Trustwave 

The ModSecurity Core Rule Set is provided to you under the terms and 
conditions of Apache Software License Version 2 (ASLv2)

http://www.apache.org/licenses/LICENSE-2.0.txt 

Mail-List
=========
For more information refer to the OWASP Core Rule Set Project page at
http://www.owasp.org/index.php/Category:OWASP_ModSecurity_Core_Rule_Set_Project

Core Rules Mail-list -
Suscribe here: https://lists.owasp.org/mailman/listinfo/owasp-modsecurity-core-rule-set
Archive: https://lists.owasp.org/pipermail/owasp-modsecurity-core-rule-set/

Downloading
===========

You can manually download the latest CRS from the OWASP Project site -
http://www.owasp.org/index.php/Category:OWASP_ModSecurity_Core_Rule_Set_Project#tab=Download

You can optionally automatically download the latest rules by using the
rules-updater.pl script in the /util directory.  Refer to the README file in the
/util dir.

ModSecurity Blog Posts
======================

http://blog.spiderlabs.com/modsecurity/

ModSecurity Advanced Topic of the Week: Traditional vs. Anomaly Scoring Detection Modes
http://blog.spiderlabs.com/2010/11/advanced-topic-of-the-week-traditional-vs-anomaly-scoring-detection-modes.html

ModSecurity Advanced Topic of the Week: Exception Handling
http://blog.spiderlabs.com/2010/11/modsecurity-advanced-topic-of-the-week-exception-handling.html

Overview
========

Using ModSecurity requires rules. In order to enable users to take full
advantage of ModSecurity immediately, Trustwave is providing a free 
Core rule set. Unlike intrusion detection and prevention systems which 
rely on signature specific to known vulnerabilities, the Core Rule Set 
provides generic protection from unknown vulnerabilities often found in web 
application that are in most cases custom coded. This is what we call "Attack
Payload Detection." 

Keep in mind that a predefined rule set is only part of the work required to 
protect your web site. We strongly urge you to consult Ivan Ristic's book, 
"ModSecurity Handbook" http://store.feistyduck.com/products/modsecurity-handbook
and the ModSecurity Reference Manual - http://www.modsecurity.org/documentation/.
The CRS is heavily commented to allow it to be used as a step-by-step 
deployment guide for ModSecurity.


CRS 2.0 Design Concepts 
=======================

-=[ CRS < 2.0 - Self-Contained Rules ]=-
Older (<2.0) CRS used individual, “self-contained” actions in rules
	- If a rule triggered, it would either deny or pass and log
	- No intelligence was shared between rules
Not optimal from a rules management perspective (handling false positives/exceptions)
	- Editing the regex could blow it up
	- Typical method was to copy/paste rules into custom rules files and then edit rule logic
	  and disable core rule ID.
	- Heavily customized rules were less likely to be updated by the user
Not optimal from a security perspective
	- Not every site had the same risk tolerance
	- Lower severity alerts were largely ignored
	- Individual low severity alerts are not important but several low severity events
	  in the same transaction are.

-=[ CRS 2.0 - Collaborative Detection ]=-
== Rules - Detection and Management ==
Rules logic has changed by decoupling the inspection/detection from the blocking functionality
	- Rules log.pass and set transactional variables (tx) to track anomaly scores and to 
	  store meta-data about the rule match
	- This TX rule match data can be used by other 3rd party rules (converter Emerging Threats
	  Snort web attack rules) to more accurately correlate identified attacks with their
	  attack vector locations.
	- TX data of previous strong rule matches can also be used to conditionally apply weaker signatures
	  that normally would have a high fasle positive rate.
	- Rules also increase anomaly scores for both the attack category and global score which allows
	  users to set a threshold that is appropriate for them.
	- This also allows several low severity events to trigger alerts while individual ones are suppressed.
	- Exceptions may be handled by either increasing the overall anomaly score threshold, or
	  by adding rules to a local custom exceptions file where TX data of previous rule matches
	  may be inspected and anomaly scores re-adjusted based on the false positive criteria.

User can now globally update which variables to inspect and the anomaly score settings in the
modsecurity_crs_10_config.conf file.
	- PARANOID_MODE setting which will apply rules to locations that have a higher false positive rate
	- INBOUND_ANOMALY_SCORE setting will be populated in the inbound blocking file and if a transaction
	  score at the end of phase:2 is equal to or greater than this number, it will be denied.
	- OUTBOUND_ANOMALY_SCORE setting will be populated in the outbound blocking file and it a transaction
	  score at the end of phase:4 is equal to or greater than this number, it will be denied.

== Inbound/Outbound Blocking ==
The CRS rules themselves are configured with the pass action, which allows all the rules to be processed
and for the proposed anomaly scoring/collaborative detection concept to work.  The inbound/outbound anomaly
score levels may be set in the modsecurity_crs_10_config.conf file.  These scores will be evaluated in the
modsecurity_crs_49_inbound_blocking.conf and modsecurity_crs_59_outbound_blocking.conf files. 

== Alert Management - Correlated Event Creation ==
One of the top feedback items we have heard is that the CRS events in the Apache error_log file
were very chatty.  This was due to each rule triggering its own error_log entry.  What most people
wanted was for 1 correlated event to be generated that would give the user a higher level 
determination as to what the event category was.

To that end- each CRS rule will generate an audit log event Message entry but they will not log
to the error_log on their own.  These rules are now considered basic or reference events and 
may be reviewed in the audit log if the user wants to see what individual events contributed
to the overall anomaly score and event designation.

== Inbound/Outbound Correlation ==
After the transaction has completed (in the logging phase), the rules in the 
base_rules/modsecurity_crs_60_correlation.conf file will conduct further post-processing by 
analyzing any inbound events with any outbound events in order to provide a more
intelligent/priority correlated event.

	- Was there an inbound attack?
	- Was there an HTTP Status Code Error (4xx/5xx level)?
	- Was there an application information leak?

If an inbound attack was detected
and either an outbound application status code error or infolead was detected, then the overall 
event severity is raised -

	- 0: Emergency - is generated from correlation where there is an inbound attack and
         an outbound leakage.
	- 1: Alert - is generated from correlation where there is an inbound attack and an
         outbound application level error.


Core Rule Set Content
=====================

In order to provide generic web applications protection, the Core Rule Set 
uses the following techniques:

-=[ HTTP Protocol Validation and Protection ]=-
Detecting violations of the HTTP protocol and a locally 
defined usage policy. This first line of protection ensures that all abnormal HTTP
requests are detected. This line of defense eliminates a large number of
automated and non targeted attacks as well as protects the web server itself.

== base_rules/modsecurity_crs_20_protocol_violations.conf == 
Protocol vulnerabilities such as Response Splitting, Request Smuggling, Premature URL ending
	- Content length only for non GET/HEAD methods 
	- Non ASCII characters or encoding in headers
	- Valid use of headers (for example, content length is numerical)
	- Proxy Access

== base_rules/modsecurity_crs_21_protocol_anomalies.conf == 
Attack requests are different due to automation
	- Missing headers such as Host, Accept, User-Agent
	- Host is an IP address (common worm propagation method)

== base_rules/modsecurity_crs_23_request_limits.conf == 
Policy is usually application specific
	- Some restrictions can usually be applied generically
	- White lists can be build for specific environments
Limitations on Sizes
	- Request size, Upload size
	- # of parameters, length of parameter

== base_rules/modsecurity_crs_30_http_policy.conf == 
Items that can be allowed or restricted
	- Methods - Allow or restrict WebDAV, block abused methods such as CONNECT, TRACE or DEBUG 
	- File extensions – backup files, database files, ini files
	- Content-Types (and to some extent other headers)

-=[ Automation Detection ]=-
Automated clients are both a security risk and a
commercial risk. Automated crawlers collect information from your site, consume
bandwidth and might also search for vulnerabilities on the web site. Automation
detection is especially useful for generic detection of comments spam.

Detecting bots, crawlers, scanners and other surface malicious activity. 
Not aimed against targeted attacks, but against general malicious internet activity
	- Offloads a lot of cyberspace junk & noise
	- Effective against comment spam
	- Reduce event count

== base_rules/modsecurity_crs_35_bad_robots.conf == 
Detection of Malicious Robots
	- Unique request attributes: User-Agent header, URL, Headers
	- RBL Check of IP addresses
	- Detection of security scanners
	- Blocking can confuse security testing software (WAFW00f)

== optional_rules/modsecurity_crs_42_comment_spam.conf ==
This rules file is only relevant if you are concerned about comment SPAM attacks.
The rules file will run an RBL check against the source IP address at SPAMHAUS and will
cache the response for 1 day.  If the client sends subsequent requests, it will be denied
without having to re-run an RBL check.

This file will also look for comment SPAM posting attacks which submit URL links.


-=[ Common Web Attacks Protection ]=-
Common Web Attacks Protection Rules on the second level address the common web
application security attack methods. These are the issues that can appear in
any web application. Some of the issues addressed are:

- SQL Injection
- Cross-Site Scripting (XSS)
- OS Command execution
- Remote code inclusion
- LDAP Injection
- SSI Injection
- Information leak
- Buffer overflows
- File disclosure

== base_rules/modsecurity_crs_40_generic_attacks.conf == 
	- OS command injection and remote command access
	- Remote file inclusion
	- Session Fixation

== optional_rules/modsecurity_crs_40_experimental.conf ==
The rules in this file are considered BETA quality as they have not been rigorously tested.
They attempt to address advanced attacks such as HTTP Parameter Pollution or use new rule
features or techniques.

== base_rules/modsecurity_crs_42_tight_security.conf ==
This rules file attempts to identify all directory traversal variations.  It is prone to a high
level of false positives so set PARANOID_MODE if you want to run these rules. 

== base_rules/modsecurity_crs_41_sql_injection.conf ==
        - SQL injection and blind SQL injection

== base_rules/modsecurity_crs_41_xss.conf ==
	- Cross site scripting (XSS)

== base_rules/modsecurity_crs_41_phpids_converter.conf ==
== base_rules/modsecurity_crs_41_phpids_filters.conf ==
Trustwave's SpiderLabs received authorization from PHPIDS (http://phpids.net/) to convert their 
rules and include them in the CRS
	- Thanks to Mario Heiderich

Converted version of PHPIDS Converter.php functionality.
https://svn.php-ids.org/svn/trunk/lib/IDS/Converter.php
These rules look for common evasion tactics.

Converted version of PHPIDS default_filters.xml data.
https://svn.php-ids.org/svn/trunk/lib/IDS/default_filter.xml
	- Filters are heavily tested by the community and updated frequently
	- ~70 regular expression rules to detect common attack payloads
	- XSS
	- SQL Injection
	- RFI

== optional_rules/modsecurity_crs_46_et_sql_injection.conf ==
== optional_rules/modsecurity_crs_46_et_web_rules.conf == 
Due to the high number of rules and the possible impact on performance, these rules
have been placed in the optional_rules directory.

Trustwave's SpiderLabs received authorization from ET to convert their Snort rules and include them in the CRS
http://www.emergingthreats.net/ 

Converted the following ET Snort rule files
	- emerging-web_server.rules
	- emerging-web_specific_apps.rules 

Identifying attacks against known web vulnerabilities does have value 
	- Raised threat level
	- If done correctly, lessens false positives

The issue to overcome is that the PCRE RegExs used in the rules are pretty poor.  What we want
to do is to combine the *what* of our generic attack payload detection (attack payloads) with 
the *where* (attack vector - URL + Parameter Name) of the ET known vuln data. The approach we
took was to have most of the ET rules look for the attack vector data and then simply check all
saved TX data for a corresponding attack vector match.


-=[ Trojan Protection ]=-
ModSecurity Core Rule Set detects access to back doors
installed on a web server. This feature is very important in a hosting
environment when some of this backdoors may be uploaded in a legitimate way and
used maliciously. In addition the Core Rule Set includes a hook for adding
an Anti-Virus program such as ClamAV for checking file uploads.

== base_rules/modsecurity_crs_45_trojans.conf ==
	- Check uploading of http backdoor page
	- Access detection
	- Known signatures (x_key header)
	- Generic file management output (gid, uid, drwx, c:\)

-=[ InfoLeakages ]=-
If all fails, the Core Rule Set will detect errors sent by
the web server. Detecting and blocking errors prevents attackers from
collecting reconnaissance information about the web application and also server
as a last line of defense in case an attack was not detected eariler.

== base_rules/modsecurity_crs_50_outbound.conf ==
	- HTTP Error Response Status Codes
	- SQL Information Leakage
	- Stack Dumps
	- Source Code Leakage


-=[ Request Header Tagging ]=-
This concept is similar to anti-SPAM SMTP apps that will add additional mime headers
to emails providing the SPAM detection analysis information.  The CRS is attempting
to mimic this concept at the HTTP layer by adding additional request headers that
provide insight into any ModSecurity events that may have triggered during processing.
The advantage of this approach is that it allows a WAF to be in a detection-only mode
while still providing attack data to the destination application server.  The recieving
app server may then inspect the WAF request headers and make a determination whether
or not to process the transaction.  This concept is valuable in distributed web environments
and hosting architectures where a determination to block may only be appropriate at the
destination app server.

== optional_rules/modsecurity_crs_49_header_tagging.conf ==
This rules file will take all of the TX attack variable data and populate Apache ENV
variables that Apache can then use to add X-WAF-Event request header data to the
request.

Example showing the consolidated X-WAF-Events and X-WAF-Score data -

GET /path/to/foo.php?test=1%27%20or%20%272%27=%272%27;-- HTTP/1.1
Host: www.example.com 
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.5) Gecko/20091109 Ubuntu/9.10 (karmic) Firefox/3.5.5
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
X-WAF-Events: TX: / 999935-Detects common comment types-WEB_ATTACK/INJECTION-ARGS:test, TX:999923-Detects JavaScript location/document property access and window access obfuscation-WEB_ATTACK/INJECTION-REQUEST_URI_RAW, TX:950001-WEB_ATTACK/SQL_INJECTION-ARGS:test
X-WAF-Score: Total=48; sqli=2; xss=
Connection: Keep-Alive


