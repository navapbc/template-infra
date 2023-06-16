select(.details != null) |
  "| VULN_ID | LEVEL | FINDING |", "| --- | --- | --- |",
  (.details[] |
    [
      "|`\(.code)`|`\(.level)`|\(.alerts[])|"
    ] | join("\n")
  )
