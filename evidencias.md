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

## Runs do GitHub Actions

Preencher depois do push. Para cada run: URL, run id, horário, job e trecho do log.

| Alvo | Branch | Job esperado | URL | Horário | Status |
|---|---|---|---|---|---|
| Baseline | main | gitleaks, semgrep, trivy | | | |
| Prova 1 | sabotage/gitleaks | gitleaks failed | | | |
| Prova 1, arquivo apagado | sabotage/gitleaks | gitleaks failed | | | |
| Prova 2 | sabotage/semgrep | semgrep failed | | | |
| Prova 3 | sabotage/trivy | trivy failed | | | |
