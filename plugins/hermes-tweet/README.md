# hermes-tweet

A Claude Code plugin for operating [Hermes Tweet](https://github.com/Xquik-dev/hermes-tweet), the native Hermes Agent X/Twitter plugin.

Use it when a Hermes Agent session needs X/Twitter research, monitoring,
publishing guidance, or troubleshooting around Hermes Tweet's read-first
tooling and action gates.

## Install Hermes Tweet

```bash
hermes plugins install Xquik-dev/hermes-tweet --enable
```

Configure `XQUIK_API_KEY` where the Hermes runtime executes. Keep
`HERMES_TWEET_ENABLE_ACTIONS=false` unless an interactive session has an
explicit approval step for account-changing actions.

## Skill

- **hermes-tweet** — load Hermes Tweet install, routing, and safety guidance for
  Hermes Agent X/Twitter workflows.

## Links

- [Hermes Tweet source](https://github.com/Xquik-dev/hermes-tweet)
- [Hermes Tweet package](https://pypi.org/project/hermes-tweet/)
- [Hermes Agent](https://github.com/NousResearch/hermes-agent)
