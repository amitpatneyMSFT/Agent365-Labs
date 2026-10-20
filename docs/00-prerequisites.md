# SDK requirements

**Main flow: [1. Copilot Studio](./01-copilot-studio.md) → 2. SDK requirements → [3. .NET](./02a-web-obo-dotnet.md)**

Complete this setup after Copilot Studio and before the .NET lab. These requirements also apply to the optional [Python](./02b-web-obo-python.md) and [JavaScript / Node.js](./02c-web-obo-nodejs.md) labs; install their language-specific tools only if you plan to take them.

The first lab has its own [Copilot Studio prerequisites](./01-copilot-studio.md#prerequisites). You do not need the SDK tools to complete that lab.

Every SDK lab in this repository requires the same three things: tools on your machine, licences in your tenant, and permissions on your account.

## The tools you need on your machine

| Requirement | Minimum | Check it with | What needs it |
| --- | --- | --- | --- |
| .NET SDK | 10.0 for the .NET lab; 8.0 or later for CLI-only use | `dotnet --list-sdks` | The .NET sample targets `net10.0`; the Agent 365 CLI also needs .NET |
| Agent 365 CLI | latest | `a365 -h` | Every SDK lab |
| PowerShell | 7.0 | `pwsh --version` | The consent scripts |
| Azure CLI | latest | `az version` | Signing in to the tenant |
| Microsoft Graph authentication module | latest | `Get-Module -ListAvailable Microsoft.Graph.Authentication` | CLI prerequisite checks and Graph authentication |
| Microsoft Graph applications module | latest | `Get-Module -ListAvailable Microsoft.Graph.Applications` | CLI prerequisite checks and application permission scripts |
| Git | any | `git --version` | Cloning the sample agents |
| GitHub CLI (`gh`) | latest with `gh skill` support | `gh --version` | Installing skills for GitHub Copilot CLI or VS Code |
| Python | 3.12 | `python --version` | Optional Python lab only |
| uv | latest | `uv --version` | Optional Python lab only |
| Node.js | 20.10 | `node --version` | Optional JavaScript / Node.js lab only |

> Install the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) for the main .NET lab. Confirm `dotnet --list-sdks` includes a `10.0.x` SDK; the linked sample targets `net10.0`. If you are taking only the Python or Node.js lab, .NET 8.0 or later is sufficient for the Agent 365 CLI. Lab A365-01 does not use the CLI.

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

### Install the Microsoft Graph PowerShell modules

1. Open **PowerShell 7** (`pwsh`).
2. Run the two `Get-Module` checks in the tools table. Each must return a module with the requested name.
3. For each missing module, run its installation command:

   ```powershell
   Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser
   Install-Module -Name Microsoft.Graph.Applications -Scope CurrentUser
   ```

4. Repeat the checks and confirm both modules are available in PowerShell 7.

Use your organization's configured PowerShell repositories. If a module is unavailable, ask your administrator to provide it through an approved source. Both modules must be available in PowerShell 7 for the Agent 365 CLI's prerequisite check.

## Installing the Agent 365 Skills

Most of the Agent 365 work in the **SDK labs** is done by asking an AI coding assistant to do it, using the [Agent 365 Skills](https://github.com/microsoft/agent365-skills). The skills work with every major assistant, and each one installs them differently. Pick the row that matches the tool you use:

| Your assistant | How to install |
| --- | --- |
| Claude Code (app, web or CLI) | Run `/plugin marketplace add https://github.com/microsoft/agent365-skills` inside a session, then `/plugin install agent365@agent365-skills` |
| GitHub Copilot CLI, VS Code agent mode | `gh skill add microsoft/agent365-skills --all` |
| Cursor, Windsurf, Codex CLI, Gemini CLI, or anything else that reads `.agents/skills/` | `node /path/to/agent365-skills/scripts/install.js`, run from your agent project directory |

Run the install from **your agent's project folder**, so the skills can see the code they are meant to change. The GitHub CLI command uses `--all` to install every discovered skill without a selection prompt. Restart your coding assistant after installation so it loads the skills.

If `gh` is unavailable, install the [GitHub CLI](https://cli.github.com/) through your organization's approved software channel. Run `gh skill add --help` and confirm it lists `--all`; if the `skill` command is unavailable, update the CLI through the same channel.

> Lab A365-01 does not use these coding-assistant skills. It uses a native skill created inside the Copilot Studio browser authoring experience.

## The licences your tenant needs for the SDK labs

| Requirement | What to know |
| --- | --- |
| Microsoft 365 tenant | With Agent 365 enabled |
| Observability licence | **At least one user in the tenant must have Microsoft 365 E7 or Microsoft Agent 365 assigned** |
| Microsoft 365 Copilot | Required for Work IQ in Exercise 5 of the .NET and Node.js labs. Confirm the user who will sign in and call Mail and Calendar has this entitlement. The Python lab does not implement Work IQ |
| Azure subscription | For the Azure OpenAI resource the agent reasons with |

> If no user has Microsoft 365 E7 or Microsoft Agent 365 assigned, telemetry is accepted with `HTTP 200` and then discarded. The logs report a successful export, Defender shows no data, and no error is raised. Verify an actual user assignment before you start; having the subscription available in the tenant is not enough.

Identity registration requires Agent 365 to be enabled but does not require an additional licence. Observability and Work IQ have separate licence requirements; a Microsoft 365 Copilot licence alone does not meet the observability requirement. See the [capability-specific prerequisites](https://learn.microsoft.com/microsoft-agent-365/developer/get-started#prerequisites).

## The permissions you need on your account for the SDK labs

| Permission | Who needs it | What it is for |
| --- | --- | --- |
| Agent ID Developer, or a role that includes blueprint creation | You | Creating the agent identity blueprint in Exercise 3 |
| Application Developer, or equivalent app-registration permissions | You | Creating the ordinary web sign-in app registration in Exercise 2 |
| Global Administrator | You *or* a colleague | Granting admin consent to the blueprint |
| Azure OpenAI access | You | The model the agent uses. For the Entra credential path you need the **Cognitive Services OpenAI User** role on the resource; for key auth, access to the resource keys |

> You do not need to be a Global Administrator yourself. The CLI performs every action it is permitted to perform, then prints a PowerShell snippet for an administrator to run for the rest. Identify the person who will run it before you start.

Ask your Microsoft Entra administrator to confirm you have both blueprint-creation and ordinary app-registration permissions before starting. **Application Developer** does not grant the blueprint-creation permission. See the [Agent 365 setup prerequisites](https://learn.microsoft.com/microsoft-agent-365/developer/get-started#prerequisites).

The web on-behalf-of labs contain two of these handoffs: one when the agent is registered, and one when the sign-in app is given permission to call the agent's blueprint. Each takes an administrator about a minute.

## Getting the sample agent

The SDK labs start from a research assistant that answers questions about Microsoft products by searching the Microsoft Learn MCP server. Clone the runbook repository and open the .NET sample for the main flow:

```bash
git clone https://github.com/qmatteoq/agent365-runbook
cd agent365-runbook/01-scenarios/Web-App-Agent-User-OBO/0.Resources/Starting-point/dotnet
```

The sample folders under `Starting-point/` are:

| Lab | Folder |
| --- | --- |
| A365-02A (.NET, main flow) | `dotnet/` |
| A365-02B (Python, optional) | `python/` |
| A365-02C (JavaScript / Node.js, optional) | `nodejs/` |

You can bring your own agent instead. The SDK labs assume two things about it: it runs as a web app with one HTTP request per turn, and there is a single place in the code where a turn begins and ends, which is where the instrumentation goes.

## An Azure OpenAI resource for the SDK labs

The SDK agents call an **Azure OpenAI model deployed in Microsoft Foundry**. You will create a **Foundry project**, which is your workspace in the portal, and a **Foundry resource**, which holds the model deployments, endpoint, and access settings. A model deployment makes a particular model available for your agent to call.

These instructions use the **new Microsoft Foundry portal**. You will create a project, deploy a chat model, test it, and collect the connection settings for the labs. If your facilitator provides a project and deployment, start at Step 4.

> **Costs:** model calls, including playground tests, incur Azure charges. A Microsoft 365 or Agent 365 licence does not include Azure OpenAI usage. Use a subscription approved for the lab and review [Azure OpenAI pricing](https://azure.microsoft.com/pricing/details/cognitive-services/openai-service/) before deploying.

### Step 1: Sign in and check your Azure subscription

1. Open the [Azure portal](https://portal.azure.com) and sign in with the account you will use for the lab.
2. Search for **Subscriptions** in the search bar at the top of the portal and open it.
3. Select the subscription approved for the lab. Confirm its status is **Active**. If no subscription is listed, ask your Azure administrator or facilitator for access before continuing.
4. Record the subscription name and **Subscription ID**.
5. Ask your administrator to confirm you have permission to create a Foundry resource and project in the target **resource group**, which is a container for related Azure resources. **Foundry Owner** or **Foundry Account Owner** on the resource group provides resource-creation permissions. Creating a new resource group also requires permission at subscription level. See [Foundry project prerequisites](https://learn.microsoft.com/azure/foundry/how-to/create-projects#prerequisites).

Your administrator can create the project and deployment for you if you do not have these permissions. Azure resource permissions are separate from the Microsoft Entra roles used to register agents later in the lab.

### Step 2: Create a Foundry project and resource

Use these Azure settings when creating your project:

| Field | What to enter |
| --- | --- |
| **Subscription** | The subscription you checked in Step 1 |
| **Resource group** | Select the group provided by your facilitator, or allow the portal to create a dedicated group for this lab |
| **Location** | An organization-approved region that supports `gpt-4.1`; check [model availability by region](https://learn.microsoft.com/azure/foundry/foundry-models/concepts/models-sold-directly-by-azure-region-availability) |

1. Open [Microsoft Foundry](https://ai.azure.com) and sign in with the same account.
2. Turn the **New Foundry** toggle **On**.
3. Open the project selector in the upper-left corner and select **Create new project**. If your first sign-in already shows the project creation form, continue with that form.
4. Enter `agent365-labs-ab` as the project name, replacing `ab` with your initials.
5. Expand **Advanced options** and enter the Azure settings from the table above.
6. Turn **Set up recommended resources** **Off**. This option is enabled by default and provisions additional resources, including Application Insights, that can incur separate charges. This lab sends telemetry to Agent 365 and does not require Application Insights. If your organization requires those resources, ask your administrator to approve the configuration and costs.
7. Select **Create** or **Create project**, as shown in the form. Foundry creates the project and its parent Foundry resource.
8. Wait for creation to finish. Confirm `agent365-labs-ab` appears in the project selector.

If your organization requires private networking, specific resource names, or mandatory tags, ask your administrator to prepare a compliant project using the [Foundry project setup guide](https://learn.microsoft.com/azure/foundry/how-to/create-projects). Confirm your lab machine can reach its model endpoint before continuing.

**Checkpoint:** your project opens in the new Foundry portal. You have a workspace and resource; deploy the model next.

### Step 3: Deploy a chat model

1. In Foundry, confirm your lab project is selected.
2. Select **Catalog** > **Models**.
3. Search for **gpt-4.1** and open its model card. This Azure OpenAI chat model supports the tool calls used by the sample agents. If it is unavailable, ask your facilitator for an approved chat model with tool-calling support.
4. Select **Deploy** > **Custom settings**.
5. Confirm the deployment targets your lab project's Foundry resource.
6. Enter `gpt-4.1` as the **Deployment name**. This is the name you will put in the sample's configuration.
7. Select **Global Standard** as the **Deployment type** if your organization permits global processing. If it requires regional processing, ask your administrator which available deployment type to use. Use a pay-per-token deployment for this lab; batch deployments cannot serve the interactive chat.
8. Set **Tokens per Minute Rate Limit** to **10,000** for a single learner, if that quota is available. For a shared deployment, use the capacity provided by your facilitator.
9. Select **Deploy**. When deployment completes, Foundry opens the model playground.
10. Select **Build** in the upper-right navigation, then **Models** in the left pane. Confirm the deployment is listed with status **Succeeded**.

If deployment is blocked by insufficient quota, ask your administrator to allocate quota or provide a deployment in an approved region. Creating or editing a model deployment requires **Cognitive Services Contributor** or equivalent permissions on the Foundry resource. See [Deploy models in the Foundry portal](https://learn.microsoft.com/azure/foundry/foundry-models/how-to/deploy-foundry-models).

### Step 4: Collect the connection settings

1. In Foundry, select the project provided by your facilitator or the one you created.
2. Select **Build** > **Models**, then open your `gpt-4.1` deployment.
3. Copy the **Deployment name** exactly. Open the **Code** tab and locate the Azure OpenAI endpoint in the connection example.
4. Record the resource's **Azure OpenAI base endpoint**, in the form `https://<resource-name>.openai.azure.com/`. If the example shows `https://<resource-name>.openai.azure.com/openai/v1/`, keep only `https://<resource-name>.openai.azure.com/` for these samples. They add the API path themselves. See [Foundry model endpoints](https://learn.microsoft.com/azure/foundry/foundry-models/concepts/endpoints#azure-openai-inference-endpoint).
5. In the [Azure portal](https://portal.azure.com), open the Foundry resource that owns this deployment. Record its resource name and resource group; you will use them for the access assignment in Step 5.
6. Open **Microsoft Entra ID** > **Overview** and copy **Tenant ID**. Confirm the directory is the one that owns the Azure subscription used above.
7. Keep the three connection settings in the table below for Exercise 1 of your chosen SDK lab.

| Setting | Example | Used in the samples |
| --- | --- | --- |
| Azure OpenAI endpoint | `https://<resource-name>.openai.azure.com/` | .NET: `AzureOpenAI:Endpoint`; Python/Node.js: `AZURE_OPENAI_ENDPOINT` |
| Deployment name | `gpt-4.1` | .NET: `AzureOpenAI:Deployment`; Python/Node.js: `AZURE_OPENAI_DEPLOYMENT` |
| Tenant ID | The directory's GUID | .NET: `AzureOpenAI:TenantId`; Python/Node.js: `AZURE_OPENAI_TENANT_ID` |

The lab samples use the **Azure OpenAI base endpoint**, not the Foundry project endpoint ending in `/api/projects/<project-name>`. Use the **deployment name** in configuration, even if you chose a name different from the underlying model.

### Step 5: Grant your account access to call the model

The labs recommend signing in with Microsoft Entra credentials instead of storing an API key. The samples call the Azure OpenAI API, so your signed-in account needs **Cognitive Services OpenAI User**, or another role that includes that API's Entra inference access, on the **parent Foundry resource**. Project access and permission to create resources alone do not grant this resource-level model access.

Ask an administrator who can assign Azure roles, such as an **Owner**, **User Access Administrator**, or **Role Based Access Control Administrator** at the resource scope, to complete these steps:

1. In the Azure portal, open the Foundry resource you recorded in Step 4.
2. Select **Access control (IAM)** > **Add** > **Add role assignment**.
3. Search for and select **Cognitive Services OpenAI User**, then select **Next**.
4. Under **Assign access to**, select **User, group, or service principal**.
5. Select **Select members**, find the account you will use for the SDK lab, select it, and confirm the selection.
6. Select **Review + assign** to finish the assignment.

Allow a few minutes for the role to take effect. See the [Cognitive Services OpenAI User role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user) if an administrator needs to check your existing access.

If your facilitator requires API-key authentication, use the resource key available in the deployment's connection details. The SDK lab explains how to configure it outside committed files. Keep keys out of source control, screenshots, and lab notes shared with others.

### Step 6: Test the deployment

1. In Foundry, select your lab project.
2. Select **Build** > **Models**, then select your deployment to open its playground.
3. Confirm the selected deployment is the one you recorded, then send: `Reply with one sentence explaining what Azure OpenAI is.`
4. Confirm a text response appears. If access is denied, check your role assignment and the resource's network settings with your administrator. If a rate-limit or quota error appears, wait and retry, then ask your facilitator to review capacity if it persists.

The playground test checks that the deployment responds. Exercise 1 of the SDK lab will check the connection from your local application using the endpoint, deployment name, and tenant ID you collected.

**Checkpoint:** the model deployment has succeeded, it answers in the chat playground, you have recorded all three connection settings, and your lab account has model access.

## Next steps

Once the requirements above are ready, continue to [Lab A365-02A: .NET](./02a-web-obo-dotnet.md), the final step in the main flow.

The [Python](./02b-web-obo-python.md) and [JavaScript / Node.js](./02c-web-obo-nodejs.md) labs are optional extensions after the main flow.

<cc-next label="Continue to .NET - Lab A365-02A" url="../02a-web-obo-dotnet/"></cc-next>
