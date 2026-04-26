# bonsaika
[![Docker build](https://github.com/xHain-hackspace/bonsaika/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/xHain-hackspace/bonsaika/actions/workflows/docker-publish.yml)

>Bonsaika, derived from the Japanese words "Bonsai" (盆栽), meaning tray planting, and "ka" (家), denoting a person or specialist, refers to individuals devoted to the meticulous care, cultivation, and artistic refinement of Bonsai trees.

bonsaika takes care to update the chat room in out matrix space. It commuinicates with our [authentik](https://login.x-hain.de) instance to retrieve the current list of members and their matrix usernames. With this list it updates the member channel in our [matrix space](https://matrix.to/#/#xhain:x-hain.de).


- [bonsaika](#bonsaika)
  - [Configuration](#configuration)

## Configuration

You need to define the following environment variables to run bonsaika.

| Variable                  | Description                                                 |
| ------------------------- | ----------------------------------------------------------- |
| BONSAIKA_AUTHENTIK_SERVER | The url of the authentik server (`https://login.x-hain.de`) |
| BONSAIKA_AUTHENTIK_TOKEN  | The token needed to authenticate at the authentik server    |
| BONSAIKA_MATRIX_SERVER    | the url of the matrix server                                |
| BONSAIKA_MATRIX_TOKEN     | The token needed to authenticate at the matrix server       |
| BONSAIKA_MATRIX_ROOM      | The matrix room managed by bonsakai                         |


## Start

`docker build . -t bonsaika`
`docker run --env BONSAIKA_AUTHENTIK_SERVER="{BONSAIKA_AUTHENTIK_SERVER}" --env BONSAIKA_AUTHENTIK_TOKEN="{BONSAIKA_AUTHENTIK_TOKEN}" --env BONSAIKA_MATRIX_SERVER="{BONSAIKA_MATRIX_SERVER}" --env BONSAIKA_MATRIX_TOKEN="BONSAIKA_MATRIX_TOKEN" --env BONSAIKA_MATRIX_ROOM="BONSAIKA_MATRIX_ROOM" bonsaika` 

