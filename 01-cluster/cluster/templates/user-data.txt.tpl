MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/usr/bin/env bash
sed -i.bak "s/ECS_IMAGE_MINIMUM_CLEANUP_AGE=10m/ECS_IMAGE_MINIMUM_CLEANUP_AGE=60m/" /etc/ecs/ecs.config

--==MYBOUNDARY==--
