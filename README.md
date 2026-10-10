# devsecops-cp05

Site estático e pipeline de segurança do CP05 (FIAP · DevSecOps and Cloud Computing).

O workflow [`.github/workflows/security.yml`](.github/workflows/security.yml) roda em todo `push` e `pull_request` com três jobs: `gitleaks`, `semgrep` e `trivy`.

```bash
docker build -t app:local .
docker run --rm -p 8080:80 app:local
```

A página fica em `http://localhost:8080`.
