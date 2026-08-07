# wsl-setup

Configuração replicável para desenvolvimento Full Stack/Full Cycle e Arquitetura centralizado no **WSL**, com **Windows Bridge** para reaproveitar as ferramentas instaladas no Linux em terminais do Windows, sem duplicar SDKs no sistema hospedeiro.

Este repositório é a própria raiz de configuração; clone-o e use os scripts na pasta que preferir. Os exemplos abaixo usam placeholders `<drive>` e `<repo-path>` para caminhos da máquina local.

## Leitura Rápida

Se o objetivo for reinstalar a máquina com o menor número de passos, use primeiro:

- [REINSTALL-RUNBOOK.md](REINSTALL-RUNBOOK.md)

## Estrutura

```text
wsl-setup/
├── wsl-setup/              # Script de bootstrap do WSL
├── windows-bridge/         # Bridge para reaproveitar ferramentas do WSL no Windows
├── REINSTALL-RUNBOOK.md    # Runbook executivo de reinstalação
├── .tool-versions          # Fonte da verdade das versões via ASDF
├── trae-wsl.settings.json  # Template de settings para terminal WSL no Trae
├── bootstrap-machine.cmd   # Atalho de duplo clique para o bootstrap do host Windows
├── bootstrap-machine.ps1   # Instalador principal do host Windows
└── README.md              # Este arquivo
```

## Instalação Rápida

### Fluxo Recomendado em Nova Máquina Windows

O fluxo mais simples e direto para reinstalar esta máquina é:

1. Abra um PowerShell **como Administrador**.
2. Vá para a raiz do repositório clonado.
3. Execute:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-machine.ps1
```

Atalho equivalente para `cmd`:

```bat
.\bootstrap-machine.cmd
```

Esse instalador central:

- instala o `WSL2` e a distro `Ubuntu` se ainda não existirem;
- valida se a distro já está pronta para automação;
- provisiona o workspace dentro do WSL;
- aplica o `windows-bridge` global para PowerShell, `cmd` e Git Bash.

Se o `WSL2` ou a distro `Ubuntu` ainda não existirem, o script:

- executa `wsl --install -d Ubuntu`;
- pode exigir reinicialização do Windows;
- pede para você abrir o Ubuntu uma vez para criar o usuário Linux;
- depois basta rodar o mesmo comando novamente.

### Fluxo Manual

Se preferir executar por etapas:

1. Instale o `WSL2` e a distro `Ubuntu`:

```powershell
wsl --install -d Ubuntu
```

2. Abra o Ubuntu e conclua a criação do usuário Linux.

3. Entre no WSL e execute o bootstrap do workspace:

```bash
cd "/mnt/<drive>/<repo-path>/wsl-setup"
chmod +x bootstrap-workspace.sh
./bootstrap-workspace.sh
```

4. No Windows, aplique o bridge global:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows-bridge\install-global.ps1
```

## Ferramentas Instaladas

O script instala:

- Dependências base do sistema para compilar e executar SDKs
- ASDF Version Manager
- Plugins ASDF para `python`, `nodejs`, `java` e `dotnet`
- Ferramentas declaradas em `.tool-versions`
- `RTK` via instalador oficial do projeto `rtk-ai/rtk`
- `GitHub CLI` via release oficial do projeto `cli/cli`
- Utilitários de apoio: `jq`, `ripgrep`, `fd-find`, `shellcheck`, `shfmt`, `pipx`
- `LocalStack CLI` via `pipx`

Versões atualmente declaradas no workspace:

- `python 3.14.6t`
- `nodejs 26.4.0`
- `java temurin-25.0.3+9.0.LTS`
- `dotnet 10.0.301 8.0.302`

## Configuração do Trae Para WSL

O ambiente deste agente não permite gravar automaticamente em `.vscode/settings.json`, então a configuração pronta foi deixada em:

- `trae-wsl.settings.json`

Para aplicar no Trae, copie o conteúdo desse arquivo para `.vscode/settings.json` do workspace.

Antes de salvar, substitua os placeholders:

- `<distro>` pelo nome da sua distro WSL
- `<drive>` pela letra do drive onde o repositório foi clonado
- `<repo-path>` pelo caminho do repositório dentro desse drive

Essa configuração faz o terminal integrado e o perfil de automação abrirem em:

- `WSL (Ubuntu)`
- Diretório `/mnt/<drive>/<repo-path>`

## Bridge Windows -> WSL

Para reutilizar no Windows as ferramentas instaladas apenas no WSL, sem instalar `python`, `node`, `dotnet`, `docker`, `gh` ou `rtk` no Windows, use os arquivos em:

- `windows-bridge/`

Arquivos principais:

- `wrun.ps1`: executor genérico para PowerShell
- `wrun.cmd`: executor genérico para `cmd`
- `wrun.sh`: executor genérico para Git Bash
- `activate-wsl-tools.ps1`: carrega funções no PowerShell
- `activate-wsl-tools.cmd`: carrega macros no `cmd`
- `activate-wsl-tools.sh`: carrega funções no Git Bash
- `install-global.ps1`: instala wrappers globais e bootstrap automático

O bridge sempre:

- usa `wsl.exe -d Ubuntu`
- converte o diretório atual do Windows para o diretório correspondente no WSL
- carrega `asdf`, `shims` e `~/.local/bin`
- reaproveita o `DOTNET_ROOT` configurado pelo plugin do `asdf`

### Instalação Global

Para abrir um terminal novo no Windows e já usar `python`, `node`, `dotnet`, `docker`, `gh` e `rtk` apontando para o WSL, execute uma vez:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows-bridge\install-global.ps1
```

Esse instalador:

- cria wrappers em `%USERPROFILE%\.local\bin`
- adiciona esse diretório ao `PATH` do usuário
- configura o Git Bash para carregar o bridge automaticamente em novos shells

Depois disso, abra um novo terminal para carregar o ambiente atualizado.

### Ferramentas Expostas no Windows

Depois da instalação global, estes comandos passam a funcionar em terminais novos do Windows usando o WSL como backend:

- `python`
- `pip`
- `pytest`
- `node`
- `npm`
- `npx`
- `java`
- `javac`
- `dotnet`
- `docker`
- `docker-compose`
- `gh`
- `rtk`

### Uso Rápido

PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
. .\windows-bridge\activate-wsl-tools.ps1
python --version
dotnet --version
docker ps
gh --version
rtk gain
```

CMD:

```bat
call .\windows-bridge\activate-wsl-tools.cmd
python --version
dotnet --version
docker ps
gh --version
rtk gain
```

Git Bash:

```bash
source ./windows-bridge/activate-wsl-tools.sh
python --version
dotnet --version
docker ps
gh --version
rtk gain
```

### Uso Genérico Sem Atalhos

Se preferir não injetar aliases/funções no shell, use `wrun` diretamente:

PowerShell:

```powershell
.\windows-bridge\wrun.cmd python --version
.\windows-bridge\wrun.cmd dotnet --version
.\windows-bridge\wrun.cmd gh --version
```

CMD:

```bat
.\windows-bridge\wrun.cmd python --version
.\windows-bridge\wrun.cmd docker ps
.\windows-bridge\wrun.cmd gh --version
```

Git Bash:

```bash
./windows-bridge/wrun.sh python --version
./windows-bridge/wrun.sh gh --version
./windows-bridge/wrun.sh rtk gain
```

## RTK no WSL

O bootstrap instala o `RTK` usando o instalador oficial do projeto:

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
```

Se quiser reproduzir exatamente a mesma versão em outra máquina, rode o setup com `RTK_VERSION` definido:

```bash
RTK_VERSION=v0.43.0 ./setup.sh
```

O binário é instalado em:

- `~/.local/bin/rtk`

## GitHub CLI no WSL

O bootstrap instala o `gh` a partir do release oficial do projeto `cli/cli`, copiando o binário para:

- `~/.local/bin/gh`

Validação rápida:

```bash
gh --version
gh auth status
```

## Scripts Principais

Os scripts principais para replicação são:

- `bootstrap-machine.ps1`
  - instalador principal do host Windows;
  - instala/configura `WSL2`, valida a distro e aplica o `windows-bridge`.
- `wsl-setup/bootstrap-workspace.sh`
  - instalador principal dentro do WSL;
  - executa `setup.sh` e os scripts de validação.
- `windows-bridge/install-global.ps1`
  - instala os wrappers globais do Windows.

Validações aplicadas pelo script:

- `rtk --version`
- `rtk gain`
- `gh --version`

Essas validações existem para garantir que o binário instalado é o `RTK Token Killer` correto, e não outro projeto com o mesmo nome.

Se quiser habilitar o hook global do RTK para sua ferramenta de IA depois da instalação, execute manualmente:

```bash
rtk init -g
```

Esse passo fica manual porque altera configuração global da ferramenta e pode variar conforme o agente em uso.

## Replicação em Outra Máquina

Fluxo recomendado para reproduzir este workspace em outra máquina:

1. Clone ou copie este workspace para o novo computador.
2. Abra um PowerShell **como Administrador**.
3. Execute:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-machine.ps1
```

4. Se o script instalar o `WSL2` pela primeira vez:

- reinicie o Windows se solicitado;
- abra o Ubuntu uma vez;
- conclua a criação do usuário Linux;
- reexecute o mesmo comando acima.

5. Valide o ambiente no WSL:

```bash
python --version
node --version
java --version
dotnet --version
gh --version
rtk --version
rtk gain
```

6. Valide no Windows em um terminal novo:

```powershell
python --version
node --version
dotnet --version
gh --version
rtk gain
```

7. Copie o template `trae-wsl.settings.json` para `.vscode/settings.json` do workspace que usará este projeto.

8. Reabra o Trae e confirme que o terminal abre em `WSL (Ubuntu)`.

9. Se quiser executar só a validação estrutural do instalador do host sem provisionar tudo, use:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-machine.ps1 -ValidateOnly
```

Para validar a alternância de `.NET 8` e `.NET 10`, execute:

```bash
cd "/mnt/<drive>/<repo-path>/wsl-setup"
chmod +x verify-dotnet.sh
./verify-dotnet.sh
```

Para validar o `RTK` correto no WSL, execute:

```bash
cd "/mnt/<drive>/<repo-path>/wsl-setup"
chmod +x verify-rtk.sh
./verify-rtk.sh
```

Para validar o `GitHub CLI` no WSL, execute:

```bash
cd "/mnt/<drive>/<repo-path>/wsl-setup"
chmod +x verify-gh.sh
./verify-gh.sh
```

## Observações

- O script usa `.tool-versions` como fonte da verdade; não há mais versões hardcoded no `setup.sh`.
- O pacote agora cobre host Windows + `WSL2` + distro `Ubuntu` + provisionamento WSL + `windows-bridge`.
- Para `.NET`, o default do workspace e `10.0.301`, com `8.0.302` instalada adicionalmente.
- Para `RTK`, o instalador oficial do projeto `rtk-ai/rtk` e a validação por `rtk gain` evitam colisão com outro pacote chamado `rtk`.
- Para `gh`, a instalação usa o release oficial do projeto `cli/cli`, sem depender do pacote da distro.
- Se você alterar versões no manifesto, basta reexecutar `./setup.sh`.
- O bootstrap pode demorar bastante na primeira execução por compilar/baixar múltiplos SDKs.
