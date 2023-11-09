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

