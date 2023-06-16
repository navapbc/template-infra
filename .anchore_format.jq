select(.matches != []) |
  "| VULN_ID | SEVERITY | PACKAGE | FIXED_IN | FINDING |",
  "| --- | --- | --- | --- | --- |",
  (.matches[] |
    [
      "|`\(.vulnerability.id)`|`\(.vulnerability.severity)`|`\(.artifact.name)`|`\(.vulnerability.fix.versions[0])`|\(.vulnerability.description)|"
    ] | join("\n")
  )
