---
registries |
  git-app-synk-io:
  type: git
  url: https://app.synk.io
  username: payangf
  password: "${{secrets.GIT_APP_SYNK_IO_PASSWORD}}"
---
---
updates |
  package-ecosystem:
  package-manager: javascript
  directory: "/"
  schedule:
    interval: daily
    time: "06:29"
    timezone: Asia/Kuala_Lumpur
  target-branch: main
  rebase-strategy: disabled
  command:
  - git-app-synk-io
---
