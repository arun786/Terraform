region = "us-west-2"
cidr_block = "0.0.0.0/0"
port = "80"
plugins = [
  "amazon-ecr",
  "workflow-aggregator",
  "gradle",
  "github-branch-source",
  "ldap",
  "matrix-auth",
  "jdk-tool",
  "ssh-slaves"]
private_key_path = "C:\\Users\\Adwiti\\Desktop\\awskey\\keyForVPC.pem"
key_name = "keyForVPC"