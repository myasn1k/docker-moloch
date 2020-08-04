# Docker Moloch

Docker Moloch container

Image is based on the [ubuntu](https://registry.hub.docker.com/u/ubuntu/) base image

Use it with elastic search whithout security (x-pack), there's a
`docker-compose.yml` that does everything for you

## Env vars available

| NAME              | DEFAULT VALUE   |  NOTES                                                                   |
| --------------    | --------------- | ---------------------------------------------------------------------    |
| MOLOCH_VERSION    | 2.3.2-1_amd64   | According https://molo.ch/#downloads                                     |
| UBUNTU_VERSION    | 18.04           | Like version of ubuntu base container                                    |
| ES_HOST           | elasticsearch   | If you us docker-compose, you should name your service  `elasticsearch`  |
| ES_PORT           | 9200            | Elastic search port in elastic search container or exposed in any server |
| MOLOCH_PASSWORD   | changeme           | To connect admin use on the web interface                                |
| MOLOCH_INTERFACE  | eth0            | Network interface to listen                                              |
