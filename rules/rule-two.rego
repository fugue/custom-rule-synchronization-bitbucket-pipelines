package rules.ruletwo

# Simple rules must specify the resource type they will police.
resource_type = "aws_ebs_volume"

__rego__metadoc__ := {
    "id": "CUSTOM_EBS_002",
    "custom": {
      "severity": "Medium",
      "providers": ["AWS", "REPOSITORY"]
      },
    "title": "rule-two",
    "description": "EBS volumes must be encrypted per company policy!"
}

# Simple rules must specify `allow` or `deny`.  For this example, we use
# an `allow` rule to check that the EC2 instance is encrypted.

deny[msg] {
  not input.encrypted == true
  msg = "Per company policy, you must encrypt your EBS volumes. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html"
}
