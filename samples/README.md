# SDK sample starting points

These are the pre-instrumentation web app agents used by the SDK labs:

| Folder | Stack | Lab |
| --- | --- | --- |
| [`dotnet/`](./dotnet/) | .NET 10, Microsoft Agent Framework, Blazor Server | [A365-02A](../docs/02a-web-obo-dotnet.md) |
| [`python/`](./python/) | Python 3.12, LangChain, FastAPI | [A365-02B](../docs/02b-web-obo-python.md) |

Both agents answer Microsoft documentation questions using Azure OpenAI and the Microsoft Learn MCP server. They include dormant Microsoft Entra sign-in plumbing and blueprint configuration, but no Agent 365 instrumentation. Start here and add registration, OBO and observability during the labs; these are not the finished agents.

The Node.js starter is not copied into this repository. Follow [A365-02C](../docs/02c-web-obo-nodejs.md) to use the external runbook sample.

## Source provenance

Copied from [qmatteoq/agent365-runbook](https://github.com/qmatteoq/agent365-runbook) at immutable commit [`98aecf88dc6ab66f87711751b1e61e892e569ce1`](https://github.com/qmatteoq/agent365-runbook/commit/98aecf88dc6ab66f87711751b1e61e892e569ce1), resolved from `main` for this import.

| Local folder | Source path at that commit |
| --- | --- |
| `samples/dotnet` | [`01-scenarios/Web-App-Agent-User-OBO/0.Resources/Starting-point/dotnet`](https://github.com/qmatteoq/agent365-runbook/tree/98aecf88dc6ab66f87711751b1e61e892e569ce1/01-scenarios/Web-App-Agent-User-OBO/0.Resources/Starting-point/dotnet) |
| `samples/python` | [`01-scenarios/Web-App-Agent-User-OBO/0.Resources/Starting-point/python`](https://github.com/qmatteoq/agent365-runbook/tree/98aecf88dc6ab66f87711751b1e61e892e569ce1/01-scenarios/Web-App-Agent-User-OBO/0.Resources/Starting-point/python) |

The complete tracked starters are retained, including project names, static assets and source maps, launch settings, Python IDE files, `.env.example`, `.python-version` and `uv.lock`. No real secrets, generated build outputs, virtual environments or caches are included.

The only adaptations within the imported starters are README links: runbook links now use immutable upstream URLs, and the Python README's Node.js sibling link points to the external source. Runtime code, configuration, dependency manifests and the lock file are unchanged. The labs require .NET 10 to match the source project's `net10.0` target.

The source owner requested this copy. No top-level license was present in the source repository at the pinned commit; this import does not add or imply one. Existing third-party notices, including the Bootstrap copyright and license headers in the bundled assets, are retained unchanged.
