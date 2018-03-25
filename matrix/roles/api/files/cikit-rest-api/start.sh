#!/usr/bin/env bash -e

cd /usr/local/share/cikit/matrix/roles/api/files/cikit-rest-api

container_exec()
{
  docker exec -i cikit-rest-api.loc bash -c "$@"
}

cikit env/start --ignore-cikit-mount --privileged
container_exec "apt install ssh lxc iptables -y"
cikit matrix/provision --install-api
container_exec "service docker start && systemctl enable docker"

if [ "test" == $1 ]; then
  container_exec "cd /var/www/cikit-rest-api && npm test && npm run test-report-coveralls"
fi
