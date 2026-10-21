import Config

config :logger, level: :warning

config :tesla, adapter: Tesla.Mock

# the schedule is only set in runtime.exs, so the job must not be run in tests
config :bonsaika, Bonsaika.Scheduler, jobs: [update_member_channel: [state: :inactive]]

config :bonsaika,
  authentik_server: "https://authentik.test",
  authentik_token: "token",
  authentik_group: "member",
  matrix_server: "https://matrix.test",
  matrix_token: "token",
  matrix_room: "!room:x-hain.de",
  matrix_space: "!space:x-hain.de",
  whitelist: ["@bot:x-hain.de"]
