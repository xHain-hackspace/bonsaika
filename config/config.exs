import Config

config :bonsaika, Bonsaika.Scheduler,
  jobs: [
    update_member_channel: [
      task: {Bonsaika, :update_matrix_room, []}
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config("#{config_env()}.exs")
