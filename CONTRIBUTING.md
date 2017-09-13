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

FIXME:

- Add rule id numbering
- Add naming conventions for vars
