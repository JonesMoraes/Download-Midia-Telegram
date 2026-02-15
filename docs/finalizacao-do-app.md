# Como finalizar o app Vidal Transportes

Este guia transforma a arquitetura atual em um plano de execução até produção.

## 1) Definir escopo de release (MVP fechado)

Objetivo: congelar funcionalidades obrigatórias para primeira versão pública.

### Funcionalidades mínimas

- Autenticação (telefone + Google, com account linking opcional).
- Cadastro e edição de perfil de motorista/usuário.
- Criação e gestão de rotas/paradas.
- Upload de POD (foto/arquivo) em Cloud Storage.
- Rastreamento por link público (`tracking`).
- Observabilidade básica (Crashlytics + logs estruturados backend).

### Critérios de pronto (DoD do MVP)

- Sem crash bloqueante (P0) em testes de fluxo principal.
- Latência aceitável em Minas Gerais para ações críticas.
- Regras de segurança Firebase validadas com testes automatizados.
- Pipeline CI/CD com promoção `dev -> staging -> prod`.

---

## 2) Estruturar o repositório de código

Hoje este repo está documental. Para finalizar o app, adicionar estrutura mínima:

- `app/` (Flutter)
- `services/places-proxy/`
- `services/ai-proxy/`
- `services/tracking/`
- `infra/terraform/`
- `firebase/` (regras, índices, emuladores)

### Entregáveis imediatos

- Projeto Flutter inicial com flavors (`dev`, `staging`, `prod`).
- Arquivo de exemplo de ambiente (`.env.example`).
- Configuração de lint/análise (`analysis_options.yaml`).

---

## 3) Implementar backend mínimo funcional

### 3.1 `tracking` primeiro

- Criar endpoint para gerar token de rastreamento.
- Criar endpoint para consulta pública com dados filtrados.
- Implementar revogação/expiração.
- Adicionar rate limit via Redis.

### 3.2 `places-proxy`

- Endpoints de autocomplete/details.
- Cache de respostas com TTL.
- Validação de entrada e normalização de payload.

### 3.3 `ai-proxy`

- Validar entrada/saída por JSON Schema.
- Sanitizar saída.
- Fallback em erro upstream.

---

## 4) Fechar segurança antes de abrir produção

- IAM por serviço (least privilege).
- Segredos em Secret Manager (sem chave hardcoded).
- Regras Firestore/Storage com testes de permissão.
- Cloud Armor no entrypoint HTTP.
- Auditoria habilitada (Audit Logs + SCC).

---

## 5) Subir CI/CD obrigatório

### App Flutter

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- Build Android/iOS por flavor
- Distribuição interna (QA) antes de release

### Serviços

- testes unitários/integrados
- build de imagem
- scan de segurança
- deploy em `staging`
- aprovação manual para `prod`

### Infra

- `terraform fmt -check`
- `terraform validate`
- `terraform plan`
- `terraform apply` com aprovação

---

## 6) Plano de QA para “finalizar de verdade”

### 6.1 Fluxos críticos

- Login/logout e recuperação de sessão.
- Criar rota -> iniciar rota -> concluir parada -> anexar POD.
- Compartilhar link de rastreamento -> consultar sem autenticação.
- Cenários de falha de rede e retry.

### 6.2 Critérios de entrada em produção

- 0 bugs P0/P1 abertos.
- Taxa de crash abaixo da meta definida.
- Alertas operacionais ativos e testados.
- Runbook de incidente documentado.

---

## 7) Checklist objetivo de go-live

- [ ] Flutter app versionado e buildando em CI.
- [ ] Serviços Cloud Run implantados em `staging` e `prod`.
- [ ] Banco/regras Firebase validadas por testes automatizados.
- [ ] Secret Manager com rotação definida.
- [ ] Dashboards e alertas de latência/erro/custo publicados.
- [ ] Política de backup/export de dados definida.
- [ ] Teste de carga básico aprovado para horário de pico.
- [ ] Aprovação final de segurança e operação.

---

## 8) Sequência recomendada (4 sprints)

### Sprint 1
- Bootstrap Flutter + autenticação + base de dados de perfil.

### Sprint 2
- Rotas/paradas + tracking público + POD.

### Sprint 3
- Proxies (`places` e `ai`) + segurança e rate limiting.

### Sprint 4
- Hardening, observabilidade, QA de regressão, go-live.

---

## 9) Resultado esperado ao final

- App operacional em produção para Minas Gerais.
- Fluxo ponta a ponta funcionando com monitoramento.
- Segurança mínima de produção aplicada.
- Processo de release repetível e auditável.
