import Config

config :bonsaika,
  authentik_server: System.fetch_env!("BONSAIKA_AUTHENTIK_SERVER"),
  authentik_token: System.fetch_env!("BONSAIKA_AUTHENTIK_TOKEN"),
  matrix_server: System.fetch_env!("BONSAIKA_MATRIX_SERVER"),
  matrix_token: System.fetch_env!("BONSAIKA_MATRIX_TOKEN"),
  matrix_room: System.fetch_env!("BONSAIKA_MATRIX_ROOM")
