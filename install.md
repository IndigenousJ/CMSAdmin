# Wheels Framework Clean Installation Guide (App-Side / Root Structure)

This document contains the prompt and setup procedure to install the latest stable Wheels framework as a clean install with a flat, app-side structure (no `public/` folder, no Docker).

---

## 📋 The AI Prompt

Copy and paste the prompt below into an AI assistant when initializing a new Wheels framework directory:

```markdown
This is a clean slate with no relation to any outside folder. Do not reference anything outside this directory.

Please download and configure the latest stable Wheels framework directly in this folder with the following requirements:
1. Clean Install: Use the official Wheels base template and core framework (no starter-app plugins, demo databases, or sample data).
2. No Docker: Do not include Dockerfiles, docker-compose files, or devcontainers.
3. App-Side / Root Structure (No `public/` subfolder):
   - Place `Application.cfc` and `index.cfm` (the dispatch front controller) directly in the project root.
   - Adjust `Application.cfc` internal mappings (`/app`, `/vendor`, `/wheels`, `/config`, `/tests`, `/plugins`) and `.env` loading to point to `./` instead of `../`.
   - Place all web asset folders (`stylesheets/`, `javascripts/`, `images/`, `files/`, `miscellaneous/`) directly in the project root.
   - Remove the `public/` directory completely.
4. Domain & Localhost Configuration:
   - In `config/environment.cfm`, dynamically detect the environment: set "development" when accessed via localhost/127.0.0.1/::1, and "production" (or WHEELS_ENV) when accessed via a domain.
   - In `config/settings.cfm`, support dynamic base URL resolution from incoming requests with optional `WHEELS_BASE_URL` override from `.env`.
   - Initialize `.env` from `env.example`.
5. Web Server Configuration:
   - Provide an IIS `web.config` at the root with URL Rewrite rules for Wheels clean URLs (`index.cfm/{R:1}`), passing through physical static assets and ColdFusion engine paths (`CFIDE`, `cf_scripts`, etc.).
   - In `server.json`, set `"webroot": "."`, point rewrites to `urlrewrite.xml`, and bind host to `"0.0.0.0"`.
```

---

## 🛠️ Automated Setup Script (PowerShell)

If you prefer to run the setup manually or in a CI/CD pipeline, run this script in PowerShell from the target project directory:

```powershell
$ErrorActionPreference = "Stop"

Write-Host "1. Fetching latest stable Wheels release..."
$rel = Invoke-RestMethod -Uri "https://api.github.com/repos/wheels-dev/wheels/releases/latest" -Headers @{"User-Agent"="PowerShell"}
$version = $rel.tag_name.TrimStart("v")
Write-Host "Latest version: $version"

$baseTemplateUrl = ($rel.assets | Where-Object { $_.name -like "wheels-base-template-*.zip" }).browser_download_url
$coreUrl = ($rel.assets | Where-Object { $_.name -like "wheels-core-*.zip" }).browser_download_url

$tempBase = Join-Path ([System.IO.Path]::GetTempPath()) "wheels-base-template.zip"
$tempCore = Join-Path ([System.IO.Path]::GetTempPath()) "wheels-core.zip"

Write-Host "2. Downloading release assets..."
Invoke-WebRequest -Uri $baseTemplateUrl -OutFile $tempBase
Invoke-WebRequest -Uri $coreUrl -OutFile $tempCore

Write-Host "3. Extracting Base Template to current directory..."
Expand-Archive -Path $tempBase -DestinationPath "." -Force

Write-Host "4. Extracting Wheels Core into vendor/..."
$vendorDir = "vendor"
if (-not (Test-Path $vendorDir)) { New-Item -ItemType Directory -Path $vendorDir | Out-Null }
Expand-Archive -Path $tempCore -DestinationPath $vendorDir -Force

Write-Host "5. Flattening structure: Moving files from public/ to root..."
$assetDirs = @("files", "images", "javascripts", "miscellaneous", "stylesheets")
foreach ($dir in $assetDirs) {
    if (Test-Path "public\$dir") {
        if (-not (Test-Path $dir)) { Move-Item -Path "public\$dir" -Destination $dir -Force }
    }
}
if (Test-Path "public\urlrewrite.xml") {
    Move-Item -Path "public\urlrewrite.xml" -Destination "urlrewrite.xml" -Force
}

Write-Host "6. Configuring root Application.cfc..."
$appCfc = Get-Content -Raw "public\Application.cfc"
$appCfc = $appCfc -replace 'expandPath\("\.\./app/"\)', 'expandPath("./app/")'
$appCfc = $appCfc -replace 'expandPath\("\.\./vendor/"\)', 'expandPath("./vendor/")'
$appCfc = $appCfc -replace 'expandPath\("\.\./tests"\)', 'expandPath("./tests")'
$appCfc = $appCfc -replace 'expandPath\("\.\./config"\)', 'expandPath("./config")'
$appCfc = $appCfc -replace 'expandPath\("\.\./plugins"\)', 'expandPath("./plugins")'
$appCfc = $appCfc -replace 'this\.appDir & "\.\./plugins"', 'expandPath("./plugins")'
$appCfc = $appCfc -replace 'this\.appDir & "\.\./\.env"', 'expandPath("./.env")'
$appCfc = $appCfc -replace 'this\.appDir & "\.\./\.env\."', 'expandPath("./.env.")'
$appCfc = $appCfc -replace 'include "\.\./config/app\.cfm";', 'include "config/app.cfm";'
$appCfc = $appCfc -replace '"\.\./vendor/wheels/events/testcontext\.cfm"', '"vendor/wheels/events/testcontext.cfm"'
Set-Content -Path "Application.cfc" -Value $appCfc -Encoding UTF8 -NoNewline

Write-Host "7. Creating root index.cfm front controller..."
@'
<cfsilent>
<!---
	Uses the Dispatch object, which has been created on app start, to render content.
--->
</cfsilent><cfoutput>#application.wheels.dispatch.$request()#</cfoutput>
'@ | Set-Content -Path "index.cfm" -Encoding UTF8 -NoNewline

Write-Host "8. Creating root IIS web.config..."
@'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <defaultDocument>
            <files>
                <clear />
                <add value="index.cfm" />
            </files>
        </defaultDocument>
        <rewrite>
            <rules>
                <rule name="Wheels Clean URLs" stopProcessing="true">
                    <match url="^(.*)$" />
                    <conditions logicalGrouping="MatchAll">
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                        <add input="{URL}" pattern="^/(cf_scripts|flex2gateway|jrunscripts|CFIDE|lucee|cfformgateway|cffileservlet|files|images|javascripts|miscellaneous|stylesheets|robots\.txt|favicon\.ico|sitemap\.xml|index\.cfm)" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="index.cfm/{R:1}" />
                </rule>
            </rules>
        </rewrite>
        <httpErrors existingResponse="PassThrough" />
    </system.webServer>
</configuration>
'@ | Set-Content -Path "web.config" -Encoding UTF8 -NoNewline

Write-Host "9. Cleaning up public/ directory and docker configs..."
Remove-Item -Recurse -Force "public" -ErrorAction SilentlyContinue
if (Test-Path ".claude\.devcontainer") {
    Remove-Item -Recurse -Force ".claude\.devcontainer" -ErrorAction SilentlyContinue
}

Write-Host "10. Setting up .env and environment detection..."
if ((Test-Path "env.example") -and (-not (Test-Path ".env"))) {
    Copy-Item "env.example" ".env"
}

# Update server.json to bind 0.0.0.0 and root webroot
if (Test-Path "server.json") {
    $serverJson = Get-Content -Raw "server.json"
    $serverJson = $serverJson -replace '"webroot":\s*"public"', '"webroot": "."'
    $serverJson = $serverJson -replace '"config":\s*"public/urlrewrite\.xml"', '"config": "urlrewrite.xml"'
    $serverJson = $serverJson -replace '"host":\s*"localhost"', '"host": "0.0.0.0"'
    Set-Content -Path "server.json" -Value $serverJson -Encoding UTF8 -NoNewline
}

# Clean temp archives
Remove-Item -Force $tempBase, $tempCore -ErrorAction SilentlyContinue

Write-Host "Wheels clean app-side installation complete!"
```

---

## 📁 Resulting Directory Layout

```text
├── Application.cfc      # Primary application entry & mapping config
├── index.cfm            # Wheels front controller dispatch
├── web.config           # IIS clean URL rewriting
├── urlrewrite.xml       # Tuckey URL rewriting (CommandBox / LuCLI)
├── server.json          # Server bindings (0.0.0.0, root webroot)
├── .env                 # Environment variables
├── app/                 # Controllers, Models, Views, Migrator, etc.
├── config/              # Routes, Settings, and Environment detection
├── files/               # Public user file uploads
├── images/              # Public images
├── javascripts/         # Public JS files
├── miscellaneous/       # Standalone non-framework scripts
├── stylesheets/         # Public CSS files
├── tests/               # Wheels test runner & test specs
└── vendor/wheels/       # Wheels core framework engine
```

