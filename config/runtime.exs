import Config

# The test environment uses fake settings from config/test.exs
if config_env() != :test do
  config :bonsaika,
    authentik_server: System.fetch_env!("BONSAIKA_AUTHENTIK_SERVER"),
    authentik_token: System.fetch_env!("BONSAIKA_AUTHENTIK_TOKEN"),
    authentik_member_group: System.fetch_env!("BONSAIKA_AUTHENTIK_GROUP"),
    authentik_dev_group: System.fetch_env!("BONSAIKA_AUTHENTIK_RECHENWERK_GROUP"),
    matrix_server: System.fetch_env!("BONSAIKA_MATRIX_SERVER"),
    matrix_token: System.fetch_env!("BONSAIKA_MATRIX_TOKEN"),
    matrix_room: System.fetch_env!("BONSAIKA_MATRIX_ROOM"),
    matrix_space: System.fetch_env!("BONSAIKA_MATRIX_SPACE"),
    forjego_token: System.fetch_env!("BONSAIKA_FORJEGO_TOKEN"),
    forjego_org: System.fetch_env!("BONSAIKA_FORJEGO_ORG"),
    forjego_server: System.fetch_env!("BONSAIKA_FORJEGO_SERVER"),
    forjego_team: System.fetch_env!("BONSAIKA_FORJEGO_TEAM_ID"),

    matrix_whitelist:
      "BONSAIKA_MATRIX_WHITELIST"
      |> System.fetch_env!()
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1),
    
    codeberg_whitelist:
      "BONSAIKA_CODEBERG_WHITELIST"
      |> System.fetch_env!()
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)

  config :bonsaika, Bonsaika.Scheduler,
    jobs: [
      update_member_channel: [
        schedule: System.get_env("BONSAIKA_SCHEDULE", "*/2 * * * *")
      ]
    ]
end
