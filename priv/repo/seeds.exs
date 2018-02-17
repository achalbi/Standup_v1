# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Standup.Repo.insert!(%Standup.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Standup.Repo.insert!(%Standup.Accounts.Role{
    key: "admin",
    name: "Administrator"
})

Standup.Repo.insert!(%Standup.Accounts.Role{
    key: "user",
    name: "Regular user"
})

Standup.Repo.insert!(%Standup.StatusTrack.WorkStatusType{
    name: "Daily",
    description: "This option is used to track Daily Work status",
    period: "1",
})