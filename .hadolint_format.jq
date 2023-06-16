select(. != null) |
  "| VULN_ID | LEVEL | FILE | FINDING |", "| --- | --- | --- | --- |",
  (.[] |
    [
      "|`\(.code)`|`\(.level)`|`\(.file)`|\(.message | (split("||") | join("or")))|"
    ] | join("\n")
  )
