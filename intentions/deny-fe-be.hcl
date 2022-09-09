Kind = "service-intentions"

Name = "backend-randomer"
Sources = [
  {
    Name   = "frontend-randomer"
    Action = "deny"
  }
]
