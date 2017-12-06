defmodule Standup.Guardian.AuthPipeline.Browser do
  use Guardian.Plug.Pipeline, otp_app: :standup,
                              module: Standup.Guardian,
                              error_handler: Standup.Auth.ErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.LoadResource, ensure: true, allow_blank: true
end

defmodule Standup.Guardian.AuthPipeline.JSON do
  use Guardian.Plug.Pipeline, otp_app: :standup,
                              module: Standup.Guardian,
                              error_handler: Standup.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end

defmodule Standup.Guardian.AuthPipeline.Authenticate do
  use Guardian.Plug.Pipeline, otp_app: :standup,
                              module: Standup.Guardian,
                              error_handler: Standup.Auth.ErrorHandler

  plug Guardian.Plug.EnsureAuthenticated
end



# defmodule Standup.Guardian.AuthPipeline do
#   @claims %{typ: "access"}

#   use Guardian.Plug.Pipeline, otp_app: :my_app,
#                               module: Standup.Guardian,
#                               error_handler: Standup.Guardian.AuthErrorHandler

#   plug Guardian.Plug.VerifySession, claims: @claims
#   plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer"
#   plug Guardian.Plug.EnsureAuthenticated
#   plug Guardian.Plug.LoadResource, ensure: true
# end