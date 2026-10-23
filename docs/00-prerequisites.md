# SDK requirements

**Main flow: [1. Copilot Studio](./01-copilot-studio.md) → 2. SDK requirements → [3. .NET](./02a-web-obo-dotnet.md)**

Complete this setup after Copilot Studio and before the .NET lab. These requirements also apply to the optional [Python](./02b-web-obo-python.md) and [JavaScript / Node.js](./02c-web-obo-nodejs.md) labs; install their language-specific tools only if you plan to take them.

The first lab has its own [Copilot Studio prerequisites](./01-copilot-studio.md#prerequisites). You do not need the SDK tools to complete that lab.

Every SDK lab in this repository requires the same three things: tools on your machine, licences in your tenant, and permissions on your account.

## The tools you need on your machine

| Requirement | Minimum | Check it with | What needs it |
| --- | --- | --- | --- |
| .NET SDK | 10.0 for the .NET sample; 8.0 or later for the CLI | `dotnet --list-sdks` | The Agent 365 CLI itself, and .NET agents |
| Agent 365 CLI | latest | `a365 -h` | Every SDK lab |
| PowerShell | 7.0 | `pwsh --version` | The consent scripts |
| Azure CLI | latest | `az version` | Signing in to the tenant |
| Az PowerShell module | latest | `Get-Module -ListAvailable Az.Accounts` | Granting permissions |
| Git | any | `git --version` | Cloning the sample agents |
| Python | 3.12 | `python --version` | Optional Python lab only |
| uv | latest | `uv --version` | Optional Python lab only |
| Node.js | 20.10 | `node --version` | Optional JavaScript / Node.js lab only |

> The Agent 365 CLI requires .NET 8.0 or later, even if your agent is written in Python or TypeScript. It is distributed as a .NET global tool; the main .NET lab targets .NET 10 and requires the .NET 10 SDK. These requirements are for the **SDK labs** only; Lab A365-01 does not use the CLI.

### Install or update the Agent 365 CLI

Install the **`Microsoft.Agents.A365.DevTools.Cli`** package to use the `a365` command. See [Install and use the Agent 365 CLI](https://learn.microsoft.com/microsoft-agent-365/developer/agent-365-cli?tabs=windows) for the CLI reference.

Open PowerShell and run `dotnet tool list --global`. If `Microsoft.Agents.A365.DevTools.Cli` is listed, use the update command below. Otherwise, use the installation command. Package IDs may appear in lowercase.

**First installation**

```powershell
dotnet tool install --global Microsoft.Agents.A365.DevTools.Cli
```

**Update an existing installation**

```powershell
dotnet tool update --global Microsoft.Agents.A365.DevTools.Cli
```

**If installation reports an `a365` command conflict**

Check `dotnet tool list --global`. If `Microsoft.Agents365.CLI` is listed, run the following commands to replace it with `Microsoft.Agents.A365.DevTools.Cli`:

```powershell
dotnet tool uninstall --global Microsoft.Agents365.CLI
dotnet tool install --global Microsoft.Agents.A365.DevTools.Cli
```

Use your organization's configured package feeds. If the package is unavailable, ask your administrator to make it available.

**Verify the installation**

```powershell
dotnet tool list --global
a365 -h
```

Confirm the tool list contains `Microsoft.Agents.A365.DevTools.Cli` and that `a365 -h` displays help. If Windows cannot find `a365`, open a new terminal and check that `%USERPROFILE%\.dotnet\tools` is on your `PATH`.

## Installing the Agent 365 Skills

Most of the Agent 365 work in the **SDK labs** is done by asking an AI coding assistant to do it, using the [Agent 365 Skills](https://github.com/microsoft/agent365-skills). The skills work with every major assistant, and each one installs them differently. Pick the row that matches the tool you use:

| Your assistant | How to install |
| --- | --- |
| Claude Code (app, web or CLI) | Run `/plugin marketplace add https://github.com/microsoft/agent365-skills` inside a session, then `/plugin install agent365@agent365-skills` |
| GitHub Copilot CLI, VS Code agent mode | `gh skill add microsoft/agent365-skills` |
| Cursor, Windsurf, Codex CLI, Gemini CLI, or anything else that reads `.agents/skills/` | `node /path/to/agent365-skills/scripts/install.js`, run from your agent project directory |

Run the install from **your agent's project folder**, so the skills can see the code they are meant to change.

> Lab A365-01 does not use these coding-assistant skills. It uses a native skill created inside the Copilot Studio browser authoring experience.

## The licences your tenant needs for the SDK labs

| Requirement | What to know |
| --- | --- |
| Microsoft 365 tenant | With Agent 365 enabled |
| Agent 365 licence | **At least one user in the tenant must hold one** |
| Azure subscription | For the Azure OpenAI resource the agent reasons with |

> If nobody in the tenant holds an Agent 365 licence, telemetry is accepted with `HTTP 200` and then discarded. The logs report a successful export, Defender shows no data, and no error is raised. Verify the licence before you start.

## The permissions you need on your account for the SDK labs

| Permission | Who needs it | What it is for |
| --- | --- | --- |
| Application Developer (or higher) | You | Creating app registrations |
| Global Administrator | You *or* a colleague | Granting admin consent to the blueprint |
| Azure OpenAI access | You | The model the agent uses. For the Entra credential path you need the **Cognitive Services OpenAI User** role on the resource; for key auth, access to the resource keys |

> You do not need to be a Global Administrator yourself. The CLI performs every action it is permitted to perform, then prints a PowerShell snippet for an administrator to run for the rest. Identify the person who will run it before you start.

The web on-behalf-of labs contain two of these handoffs: one when the agent is registered, and one when the sign-in app is given permission to call the agent's blueprint. Each takes an administrator about a minute.

## Getting the sample agent

The SDK labs start from a research assistant that answers questions about Microsoft products by searching the Microsoft Learn MCP server. Clone this repository and open the local .NET sample for the main flow:

```bash
git clone https://github.com/microsoft/agent365-labs
cd agent365-labs/samples/dotnet
```

The .NET and Python starters are local to this repository. Node.js remains in the external runbook repository:

| Lab | Folder |
| --- | --- |
| A365-02A (.NET, main flow) | `agent365-labs/samples/dotnet/` |
| A365-02B (Python, optional) | `agent365-labs/samples/python/` |
| A365-02C (JavaScript / Node.js, optional) | External: `agent365-runbook/01-scenarios/Web-App-Agent-User-OBO/0.Resources/Starting-point/nodejs/` |

If you already cloned this repository, open the relevant folder in that checkout rather than cloning it again. For Node.js, follow the separate clone instructions in [Lab A365-02C](./02c-web-obo-nodejs.md).

You can bring your own agent instead. The SDK labs assume two things about it: it runs as a web app with one HTTP request per turn, and there is a single place in the code where a turn begins and ends, which is where the instrumentation goes.

## An Azure OpenAI resource for the SDK labs

The SDK agents call an **Azure OpenAI model deployed in Microsoft Foundry**. You will create a **Foundry project**, which is your workspace in the portal, and a **Foundry resource**, which holds the model deployments, endpoint, and access settings. A model deployment makes a particular model available for your agent to call.

These instructions use the **new Microsoft Foundry portal**. You will create a project, deploy a chat model, test it, and collect the connection settings for the labs. If your facilitator provides a project and deployment, start at Step 4.

> **Costs:** model calls, including playground tests, incur Azure charges. A Microsoft 365 or Agent 365 licence does not include Azure OpenAI usage. Use a subscription approved for the lab and review [Azure OpenAI pricing](https://azure.microsoft.com/pricing/details/cognitive-services/openai-service/) before deploying.

### Step 1: Sign in and check your Azure subscription

1. Open the [Azure portal](https://portal.azure.com) and sign in with the account you will use for the lab.
2. Search for **Subscriptions** in the search bar at the top of the portal and open it.
3. Select the subscription approved for the lab. Confirm its status is **Active**.

### Step 2: Create a Foundry project and resource

Use these Azure settings when creating your project:

| Field | What to enter |
| --- | --- |
| **Subscription** | Your current subscription |
| **Resource group** | Select the group provided by your facilitator, or allow the portal to create a dedicated group for this lab |
| **Location** | An organization-approved region that supports `gpt-4.1`; check [model availability by region](https://learn.microsoft.com/azure/foundry/foundry-models/concepts/models-sold-directly-by-azure-region-availability) |

1. Open [Microsoft Foundry](https://ai.azure.com) and sign in with the same account.
2. Make sure that the **New Foundry** toggle **On**.
3. Click on **Create new project** in the top right corner. If your first sign-in already shows the project creation form, continue with that form.
4. Enter `agent365-labs` as the project name.
5. Expand **Advanced options** and fill the values in the following way:
   1. **Region**: pick up one of the supported regions.
   2. **Subscription**: choose your azure subscription.
   3. Click on **Create new resource group** and create a new one called **rg-agentic-bootcamp**. Once you're back to the Foundry portal, select the resource group you have just created under **Resource group**.
6. Select **Create**, as shown in the form. Foundry creates the project and its parent Foundry resource.
7. Wait for creation to finish. You should be redirected directly to the `agent365-labs` project.

### Step 3: Deploy a chat model

1. In Foundry, confirm your lab project is selected.
2. Select **Discover** in the upper-right navigation, then **Models** in the left pane.
3. Search for **gpt-6.1-sol** and open its model card. This Azure OpenAI chat model supports the tool calls used by the sample agents. If it is unavailable, ask your facilitator for an approved chat model with tool-calling support.
4. Select **Deploy** > **Default settings**.
5. When deployment completes, Foundry opens the model playground.
6. Try any prompt in the chat panel to confirm that the model working.


### Step 4: Collect the connection settings

1. In Foundry, go back to the home page.
2. Record the resource's **Azure OpenAI base endpoint**, in the form `https://<resource-name>.openai.azure.com/`. If the example shows `https://<resource-name>.openai.azure.com/openai/v1/`, keep only `https://<resource-name>.openai.azure.com/` for these samples. They add the API path themselves. See [Foundry model endpoints](https://learn.microsoft.com/azure/foundry/foundry-models/concepts/endpoints#azure-openai-inference-endpoint).
3. In the [Azure portal](https://portal.azure.com), open the Foundry resource that owns this deployment. Record its resource name and resource group; you will use them for the access assignment in Step 5.
4. Open **Microsoft Entra ID** > **Overview** and copy **Tenant ID**. Confirm the directory is the one that owns the Azure subscription used above.
5. Keep the three connection settings in the table below for Exercise 1 of your chosen SDK lab.

| Setting | Example | Used in the samples |
| --- | --- | --- |
| Azure OpenAI endpoint | `https://<resource-name>.openai.azure.com/` | .NET: `AzureOpenAI:Endpoint`; Python/Node.js: `AZURE_OPENAI_ENDPOINT` |
| Deployment name | `gpt-6.1-sol` | .NET: `AzureOpenAI:Deployment`; Python/Node.js: `AZURE_OPENAI_DEPLOYMENT` |
| Tenant ID | The directory's GUID | .NET: `AzureOpenAI:TenantId`; Python/Node.js: `AZURE_OPENAI_TENANT_ID` |

The lab samples use the **Azure OpenAI base endpoint**, not the Foundry project endpoint ending in `/api/projects/<project-name>`. Use the **deployment name** in configuration, even if you chose a name different from the underlying model.

### Step 5: Grant your account access to call the model

The labs recommend signing in with Microsoft Entra credentials instead of storing an API key. The samples call the Azure OpenAI API, so your signed-in account needs **Cognitive Services OpenAI User**, or another role that includes that API's Entra inference access, on the **parent Foundry resource**. Project access and permission to create resources alone do not grant this resource-level model access.

1. In the Azure portal, open the Foundry resource you recorded in Step 4.
2. Select **Access control (IAM)** > **Add** > **Add role assignment**.
3. Search for and select **Cognitive Services OpenAI User**, then select **Next**.
4. Under **Assign access to**, select **User, group, or service principal**.
5. Select **Select members**, find the account you will use for the SDK lab (if you're using a MDX tenant, it should be **MOD Administrator**), select it, and confirm the selection.
6. Select **Review + assign** to finish the assignment.

Allow a few minutes for the role to take effect. See the [Cognitive Services OpenAI User role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user) if an administrator needs to check your existing access

## Next steps

Once the requirements above are ready, continue to [Lab A365-02A: .NET](./02a-web-obo-dotnet.md), the final step in the main flow.

The [Python](./02b-web-obo-python.md) and [JavaScript / Node.js](./02c-web-obo-nodejs.md) labs are optional extensions after the main flow.

<cc-next label="Continue to .NET - Lab A365-02A" url="../02a-web-obo-dotnet/"></cc-next>
