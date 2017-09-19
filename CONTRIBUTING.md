# Contributing to the CRS

We value third-party contributions. To keep things simple for you and us,
please adhere to the following contributing guidelines.

## Getting Started

* You will need a [GitHub account](https://github.com/signup/free).
* Submit a [ticket for your issue](https://github.com/SpiderLabs/owasp-modsecurity-crs/issues), assuming one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you specify the version that you know has the issue.
  * Bonus points for submitting a failing test along with the ticket.
* If you don't have push access, fork the repository on GitHub.

## Making Changes

* Please base your changes on branch ```v3.1/dev```
* Create a topic branch for your feature or bug fix.
* Make commits of logical units.
* Make sure your commits adhere to the rules guidelines below.
* Make sure your commit messages are in the [proper format](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html): The first line of the message should have 50 characters or less, separated by a blank line from the (optional) body. The body should be wrapped at 70 characters and paragraphs separated by blank lines. Bulleted lists are also fine.

## General Formatting Guidelines for rules contributions

 - 4 spaces per indentation level, no tabs
 - no trailing whitespace at EOL or trailing blank lines at EOF
 - comments are good, especially when they clearly explain the rule
 - try to adhere to a 80 character line length limit
 - if it is a [chained rule](https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual#chain), alignment should be like
```
    SecRule .. ..\
        "...."
        SecRule .. ..\
            "..."
            SecRule .. ..\
                ".."
```
 - use quotes even if there is only one action, it improves readability (e.g use `"chain"`, not `chain`, or `"ctl:requestBodyAccess=Off"` instead of `ctl:requestBodyAccess=Off`)
 - always use numbers for phases, instead of names
 - format your `SecMarker` between double quotes, using UPPERCASE and separating words using hyphens. Examples are
```
    SecMarker "END-RESPONSE-959-BLOCKING-EVALUATION"
    SecMarker "END-REQUEST-910-IP-REPUTATION"
```
 - the proposed order for actions is:
```
    id
    phase
    disruptive-action
    status
    capture
    t:xxx
    log
    nolog
    auditlog
    noauditlog
    msg
    logdata
    tag
    sanitiseArg
    sanitiseRequestHeader
    sanitiseMatched
    sanitiseMatchedBytes
    ctl
    setenv
    setvar
    chain
    skip
    skipAfter
```

## Rules compliance with each Paranoia Level (PL)

Rules in the CRS are organized in Paranoia Levels, which are described below.

**PL0:**

* Modsec installed, but almost no rules
* Compliance check box ok but no flowers

**PL1:**

* Compliance check box ok with flowers
* Atomic checks in single rule
* Confirmed matches only, all scores are allowed
* No false positives / Low FP
* False negatives are ok
* Your AWS free tier VM will run this for 100's sites
* Easy log management, grep is your friend

**PL2:**

* Compliance check box ok you are getting in security side
* Chains usage is OK
* Confirmed matches use score critical
* Matches that cause false positives are limited to use score notice or warning
* Low False positive rates
* False negatives are not desirable
* Your AWS free tier VM will run this for 100 sites
* Easy log management, grep is your friend, turn yourself into regex/greping pro

**PL3:**

* Compliance check box ok you are well into security, check before shooting
* Chains usage with complex regex look arounds and macro expansions
* Confirmed matches use score warning or critical
* Matches that cause false positives are limited to use score notice
* False positive rates increased but limited to multiple matches (not single string)
* False negatives are evil
* Your AWS free tier VM will run this for 10's sites
* Using LB is recommended
* Not easy to hard log management, turn yourself into regex/greping ninja and get a SIEM

**PL4:**

* Compliance check box ok you bread security and you shoot whatever thing moves, shoot fist ask later
* Every item is inspected
* Variable creations allowed to avoid engine limitations
* Confirmed matches use score notice, warning or critical
* Matches that cause false positives are limited to use score notice and warning
* False positive rates increased (even on single string)
* False negatives are a kick in the ...
* Check everything against RFC and white listed values for most popular elements
* Your AWS free tier VM will run this for a site
* You better use a LB
* Beg you are using ELK to manage your logs and have your ninja sword always sharp and have spare swords available at all times
* Red pill or blue pill?

**PL5:**

* Damn, why you took the red one?!
* go beyond modsec capabilities
* go Where No Man Has Gone Before
* Your WAF accepts only a single string with 1 letter in it hahahaha

## ID Numbering Scheme

The CRS project used the numerical id rule namespace from 900,000 to 999,999 for the CRS rules as well as 9,000,000 to 9,999,999 for default CRS rule exclusion packages.

Rules applying to the incoming request use the id range 900,000 to 949,999.
Rules applying to the outgoing response use the id range 950,000 to 999,999.

The rules are grouped by vulnerability class they address (SQLi, RCE, etc.) or functionality (initialization). These groups occupy blocks of thousands (e.g. SQLi: 942,000 - 942,999).
The grouped rules are defined in files dedicated to a single group or functionality. The filename takes up the first three digits of the rule ids defined within the file (e.g. SQLi: REQUEST-942-APPLICATION-ATTACK-SQLI.conf).

The individual rule files for the vulnerability classes are organized by the paranoia level of the rules. PL 1 is first, then PL 2 etc.

The block from 9XX000 - 9XX099 is reserved for use by CRS helper functionality. There are no blocking or filtering rules in this block.

Among the rules serving a CRS helper functionality are rules that skip rules depending on the paranoia level. These rules always use the following reserved rule ids: 9XX011-9XX018 with very few exceptions.

The blocking or filter rules start with 9XX100 with a step width of 10. E.g. 9XX100, 9XX110, 9XX120 etc. The rule id does not correspond directly with the paranoia level of a rule. Given the size of a rule group and the organization by lower PL rules first, PL2 and above tend to have rule IDs with higher numbers.

Within a rule file / block, there are sometimes smaller groups of rules that belong to together. They are closely linked and very often represent copies of the original rules with a stricter limit (alternatively, they can represent the same rule addressing a different target in a second rule where this was necessary). These are stricter siblings of the base rule. Stricter siblings usually share the first five digits of the rule ID and raise the rule ID by one. E.g. Base rule at 9XX160, stricter sibling at 9XX161.

Stricter siblings often have a different paranoia level. This means that the base rule and the stricter sibling do not reside next to one another in the rule file. Instead they are ordered in their appropriate paranoia level and can be linked via the first digits of the rule id. It is a good practice to introduce stricter siblings together with the base rule in the comments of the base rule and to reference the base rule with the keyword stricter sibling in the comments of the stricter sibling. E.g. "... This is
performed in two separate stricter siblings of this rule: 9XXXX1 and 9XXXX2", "This is a stricter sibling of rule 9XXXX0."

FIXME:

- Add naming conventions for vars
