# Evidências do CP05

Arquivo de consulta para os prints e para reescrever os parágrafos. A chave falsa não está aqui.

## Repositório local

- Pasta: `/Users/jyudi/devsecops-cp05`
- `main` e `fix/trivy-base-image`: `0505fb2` — imagem remediada, 0 HIGH/CRITICAL no Trivy local
- Push, PRs e URLs da aba Actions: pendentes até `gh auth login`

## Desvio do Semgrep em relação ao slide

O job continua se chamando `semgrep`. A invocação mudou, pelos testes locais:

- A imagem `semgrep/semgrep` não tem Node.js, então `actions/checkout` não roda dentro do `container:` da aula.
- `semgrep ci` é o cliente do Semgrep App e depende de um repositório git (e, na prática, de token).
- `p/javascript` não apontou o `eval` (0 findings).
- `p/default` apontou o `eval` e também marcou as tags mutáveis do próprio workflow (`@v4`, `@v2`, `@v0.36.0`), que o enunciado pede. O scan usa `--exclude .github` e `--error`, no runner, via `docker run`.

Comando que falha no `eval` e passa na `main` limpa:

```bash
semgrep scan --config p/default --error --metrics=off --exclude .github /src
```

Finding: `javascript.browser.security.eval-detected.eval-detected`, arquivo `vulnerable.js`, linha 3, blocking. Exit code 1.

## Gitleaks (local)

- Chave falsa no alfabeto `A-Z` e `2-7`, validada com `gitleaks detect --no-git` antes de entrar no Git. RuleID: `aws-access-token`. Arquivo: `config.js`, linha 1.
- Branch `sabotage/gitleaks`:
  - `0bf877e` `feat: adiciona config` (o segredo entra no histórico)
  - `7be0924` remove `config.js`
- Scan só dessa branch: 1 leak, mesmo depois da remoção do arquivo.
- Scan só da `main`: 3 commits, nenhum leak.

## Trivy (local)

Baseline, `nginx:1.30.4-alpine`, severidade HIGH,CRITICAL: **10 HIGH, 0 CRITICAL**. Saída em `trivy-baseline.txt` (gitignored).

| Pacote | CVE | Instalada | Corrigida |
|---|---|---|---|
| libexpat | CVE-2026-93990 | 2.8.4-r0 | 2.8.5-r0 |
| libuuid | CVE-2026-53612 | 2.42.1-r0 | 2.42.3-r0 |
| libuuid | CVE-2026-53613 | 2.42.1-r0 | 2.42.3-r0 |
| libuuid | CVE-2026-53614 | 2.42.1-r0 | 2.42.3-r0 |
| libuuid | CVE-2026-76642 | 2.42.1-r0 | 2.42.3-r0 |
| libuuid | CVE-2026-78408 | 2.42.1-r0 | 2.42.3-r1 |
| libuuid | CVE-2026-78409 | 2.42.1-r0 | 2.42.3-r0 |
| libuuid | CVE-2026-78410 | 2.42.1-r0 | 2.42.3-r0 |
| pcre2 | CVE-2026-103111 | 10.48-r0 | 10.49-r0 |
| tiff | CVE-2026-4775 | 4.7.1-r0 | 4.7.2-r0 |

`nginx:1.31-alpine` (nginx 1.31.6, Alpine 3.24.2) ainda tinha 3 HIGH: CVE-2026-93990, CVE-2026-103111, CVE-2026-4775.

Depois, `nginx:1.31.6-alpine` com `apk upgrade`: **0 HIGH, 0 CRITICAL**. Saída em `trivy-after.txt`. Commit `0505fb2`.

`exit-code: 1` no workflow faz o job falhar quando o scan encontra HIGH ou CRITICAL.

Sabotagem local, `nginx:1.14` (Debian 9.8): **113 achados, 82 HIGH e 31 CRITICAL**. Saída em `/tmp/trivy-nginx114.txt`. A branch `sabotage/trivy` é o commit `b367cc6`.

## Repositório

https://github.com/JoaoLucasYudi/devsecops-cp05

PRs abertas, nenhuma mergeada:

- https://github.com/JoaoLucasYudi/devsecops-cp05/pull/1 `sabotage/semgrep`
- https://github.com/JoaoLucasYudi/devsecops-cp05/pull/2 `sabotage/trivy`
- https://github.com/JoaoLucasYudi/devsecops-cp05/pull/3 `sabotage/gitleaks`

## Runs do GitHub Actions

Horários em Brasília (UTC-3), 10/10/2026.

| Alvo | Evento | URL | Horário | Jobs |
|---|---|---|---|---|
| main, primeiro push | push | https://github.com/JoaoLucasYudi/devsecops-cp05/actions/runs/38092478215 | 19:43 | semgrep ok, trivy ok, gitleaks erro de faixa git (sem leak) |
| main verde | push | https://github.com/JoaoLucasYudi/devsecops-cp05/actions/runs/38092856758 | 19:49 | gitleaks, semgrep e trivy ok |
| Árvore limpa (`fix/trivy-base-image`, commit `0505fb2`) | push | https://github.com/JoaoLucasYudi/devsecops-cp05/actions/runs/38092515348 | 19:43 | gitleaks, semgrep e trivy ok |
| Prova Semgrep | pull_request #1 | https://github.com/JoaoLucasYudi/devsecops-cp05/actions/runs/38092620833 | 19:45 | só semgrep falhou |
| Prova Trivy | pull_request #2 | https://github.com/JoaoLucasYudi/devsecops-cp05/actions/runs/38092623192 | 19:45 | só trivy falhou. Total: 113 (HIGH: 82, CRITICAL: 31) |
| Prova Gitleaks | pull_request #3 | https://github.com/JoaoLucasYudi/devsecops-cp05/actions/runs/38092632500 | 19:45 | só gitleaks falhou |
| Prova Gitleaks, push do commit que apaga o arquivo | push | https://github.com/JoaoLucasYudi/devsecops-cp05/actions/runs/38092619164 | 19:45 | gitleaks falhou. RuleID `aws-access-token`, arquivo `config.js`, commit `0bf877e`. O HEAD já era `7be0924`, que remove o arquivo |

O primeiro push da `main` fez o `gitleaks-action` calcular o intervalo `5cec2a0^..HEAD`. `5cec2a0` é o commit raiz e não tem pai, então o git falhou com exit code 1. O log diz `no leaks found in partial scan`. Não é um segredo na `main`. O push seguinte, de um commit que já tem pai, varre só esse commit.

Trecho do Semgrep na PR 1: `javascript.browser.security.eval-detected.eval-detected`, `/src/vulnerable.js`, linha 3, blocking, exit code 1.

Trecho do Trivy na PR 2: imagem `nginx:1.14`, `Total: 113 (HIGH: 82, CRITICAL: 31)`, job encerrado pelo `exit-code: 1`.
