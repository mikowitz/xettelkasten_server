Mox.defmock(GitBehaviourMock, for: XettelkastenServer.GitBehaviour)
Application.put_env(:xettelkasten_server, :git_implementation, GitBehaviourMock)

ExUnit.start(exclude: [delayed: true])
