# Runbook de Reinstalação

Guia curto para reinstalar este ambiente em outra máquina Windows.

## Objetivo

Provisionar, com o mínimo de passos:

- `WSL2`
- distro `Ubuntu`
- toolchain de desenvolvimento dentro do WSL
- `windows-bridge` para usar as ferramentas do WSL em PowerShell, `cmd` e Git Bash

## 5 Passos

1. Clone este repositório na nova máquina.

2. Abra um PowerShell **como Administrador** na raiz do repositório clonado.

3. Execute:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-machine.ps1
```

Atalho equivalente para `cmd`:

```bat
.\bootstrap-machine.cmd
```

4. Se for a primeira instalação de `WSL2`:

- reinicie o Windows se solicitado;
- abra o `Ubuntu` uma vez;
- conclua a criação do usuário Linux;
- execute o mesmo comando novamente.

5. Feche e reabra PowerShell, `cmd` e Git Bash. Depois valide:

```powershell
python --version
node --version
dotnet --version
gh --version
rtk gain
```

## O Que o Instalador Faz

O script [bootstrap-machine.ps1](bootstrap-machine.ps1):

- instala `WSL2` e `Ubuntu` quando necessário;
- valida se a distro está pronta para automação;
- executa o bootstrap do workspace no WSL;
- instala o `windows-bridge` global no Windows.

O bootstrap do WSL é feito por [bootstrap-workspace.sh](wsl-setup/bootstrap-workspace.sh), que executa:

- [setup.sh](wsl-setup/setup.sh)
- [verify-dotnet.sh](wsl-setup/verify-dotnet.sh)
- [verify-rtk.sh](wsl-setup/verify-rtk.sh)
- [verify-gh.sh](wsl-setup/verify-gh.sh)

## Comandos Úteis

Validação estrutural sem provisionar tudo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-machine.ps1 -ValidateOnly
```

Aplicar só o bridge do Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows-bridge\install-global.ps1
```

Validar `gh` no WSL:

```bash
cd "/mnt/<drive>/<repo-path>/wsl-setup"
./verify-gh.sh
```

## Resultado Esperado

Em terminais novos do Windows, os seguintes comandos passam a usar o WSL como backend:

- `python`
- `node`
- `dotnet`
- `docker`
- `gh`
- `rtk`

## Fonte de Verdade

Para detalhes técnicos, troubleshooting e fluxo manual completo, use:

- [WORKSPACE-README.md](WORKSPACE-README.md)
