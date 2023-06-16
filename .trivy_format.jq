select(.Results != null) |
  "| VULN_ID | SEVERITY | PACKAGE | FIXED_IN | FINDING |",
  "| --- | --- | --- | --- | --- |",
  (.Results[].Vulnerabilities[] |
    [
      "|`\(.VulnerabilityID)`|`\(.Severity)`|`\(.PkgName)`|`\(.FixedVersion)`|\(.Title)|"
    ] | join("\n")
  )
