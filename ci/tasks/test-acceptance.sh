#!/bin/sh
set -e -x

ls -al bosh-release

/usr/bin/start-bosh &

sleep 10s
bosh target 127.0.0.1

bosh upload release bosh-release/config-server-acceptance.tgz
bosh upload stemcell https://s3.amazonaws.com/bosh-warden-stemcells/bosh-stemcell-3262.2-warden-boshlite-ubuntu-trusty-go_agent.tgz

bosh update cloud-config config-server/ci/scripts/cloud-config.yml

UUID=$(bosh status --uuid)
sed -i "s/DIRECTOR_UUID_GOES_HERE/${UUID}/g" config-server/ci/scripts/deployment.yml

bosh releases
bosh deployment config-server/ci/scripts/deployment.yml
bosh -n deploy

curl -k -v -X PUT https://10.244.0.2:8080/v1/data/a -d '{"value":"aaaaa"}' -H 'Authorization: bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Jvc2guZXhhbXBsZS5jb20iLCJzdWIiOiJtYWlsdG86Ym9zaC1zbXVyZkBleGFtcGxlLmNvbSIsIm5iZiI6MTQ3NDA1NDAwMCwiZXhwIjoyOTc3NzE0NzQ4LCJpYXQiOjE0NzQwNTQwMDAsImp0aSI6ImlkMTIzNDU2IiwidHlwIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9ib3NoL3NtdXJmIn0.aBd4OgoXIY0CMMT5CXnnlFjAlKH25k38inA1kAiCgGGbFLnKNG3EJZGzeVeCfNE8iMCt-xTqmwLu978x-X1Z6T-4VCzGg6yLjvXDJnUlt1scBO2K23z3JP04cjGxQYjs0liI-ieFieo8F3DOm_kjIBOKEN8Z3dg7DyTsgxxkE6XIDDbxt2QY2CM3FUtK7AsyviB9UJbeef-2wstdPl7qhp_8QjqlEiYuba_TTHFix-LqGDM0bSbBu8v6V_t3o6E0fFOdzPixlBEf0qp4YbkRXI4TjmHj7PE8xItqW0jSuMnBqdY3_SP21S5K1eeBfZwoHBDHsttjyiBuenK3cHKKlw'