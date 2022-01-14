package rules.ruleone

resource_type = "aws_elasticache_replication_group"

__rego__metadoc__ := {
    "id": "CUSTOM_ERG_TRANSIT_AND_REST_ENCRYPTION",
    "custom": {
      "severity": "Medium",
      "providers": ["AWS", "REPOSITORY"]
      },
    "title": "rule-one",
    "description": "This is a custom rule that ensures that Elasticache Replication Groups have transit and rest encryption enabled!"
}

deny[msg] {
    not input.transit_encryption_enabled == true
    msg = "Please set transit_encryption_enabled to true"
} {
    not input.at_rest_encryption_enabled == true
    msg = "Please set at_rest_encryption_enabled to true"
}
